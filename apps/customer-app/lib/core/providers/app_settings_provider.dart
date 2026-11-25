import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

enum PermissionStatusState { unknown, granted, denied, permanentlyDenied }

class AppSettingsProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  AppSettingsProvider(this._prefs);

  String _languageCode = 'en';
  ThemeMode _themeMode = ThemeMode.light;
  bool _onboardingSeen = false;
  PermissionStatusState _locationPermission = PermissionStatusState.unknown;
  PermissionStatusState _notificationPermission = PermissionStatusState.unknown;

  String _selectedLocationName = 'Kothrud, Pune';
  String _selectedLocationPin = '411038';
  final List<Map<String, String>> _recentLocations = [
    {'name': 'Kothrud, Pune', 'pinCode': '411038', 'area': 'Paud Road, Near MIT College'},
    {'name': 'Shivajinagar, Pune', 'pinCode': '411005', 'area': 'FC Road, Deccan Gymkhana'},
    {'name': 'Akurdi, Pune', 'pinCode': '411035', 'area': 'Pradhikaran Sector 27'},
  ];

  // Notification preferences
  bool orderUpdates = true;
  bool paymentUpdates = true;
  bool deliveryUpdates = true;
  bool weeklyCartReminders = true;
  bool subscriptionReminders = true;
  bool promotions = false;
  bool accountAlerts = true;

  // Delivery & Harvest preferences
  String preferredDeliverySlot = 'Morning Harvest (6:00 AM - 8:00 AM)';
  bool leaveAtDoorstep = true;
  bool zeroPlasticPackaging = true;
  bool harvestSmsAlerts = true;

  String get languageCode => _languageCode;
  ThemeMode get themeMode => _themeMode;
  bool get onboardingSeen => _onboardingSeen;
  PermissionStatusState get locationPermission => _locationPermission;
  PermissionStatusState get notificationPermission => _notificationPermission;
  String get selectedLocationName => _selectedLocationName;
  String get selectedLocationPin => _selectedLocationPin;
  String get formattedDeliveryLocation => '$_selectedLocationName $_selectedLocationPin';
  List<Map<String, String>> get recentLocations => List.unmodifiable(_recentLocations);

  Future<void> loadSettings() async {
    _languageCode = await _prefs.getString(AppConstants.languageCodeKey) ?? 'en';
    _onboardingSeen = await _prefs.getBool(AppConstants.onboardingSeenKey);
    _selectedLocationName =
        await _prefs.getString(AppConstants.selectedLocationNameKey) ?? 'Kothrud, Pune';
    _selectedLocationPin =
        await _prefs.getString(AppConstants.selectedLocationPinKey) ?? '411038';
    final themeStr = await _prefs.getString(AppConstants.themeModeKey) ?? 'light';
    _themeMode = themeStr == 'dark'
        ? ThemeMode.dark
        : themeStr == 'system'
            ? ThemeMode.system
            : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    await _prefs.setString(AppConstants.languageCodeKey, code);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final val = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.system
            ? 'system'
            : 'light';
    await _prefs.setString(AppConstants.themeModeKey, val);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingSeen = true;
    await _prefs.setBool(AppConstants.onboardingSeenKey, true);
    notifyListeners();
  }

  void setLocationPermission(PermissionStatusState status) {
    _locationPermission = status;
    notifyListeners();
  }

  void setNotificationPermission(PermissionStatusState status) {
    _notificationPermission = status;
    notifyListeners();
  }

  Future<void> setDeliveryLocation(String name, String pinCode, {String? area}) async {
    _selectedLocationName = name;
    _selectedLocationPin = pinCode;
    await _prefs.setString(AppConstants.selectedLocationNameKey, name);
    await _prefs.setString(AppConstants.selectedLocationPinKey, pinCode);
    if (!_recentLocations.any((l) => l['pinCode'] == pinCode && l['name'] == name)) {
      _recentLocations.insert(0, {
        'name': name,
        'pinCode': pinCode,
        'area': area ?? name,
      });
      if (_recentLocations.length > 5) _recentLocations.removeLast();
    }
    notifyListeners();
  }

  void updateNotificationPreference({
    bool? order,
    bool? payment,
    bool? delivery,
    bool? weeklyCart,
    bool? subscription,
    bool? promo,
    bool? account,
  }) {
    if (order != null) orderUpdates = order;
    if (payment != null) paymentUpdates = payment;
    if (delivery != null) deliveryUpdates = delivery;
    if (weeklyCart != null) weeklyCartReminders = weeklyCart;
    if (subscription != null) subscriptionReminders = subscription;
    if (promo != null) promotions = promo;
    if (account != null) accountAlerts = account;
    notifyListeners();
  }

  void updateDeliveryPreferences({
    String? slot,
    bool? leaveDoor,
    bool? zeroPlastic,
    bool? smsAlerts,
  }) {
    if (slot != null) preferredDeliverySlot = slot;
    if (leaveDoor != null) leaveAtDoorstep = leaveDoor;
    if (zeroPlastic != null) zeroPlasticPackaging = zeroPlastic;
    if (smsAlerts != null) harvestSmsAlerts = smsAlerts;
    notifyListeners();
  }
}
