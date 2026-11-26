import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Kisan Setu';
  static const String appTagline = 'Fresh From Farms, Directly to You';

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Uses localhost via `adb reverse tcp:8080 tcp:8080` on USB devices,
        // with instant fallback to `10.0.2.2` in DioClient for Android emulators.
        return 'http://127.0.0.1:8080/api/v1';
      default:
        return 'http://localhost:8080/api/v1';
    }
  }
}
