import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/ndef_encoder.dart';
import '../../../../core/utils/result.dart';
import '../../../token_creation/domain/models/token.dart';

/// Étapes d'un transfert NFC, exposées à l'UI pour le suivi de progression.
enum NfcTransferStage {
  /// En attente du contact avec l'autre appareil.
  waiting,

  /// Appareil détecté, canal ISO-DEP établi.
  connected,

  /// Échange des données en cours.
  transferring,

  /// Transfert terminé avec succès.
  completed,
}

/// Service NFC (Phase 1 Dev 2).
///
/// Deux rôles complémentaires permettent un transfert téléphone↔téléphone :
///  - [receiveToken] : l'appareil joue le **lecteur** (ISO-DEP) et lit le jeton
///    émulé par l'autre téléphone ;
///  - [sendToken] : l'appareil joue la **carte** via HCE (Host Card Emulation),
///    le jeton est servi au lecteur d'en face.
///
/// Protocole APDU (les deux extrémités sont maîtrisées par l'application) :
///  1. `SELECT AID` → la carte renvoie la longueur totale du message NDEF ;
///  2. `READ BINARY` (00 B0 offset Le) en boucle → récupération des octets.
class NfcService {
  static const MethodChannel _method = MethodChannel('narco/hce');
  static const EventChannel _events = EventChannel('narco/hce_events');

  /// AID propriétaire « narco » (doit correspondre à `apduservice.xml`).
  static final Uint8List _aid =
      Uint8List.fromList([0xF0, 0x6E, 0x61, 0x72, 0x63, 0x6F]);

  static const Duration _defaultTimeout =
      Duration(seconds: AppConstants.nfcTimeoutSeconds);

  /// Taille maximale d'un bloc lu par commande READ BINARY.
  static const int _chunkSize = 240;

  /// Renvoie l'état de la puce NFC sur l'appareil.
  Future<NfcAvailability> availability() {
    return NfcManager.instance.checkAvailability();
  }

  // ---------------------------------------------------------------------------
  // RÉCEPTION (rôle lecteur ISO-DEP)
  // ---------------------------------------------------------------------------

