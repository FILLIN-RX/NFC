import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/result.dart';
import '../../../token_creation/domain/models/token.dart';

/// Représente un appareil Bluetooth (appairé ou découvert).
class BtDevice {
  final String name;
  final String address;

  const BtDevice({required this.name, required this.address});

  @override
  bool operator ==(Object other) =>
      other is BtDevice && other.address == address;

  @override
  int get hashCode => address.hashCode;
}

/// Étapes d'un transfert Bluetooth, exposées à l'UI.
enum BtTransferStage { waiting, connecting, transferring, completed }

/// Service Bluetooth classique (RFCOMM / SPP) — Phase 2 Dev 2.
///
/// Le transfert téléphone↔téléphone repose sur un socket RFCOMM :
///  - l'émetteur ([sendToken]) joue le **client** (connexion + écriture JSON) ;
///  - le récepteur ([receiveToken]) joue le **serveur** (accept + lecture + ACK).
///
/// L'implémentation native (Kotlin) est volontairement utilisée plutôt qu'un
/// package tiers non maintenu (incompatible AGP 8 / Gradle 9).
class BluetoothService {
  static const MethodChannel _method = MethodChannel('narco/bt');
  static const EventChannel _events = EventChannel('narco/bt_events');

  static const Duration _defaultTimeout =
      Duration(seconds: AppConstants.nfcTimeoutSeconds);

  Stream<dynamic>? _broadcast;
  Stream<dynamic> get _eventStream =>
      _broadcast ??= _events.receiveBroadcastStream().asBroadcastStream();

  // ---------------------------------------------------------------------------
  // Permissions & état
  // ---------------------------------------------------------------------------

  /// Demande les permissions Bluetooth nécessaires (Android 12+).
  Future<bool> ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((s) => s.isGranted || s.isLimited);
  }

  Future<bool> isEnabled() async {
    try {
      return (await _method.invokeMethod<bool>('isEnabled')) ?? false;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Découverte des appareils
  // ---------------------------------------------------------------------------

  Future<Result<List<BtDevice>>> bondedDevices() async {
    try {
      final raw = await _method.invokeMethod<List<dynamic>>('bondedDevices') ?? [];
      return Success(raw.map(_mapDevice).toList());
    } catch (e) {
      return Failure('Impossible de lister les appareils appairés.', error: e);
    }
  }

  /// Flux des appareils découverts pendant un scan.
  Stream<BtDevice> discoveredDevices() {
    return _eventStream
        .where((e) => e is Map && e['event'] == 'discovered')
        .map((e) => _mapDevice(e));
  }

  Future<void> startDiscovery() async {
    try {
      await _method.invokeMethod('startDiscovery');
    } catch (e) {
      AppLogger.bluetooth('Échec démarrage scan : $e');
    }
  }

  Future<void> stopDiscovery() async {
    try {
      await _method.invokeMethod('stopDiscovery');
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // ÉMISSION (rôle client RFCOMM)
  // ---------------------------------------------------------------------------

  Future<Result<void>> sendToken(
    Token token,
    String address, {
    void Function(BtTransferStage stage, {double? progress})? onStage,
    int retries = AppConstants.bluetoothMaxRetry,
  }) async {
    if (!await ensurePermissions()) {
      return Failure('Permissions Bluetooth refusées.');
    }
    if (!await isEnabled()) {
      return Failure('Le Bluetooth est désactivé. Veuillez l\'activer.');
    }

    final payload = Uint8List.fromList(utf8.encode(jsonEncode(token.toJson())));
    Object? lastError;

    for (var attempt = 1; attempt <= retries; attempt++) {
      try {
        onStage?.call(BtTransferStage.connecting, progress: 0.0);
        AppLogger.bluetooth('Envoi vers $address (tentative $attempt/$retries)');
        final ok = await _method.invokeMethod<bool>('connectAndSend', {
          'address': address,
          'payload': payload,
        });
        if (ok == true) {
          onStage?.call(BtTransferStage.completed, progress: 1.0);
          AppLogger.bluetooth('Jeton ${token.tokenId} transmis.');
          return const Success(null);
        }
        lastError = 'Aucun accusé de réception.';
      } on PlatformException catch (e) {
        if (e.code == 'REJECTED') {
          return Failure('Transfert refusé par le récepteur.');
        }
        lastError = e.message;
        AppLogger.bluetooth('Tentative $attempt échouée : ${e.message}');
      }
      if (attempt < retries) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }

    return Failure(
      'Échec de l\'envoi Bluetooth après $retries tentatives.',
      error: lastError,
    );
  }

  // ---------------------------------------------------------------------------
  // RÉCEPTION (rôle serveur RFCOMM)
  // ---------------------------------------------------------------------------

  Future<Result<Token>> receiveToken({
    void Function(BtTransferStage stage, {double? progress})? onStage,
    Duration timeout = _defaultTimeout,
  }) async {
    if (!await ensurePermissions()) {
      return Failure('Permissions Bluetooth refusées.');
    }
    if (!await isEnabled()) {
      return Failure('Le Bluetooth est désactivé. Veuillez l\'activer.');
    }

    final completer = Completer<Result<Token>>();
    StreamSubscription<dynamic>? subscription;
    Timer? timer;

    Future<void> finish(Result<Token> result) async {
      if (completer.isCompleted) return;
      timer?.cancel();
      await subscription?.cancel();
      if (result is Failure) {
        try {
          await _method.invokeMethod('stopServer');
        } catch (_) {}
      }
      completer.complete(result);
    }

    subscription = _eventStream
        .where((e) => e is Map && e['event'] == 'received')
        .listen((dynamic event) async {
      try {
        final map = Map<String, dynamic>.from(event as Map);
        final bytes = map['payload'] as Uint8List;
        onStage?.call(BtTransferStage.transferring, progress: 0.5);
        final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
        final token = Token.fromJson(json);
        onStage?.call(BtTransferStage.completed, progress: 1.0);
        AppLogger.bluetooth('Jeton ${token.tokenId} reçu, en attente de confirmation.');
        timer?.cancel();
        completer.complete(Success(token));
      } catch (e) {
        await finish(Failure('Jeton reçu invalide ou corrompu.', error: e));
      }
    });

    timer = Timer(timeout, () {
      AppLogger.bluetooth('Réception : délai dépassé.');
      finish(Failure('Délai dépassé : aucun envoi reçu.'));
    });

    try {
      await _method.invokeMethod('startServer');
      onStage?.call(BtTransferStage.waiting, progress: 0.0);
    } on PlatformException catch (e) {
      await finish(Failure('Impossible de démarrer la réception Bluetooth.', error: e));
    }

    return completer.future;
  }

  Future<void> respondToTransfer(bool accept) async {
    try {
      await _method.invokeMethod('respondToTransfer', {'accept': accept});
    } catch (e) {
      AppLogger.bluetooth('Erreur réponse transfert : $e');
    } finally {
      try {
        await _method.invokeMethod('stopServer');
      } catch (_) {}
    }
  }

  Future<void> cancel() async {
    try {
      await _method.invokeMethod('stopServer');
    } catch (_) {}
    await stopDiscovery();
  }

  BtDevice _mapDevice(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    return BtDevice(
      name: (map['name'] as String?) ?? 'Appareil inconnu',
      address: map['address'] as String,
    );
  }
}

/// Fournit une instance partagée de [BluetoothService].
final bluetoothServiceProvider = Provider<BluetoothService>((ref) => BluetoothService());
