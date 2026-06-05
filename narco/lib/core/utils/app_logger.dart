class AppLogger {
  AppLogger._();

  static void info(String tag, String message) {
    // ignore: avoid_print
    print('[$tag] [INFO] $message');
  }

  static void warning(String tag, String message) {
    // ignore: avoid_print
    print('[$tag] [WARNING] $message');
  }

  static void error(String tag, String message, [Object? error, StackTrace? stack]) {
    // ignore: avoid_print
    print('[$tag] [ERROR] $message${error != null ? ' | $error' : ''}');
    if (stack != null) {
      // ignore: avoid_print
      print(stack);
    }
  }

  static void debug(String tag, String message) {
    // ignore: avoid_print
    print('[$tag] [DEBUG] $message');
  }

  // Raccourcis par module (cf. plan d'organisation).
  static void nfc(String message) => info('NFC', message);
  static void bluetooth(String message) => info('BT', message);
  static void security(String message) => info('SEC', message);
  static void history(String message) => info('HST', message);
}
