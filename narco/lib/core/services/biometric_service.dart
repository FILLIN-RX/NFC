import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_logger.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Vérifie si le matériel supporte la biométrie et si elle est configurée
  Future<bool> canAuthenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isDeviceSupported;
    } on PlatformException catch (e) {
      AppLogger.error('BIOMETRIC', 'Erreur canAuthenticate', e);
      return false;
    }
  }

  /// Déclenche l'authentification biométrique
  Future<bool> authenticate({String reason = 'Veuillez vous authentifier pour accéder à Narco'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      AppLogger.error('BIOMETRIC', 'Erreur authenticate', e);
      return false;
    }
  }

  /// Liste les types de biométrie disponibles (Face, Fingerprint, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      AppLogger.error('BIOMETRIC', 'Erreur getAvailableBiometrics', e);
      return <BiometricType>[];
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());
