import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(String message) {
    if (kDebugMode) {
      debugPrint('[FARMER APP DEBUG] $message');
    }
  }

  static void e(String message, [dynamic error]) {
    debugPrint('[FARMER APP ERROR] $message ${error != null ? ": $error" : ""}');
  }
}
