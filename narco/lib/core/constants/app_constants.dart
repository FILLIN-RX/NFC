class AppConstants {
  AppConstants._();

  static const String appName = 'Narco';

  // Persistance locale
  static const String dbName = 'tokens.db';
  static const int dbVersion = 3;
  static const String hiveBoxName = 'token_cache';

  // Paramètres de transfert (partagés Dev 2 / Dev 3)
  static const int nfcTimeoutSeconds = 10;
  static const int bluetoothMaxRetry = 3;
  static const String protocolVersion = '1.0';
}

/// Chemins vers toutes les illustrations de l'application.
/// Les fichiers .png doivent être placés dans assets/images/.
class AppAssets {
  AppAssets._();

  // ── Illustrations empty state ──────────────────────────────────────────────
  /// Illustration : aucun jeton disponible (home screen)
  static const String emptyTokens = 'assets/images/empty_tokens.png';

  /// Illustration : aucune transaction (home & historique)
  static const String emptyTransactions = 'assets/images/empty_transactions.png';

  /// Illustration : aucun résultat de recherche
  static const String emptySearch = 'assets/images/empty_search.png';

  // ── Logo ──────────────────────────────────────────────────────────────────
  static const String logo = 'assets/logo.png';

  /// Mascotte robot (déjà présente dans les assets)
  static const String robotMascot = 'assets/images/robot_mascot.png';
}
