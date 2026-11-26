class AppConstants {
  AppConstants._();

  static const String appName = 'Kisan Setu';
  static const String appTagline = 'Fresh From Farms, Directly to You';
  static const String appVersion = 'v1.0.0';

  // Secure storage keys
  static const String tokenKey = 'kisansetu_auth_token';
  static const String refreshTokenKey = 'kisansetu_refresh_token';
  static const String userKey = 'kisansetu_user_data';

  // SharedPreferences keys
  static const String languageCodeKey = 'kisansetu_language_code';
  static const String onboardingSeenKey = 'kisansetu_onboarding_seen';
  static const String themeModeKey = 'kisansetu_theme_mode';
  static const String locationStatusKey = 'kisansetu_location_status';
  static const String selectedLocationNameKey = 'kisansetu_location_name';
  static const String selectedLocationPinKey = 'kisansetu_location_pin';
  static const String selectedLocationFullAddressKey = 'kisansetu_location_full_address';
  static const String selectedLocationLatKey = 'kisansetu_location_lat';
  static const String selectedLocationLngKey = 'kisansetu_location_lng';
  static const String locationPermissionAskedKey = 'kisansetu_loc_perm_asked';
  static const String notificationPermissionAskedKey = 'kisansetu_notif_perm_asked';

  // Network timeouts
  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;
}
