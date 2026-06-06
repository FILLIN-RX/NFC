import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../features/token_creation/domain/models/token.dart';
import '../utils/app_logger.dart';

class SecurityService {
  // En production, cette clé devrait être stockée de manière sécurisée (KeyStore/Keychain)
  static const String _secretKey = "NARCO_SECURE_HMAC_SECRET_2024";

  /// Calcule le hash SHA-256 des données critiques du jeton
  static String calculateTokenHash(Token token) {
    final String dataToHash = [
      token.tokenId,
      token.dateCreation, // Utilise le timestamp comme nonce naturel
      token.type.toString(),
      token.valeur.toString(),
      token.valeurUnite,
      token.proprietaire,
    ].join('|');

    final bytes = utf8.encode(dataToHash);
    return sha256.convert(bytes).toString();
  }

  /// Génère une signature HMAC-SHA256
  static String generateSignature(Token token) {
    final String message = calculateTokenHash(token);
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(message);

    final hmac = Hmac(sha256, key);
    return hmac.convert(bytes).toString();
  }

  /// Vérifie l'intégrité d'un jeton reçu
  static bool verifyTokenIntegrity(Token token) {
    try {
      // 1. Vérification du hash
      final computedHash = calculateTokenHash(token);
      if (computedHash != token.hash) {
        AppLogger.warning('SECURITY', 'Hash invalide pour le jeton ${token.tokenId}');
        return false;
      }

      // 2. Vérification de la signature HMAC
      final computedSignature = generateSignature(token);
      if (computedSignature != token.signature) {
        AppLogger.warning('SECURITY', 'Signature invalide pour le jeton ${token.tokenId}');
        return false;
      }

      // 3. Vérification anti-rejeu (Anti-replay) : Le jeton n'est pas expiré
      final expirationDate = DateTime.parse(token.dateExpiration);
      if (DateTime.now().isAfter(expirationDate)) {
        AppLogger.warning('SECURITY', 'Jeton expiré (Tentative de rejeu)');
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('SECURITY', 'Erreur lors de la vérification', e);
      return false;
    }
  }

  /// Vérifie si l'UUID est déjà connu pour éviter les doublons (Anti-duplication)
  /// Cette méthode simule une vérification de cache ou de DB
  static Future<bool> isDuplicate(String tokenId, List<String> existingIds) async {
    if (existingIds.contains(tokenId)) {
      AppLogger.warning('SECURITY', 'Tentative d\'insertion de jeton dupliqué : $tokenId');
      return true;
    }
    return false;
  }

  /// Prépare un jeton pour l'envoi en y ajoutant hash et signature
  static Token secureToken(Token token) {
    final hash = calculateTokenHash(token);
    final secureToken = token.copyWith(
      hash: hash,
    );
    final signature = generateSignature(secureToken);
    
    return secureToken.copyWith(
      signature: signature,
    );
  }
}