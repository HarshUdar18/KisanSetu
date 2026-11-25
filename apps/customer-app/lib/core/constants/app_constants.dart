class AppConstants {
  AppConstants._();

  static const String appName = 'Kisan Setu';
  static const String appTagline = 'Fresh From Farms, Directly to You';
  static const String appVersion = 'v1.0.0';

  // Secure storage keys
  static const String tokenKey = 'kisansetu_auth_token';
  static const String userKey = 'kisansetu_user_data';

  // SharedPreferences keys
  static const String languageCodeKey = 'kisansetu_language_code';
  static const String onboardingSeenKey = 'kisansetu_onboarding_seen';
  static const String themeModeKey = 'kisansetu_theme_mode';
  static const String selectedLocationNameKey = 'kisansetu_location_name';
  static const String selectedLocationPinKey = 'kisansetu_location_pin';
  static const String locationPermissionAskedKey = 'kisansetu_loc_perm_asked';
  static const String notificationPermissionAskedKey = 'kisansetu_notif_perm_asked';

  // Network timeouts
  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;

  // Pilot Service Corridors (Pune)
  static const List<Map<String, dynamic>> pilotLocations = [
    {
      'name': 'Kothrud, Pune',
      'city': 'Pune',
      'state': 'Maharashtra',
      'pinCode': '411038',
      'lat': 18.5074,
      'lng': 73.8077,
      'hub': 'Mulshi & Baramati Cluster',
    },
    {
      'name': 'Shivajinagar, Pune',
      'city': 'Pune',
      'state': 'Maharashtra',
      'pinCode': '411005',
      'lat': 18.5314,
      'lng': 73.8446,
      'hub': 'Shivajinagar Central Hub',
    },
    {
      'name': 'Akurdi, Pune',
      'city': 'Pune',
      'state': 'Maharashtra',
      'pinCode': '411035',
      'lat': 18.6495,
      'lng': 73.7707,
      'hub': 'Pimpri-Chinchwad Agro Hub',
    },
  ];
}
