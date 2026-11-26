class AppConstants {
  AppConstants._();

  static const String appName = 'Kisan Setu Farmer';
  static const String appTagline = 'Direct Farm-to-Market Producer Network';
  static const String appVersion = 'v1.0.0';

  // Secure storage keys (Farmer-specific, never shared with Customer App)
  static const String tokenKey = 'kisansetu_farmer_auth_token';
  static const String refreshTokenKey = 'kisansetu_farmer_refresh_token';
  static const String userKey = 'kisansetu_farmer_user_data';

  // SharedPreferences keys (Non-sensitive settings only)
  static const String languageCodeKey = 'kisansetu_farmer_lang';
  static const String onboardingSeenKey = 'kisansetu_farmer_onboarding_seen';
  static const String themeModeKey = 'kisansetu_farmer_theme';
  static const String farmVillageKey = 'kisansetu_farmer_village';
  static const String farmDistrictKey = 'kisansetu_farmer_district';
  static const String collectionHubKey = 'kisansetu_farmer_hub';

  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;

  static const List<Map<String, dynamic>> collectionHubs = [
    {
      'id': 'hub-mulshi',
      'name': 'Mulshi Dawn Hub (मुळशी डाऊन केंद्र)',
      'district': 'Pune',
      'taluka': 'Mulshi',
      'distanceKm': 4.2,
      'slots': ['5:00 AM - 6:00 AM', '6:00 AM - 7:30 AM'],
      'available': true,
    },
    {
      'id': 'hub-shivajinagar',
      'name': 'Shivajinagar Central Hub',
      'district': 'Pune',
      'taluka': 'Haveli',
      'distanceKm': 14.8,
      'slots': ['5:30 AM - 7:00 AM', '4:00 PM - 6:00 PM'],
      'available': true,
    },
    {
      'id': 'hub-baramati',
      'name': 'Baramati Agro Collection Point',
      'district': 'Pune',
      'taluka': 'Baramati',
      'distanceKm': 88.0,
      'slots': ['6:00 AM - 8:00 AM'],
      'available': true,
    },
  ];
}
