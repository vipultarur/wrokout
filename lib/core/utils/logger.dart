import 'dart:developer' as developer;

/// Application Logger replacing print calls per Step 4 Dart & Architecture rules.
abstract class AppLogger {
  AppLogger._();

  static void info(String message, [String name = 'APP']) {
    developer.log(message, name: name, level: 800);
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace, String name = 'APP']) {
    developer.log(message, name: name, level: 900, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String name = 'APP']) {
    developer.log(message, name: name, level: 1000, error: error, stackTrace: stackTrace);
  }
}
