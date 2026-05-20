import 'dart:developer' as developer;

class AppLogger {
  static void info(String message, {String tag = 'APP'}) {
    _log('INFO', message, tag);
  }

  static void debug(String message, {String tag = 'APP'}) {
    _log('DEBUG', message, tag);
  }

  static void warning(String message, {String tag = 'APP'}) {
    _log('WARN', message, tag);
  }

  static void error(String message, {String tag = 'APP', Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    String level,
    String message,
    String tag, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final formattedMessage = '[$tag] $level: $message';
    developer.log(
      formattedMessage,
      error: error,
      stackTrace: stackTrace,
      name: 'mambonami',
    );
  }
}
