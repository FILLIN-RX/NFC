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
