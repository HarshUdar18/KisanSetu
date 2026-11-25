import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

enum PermissionState { unknown, granted, denied, permanentlyDenied }

class FarmerSettingsProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  FarmerSettingsProvider(this._prefs);

  String _languageCode = 'en';
  ThemeMode _themeMode = ThemeMode.light;
  bool _onboardingSeen = false;
  PermissionState _locationPermission = PermissionState.unknown;
  PermissionState _notificationPermission = PermissionState.unknown;

  String _farmName = 'Shinde Farmstead';
  String _village = 'Mulshi';
  String _taluka = 'Mulshi';
  String _district = 'Pune';
  String _stateName = 'Maharashtra';
  String _landArea = '3.4';
  String _landUnit = 'Acres';
  String _ownershipType = 'Individual Smallholder / Landowner';
  String _soilType = 'Black Cotton / Loamy';
  String _waterSource = 'Drip Irrigation + Borewell';
  String _selectedHubId = 'hub-mulshi';
  String _selectedHubName = 'Mulshi Dawn Hub (मुळशी डाऊन केंद्र)';

  // Notification preferences
  bool orderNotifs = true;
  bool paymentNotifs = true;
  bool collectionNotifs = true;
  bool qcNotifs = true;
  bool settlementNotifs = true;
  bool weatherNotifs = true;
  bool schemeNotifs = true;
  bool accountNotifs = true;
  bool promoNotifs = false;

  // Offline sync queue
  int _pendingOfflineActions = 2;

  String get languageCode => _languageCode;
  ThemeMode get themeMode => _themeMode;
  bool get onboardingSeen => _onboardingSeen;
  PermissionState get locationPermission => _locationPermission;
  PermissionState get notificationPermission => _notificationPermission;
  String get farmName => _farmName;
  String get village => _village;
  String get taluka => _taluka;
  String get district => _district;
  String get stateName => _stateName;
  String get landArea => _landArea;
  String get landUnit => _landUnit;
  String get ownershipType => _ownershipType;
  String get soilType => _soilType;
  String get waterSource => _waterSource;
  String get selectedHubId => _selectedHubId;
  String get selectedHubName => _selectedHubName;
  int get pendingOfflineActions => _pendingOfflineActions;

  Future<void> loadSettings() async {
    _languageCode = await _prefs.getString(AppConstants.languageCodeKey) ?? 'en';
    _onboardingSeen = await _prefs.getBool(AppConstants.onboardingSeenKey);
    _village = await _prefs.getString(AppConstants.farmVillageKey) ?? 'Mulshi';
    _district = await _prefs.getString(AppConstants.farmDistrictKey) ?? 'Pune';
    _selectedHubName =
        await _prefs.getString(AppConstants.collectionHubKey) ?? _selectedHubName;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    await _prefs.setString(AppConstants.languageCodeKey, code);
    notifyListeners();
  }

  void toggleBilingual() {
    setLanguage(_languageCode == 'en' ? 'mr' : 'en');
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(AppConstants.themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingSeen = true;
    await _prefs.setBool(AppConstants.onboardingSeenKey, true);
    notifyListeners();
  }

  void setLocationPermission(PermissionState s) {
    _locationPermission = s;
    notifyListeners();
  }

  void setNotificationPermission(PermissionState s) {
    _notificationPermission = s;
    notifyListeners();
  }

  Future<void> updateFarmLocation({
    required String village,
    required String taluka,
    required String district,
    required String stateName,
  }) async {
    _village = village;
    _taluka = taluka;
    _district = district;
    _stateName = stateName;
    await _prefs.setString(AppConstants.farmVillageKey, village);
    await _prefs.setString(AppConstants.farmDistrictKey, district);
    notifyListeners();
  }

  void updateFarmDetails({
    String? farmName,
    String? landArea,
    String? landUnit,
    String? ownershipType,
    String? soilType,
    String? waterSource,
  }) {
    if (farmName != null) _farmName = farmName;
    if (landArea != null) _landArea = landArea;
    if (landUnit != null) _landUnit = landUnit;
    if (ownershipType != null) _ownershipType = ownershipType;
    if (soilType != null) _soilType = soilType;
    if (waterSource != null) _waterSource = waterSource;
    notifyListeners();
  }

  Future<void> selectCollectionHub(String id, String name) async {
    _selectedHubId = id;
    _selectedHubName = name;
    await _prefs.setString(AppConstants.collectionHubKey, name);
    notifyListeners();
  }

  void syncOfflineQueue() {
    _pendingOfflineActions = 0;
    notifyListeners();
  }

  void updateNotificationPref({
    bool? order,
    bool? payment,
    bool? collection,
    bool? qc,
    bool? settlement,
    bool? weather,
    bool? scheme,
    bool? account,
    bool? promo,
  }) {
    if (order != null) orderNotifs = order;
    if (payment != null) paymentNotifs = payment;
    if (collection != null) collectionNotifs = collection;
    if (qc != null) qcNotifs = qc;
    if (settlement != null) settlementNotifs = settlement;
    if (weather != null) weatherNotifs = weather;
    if (scheme != null) schemeNotifs = scheme;
    if (account != null) accountNotifs = account;
    if (promo != null) promoNotifs = promo;
    notifyListeners();
  }
}
