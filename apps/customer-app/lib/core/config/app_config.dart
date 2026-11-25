import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'KrishiConnect Consumer';
  static const String appTagline = 'Fresh Farm Produce Direct to Your Doorstep';

  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api/v1';
      default:
        return 'http://localhost:8080/api/v1';
    }
  }
}