  Future<Result<Token>> receiveToken({
    void Function(NfcTransferStage stage, {double? progress})? onStage,
    Duration timeout = _defaultTimeout,
  }) async {
    final availabilityResult = await _ensureAvailable();
    if (availabilityResult != null) return availabilityResult.cast<Token>();

    final completer = Completer<Result<Token>>();
    var processing = false;
    Timer? timer;

    Future<void> finish(Result<Token> result) async {
      if (completer.isCompleted) return;
      timer?.cancel();
      try {
        await NfcManager.instance.stopSession();
      } catch (_) {}
      completer.complete(result);
    }

    timer = Timer(timeout, () {
      AppLogger.nfc('Réception : délai dépassé.');
      finish(Failure('Délai dépassé : aucun appareil détecté.'));
    });

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (NfcTag tag) async {
          // Plusieurs appareils détectés successivement → annulation (cahier de charge).
          if (processing) {
            AppLogger.nfc('Réception : plusieurs appareils détectés, annulation.');
            await finish(Failure('Plusieurs appareils détectés : transfert annulé.'));
            return;
          }
          processing = true;
          onStage?.call(NfcTransferStage.connected, progress: 0.0);

          final isoDep = IsoDepAndroid.from(tag);
          if (isoDep == null) {
            await finish(Failure('Appareil ou tag incompatible (ISO-DEP requis).'));
            return;
          }

          try {
            onStage?.call(NfcTransferStage.transferring, progress: 0.0);
            final bytes = await _readPayload(isoDep, onProgress: (progress) {
              onStage?.call(NfcTransferStage.transferring, progress: progress);
            });
            final token = NdefEncoder.decode(bytes);
            onStage?.call(NfcTransferStage.completed, progress: 1.0);
            AppLogger.nfc('Réception : jeton ${token.tokenId} reçu.');
            await finish(Success(token));
          } on FormatException catch (e) {
            await finish(Failure('Jeton reçu invalide ou corrompu.', error: e));
          } catch (e) {
            await finish(Failure('Échec de lecture NFC.', error: e));
          }
        },
      );
      onStage?.call(NfcTransferStage.waiting, progress: 0.0);
    } catch (e) {
      await finish(Failure('Impossible de démarrer la session NFC.', error: e));
    }

    return completer.future;
  }

  Future<Uint8List> _readPayload(
    IsoDepAndroid isoDep, {
    void Function(double progress)? onProgress,
  }) async {
    final selectResponse = await isoDep.transceive(_buildSelectApdu());
    _ensureStatusOk(selectResponse);
    if (selectResponse.length < 4) {
      throw const FormatException('Réponse SELECT invalide.');
    }
    final total = (selectResponse[0] << 8) | selectResponse[1];
    if (total <= 0) {
      throw const FormatException('Aucune donnée à lire (longueur nulle).');
    }

    final builder = BytesBuilder();
    var offset = 0;
    while (offset < total) {
      final le = math.min(_chunkSize, total - offset);
      final readApdu = Uint8List.fromList([
        0x00,
        0xB0,
        (offset >> 8) & 0xFF,
        offset & 0xFF,
        le,
      ]);
      final response = await isoDep.transceive(readApdu);
      _ensureStatusOk(response);
      final data = response.sublist(0, response.length - 2);
      if (data.isEmpty) break;
      builder.add(data);
      offset += data.length;
      onProgress?.call(offset / total);
    }
    return builder.toBytes();
  }

  // ---------------------------------------------------------------------------
  // ÉMISSION (rôle carte via HCE)
  // ---------------------------------------------------------------------------

  Future<Result<void>> sendToken(
    Token token, {
    void Function(NfcTransferStage stage, {double? progress})? onStage,
    Duration timeout = _defaultTimeout,
  }) async {
    final availabilityResult = await _ensureAvailable();
    if (availabilityResult != null) return availabilityResult;

    final payload = NdefEncoder.encode(token);
    final completer = Completer<Result<void>>();
    Timer? timer;
    StreamSubscription<dynamic>? subscription;

    Future<void> finish(Result<void> result) async {
      if (completer.isCompleted) return;
      timer?.cancel();
      await subscription?.cancel();
      try {
        await _method.invokeMethod('stopEmulation');
      } catch (_) {}
      completer.complete(result);
    }

    subscription = _events.receiveBroadcastStream().listen(
      (dynamic event) {
        final map = Map<String, dynamic>.from(event as Map);
        switch (map['event']) {
          case 'progress':
            final served = map['served'] as int? ?? 0;
            final total = map['total'] as int? ?? 1;
            onStage?.call(NfcTransferStage.transferring, progress: served / total);
          case 'completed':
            onStage?.call(NfcTransferStage.completed, progress: 1.0);
            AppLogger.nfc('Émission : jeton ${token.tokenId} transmis.');
            finish(const Success(null));
        }
      },
      onError: (Object e) => finish(Failure('Erreur durant l\'émulation NFC.', error: e)),
    );

    timer = Timer(timeout, () {
      AppLogger.nfc('Émission : délai dépassé, aucun lecteur.');
      finish(Failure('Délai dépassé : aucun récepteur détecté.'));
    });

    try {
      await _method.invokeMethod('startEmulation', {'payload': payload});
      onStage?.call(NfcTransferStage.waiting, progress: 0.0);
    } on PlatformException catch (e) {
      await finish(Failure('Impossible de démarrer l\'émulation NFC.', error: e));
    }

    return completer.future;
  }

  /// Interrompt manuellement une émission HCE en cours.
  Future<void> cancelSending() async {
    try {
      await _method.invokeMethod('stopEmulation');
    } catch (_) {}
  }

  /// Ouvre les paramètres NFC du système.
  Future<void> openNfcSettings() async {
    try {
      await _method.invokeMethod('openNfcSettings');
    } catch (e) {
      AppLogger.nfc('Impossible d\'ouvrir les paramètres NFC: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<Failure<void>?> _ensureAvailable() async {
    final status = await availability();
    switch (status) {
      case NfcAvailability.enabled:
        return null;
      case NfcAvailability.disabled:
        return Failure('Le NFC est désactivé. Veuillez l\'activer.');
      case NfcAvailability.unsupported:
        return Failure('Cet appareil ne prend pas en charge le NFC.');
    }
  }

  Uint8List _buildSelectApdu() {
    return Uint8List.fromList([
      0x00, 0xA4, 0x04, 0x00, // CLA INS P1 P2
      _aid.length,
      ..._aid,
      0x00, // Le
    ]);
  }

  void _ensureStatusOk(Uint8List response) {
    if (response.length < 2) {
      throw const FormatException('Réponse APDU trop courte.');
    }
    final sw1 = response[response.length - 2];
    final sw2 = response[response.length - 1];
    if (sw1 != 0x90 || sw2 != 0x00) {
      throw FormatException(
        'Statut APDU inattendu : '
        '${sw1.toRadixString(16)}${sw2.toRadixString(16)}',
      );
    }
  }
}

extension _ResultCast on Failure {
  Result<R> cast<R>() => Failure<R>(message, error: error, stackTrace: stackTrace);
}

/// Fournit une instance partagée de [NfcService].
final nfcServiceProvider = Provider<NfcService>((ref) => NfcService());
