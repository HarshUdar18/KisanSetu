import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(String message) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
  }

  static void e(String message, [dynamic error]) {
    debugPrint('[ERROR] $message ${error != null ? ": $error" : ""}');
  }
}
