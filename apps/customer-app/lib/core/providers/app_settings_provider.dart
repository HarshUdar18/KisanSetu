import 'package:flutter/material.dart';
import '../../features/location/models/address_model.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

enum PermissionStatusState { unknown, granted, denied, permanentlyDenied }

enum LocationSelectionStatus { notSelected, selected, skipped }

class AppSettingsProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  AppSettingsProvider(this._prefs);

  String _languageCode = 'en';
  ThemeMode _themeMode = ThemeMode.light;
  bool _onboardingSeen = false;
  PermissionStatusState _locationPermission = PermissionStatusState.unknown;
  PermissionStatusState _notificationPermission = PermissionStatusState.unknown;

  LocationSelectionStatus _locationStatus = LocationSelectionStatus.notSelected;
  String? _selectedLocationName;
  String? _selectedLocationPin;
  String? _selectedFullAddress;
  double? _selectedLatitude;
  double? _selectedLongitude;
  final List<Map<String, String>> _recentLocations = [];

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

  LocationSelectionStatus get locationStatus => _locationStatus;
  bool get isLocationSelected =>
      _locationStatus == LocationSelectionStatus.selected &&
      (_selectedLocationName?.isNotEmpty ?? false);
  bool get isLocationSkipped => _locationStatus == LocationSelectionStatus.skipped;
  String get locationStatusCode =>
      _locationStatus == LocationSelectionStatus.selected ? 'SELECTED' : 'NOT_SELECTED';

  String get selectedLocationName => _selectedLocationName ?? '';
  String get selectedLocationPin => _selectedLocationPin ?? '';
  String? get selectedFullAddress => _selectedFullAddress;
  double? get selectedLatitude => _selectedLatitude;
  double? get selectedLongitude => _selectedLongitude;

  String get formattedDeliveryLocation {
    if (!isLocationSelected) {
      return 'Select location';
    }
    if (_selectedLocationPin != null && _selectedLocationPin!.isNotEmpty) {
      return '${_selectedLocationName!} ${_selectedLocationPin!}';
    }
    return _selectedLocationName!;
  }

  List<Map<String, String>> get recentLocations => List.unmodifiable(_recentLocations);

  Future<void> loadSettings() async {
    _languageCode = await _prefs.getString(AppConstants.languageCodeKey) ?? 'en';
    _onboardingSeen = await _prefs.getBool(AppConstants.onboardingSeenKey);

    final statusStr = await _prefs.getString(AppConstants.locationStatusKey);
    if (statusStr == 'SELECTED') {
      final name = await _prefs.getString(AppConstants.selectedLocationNameKey);
      if (name != null && name.isNotEmpty) {
        _locationStatus = LocationSelectionStatus.selected;
        _selectedLocationName = name;
        _selectedLocationPin = await _prefs.getString(AppConstants.selectedLocationPinKey);
        _selectedFullAddress =
            await _prefs.getString(AppConstants.selectedLocationFullAddressKey);
        final latStr = await _prefs.getString(AppConstants.selectedLocationLatKey);
        final lngStr = await _prefs.getString(AppConstants.selectedLocationLngKey);
        _selectedLatitude = latStr != null ? double.tryParse(latStr) : null;
        _selectedLongitude = lngStr != null ? double.tryParse(lngStr) : null;
      } else {
        _locationStatus = LocationSelectionStatus.notSelected;
      }
    } else if (statusStr == 'SKIPPED') {
      _locationStatus = LocationSelectionStatus.skipped;
      _selectedLocationName = null;
      _selectedLocationPin = null;
      _selectedFullAddress = null;
      _selectedLatitude = null;
      _selectedLongitude = null;
    } else {
      _locationStatus = LocationSelectionStatus.notSelected;
      _selectedLocationName = null;
      _selectedLocationPin = null;
      _selectedFullAddress = null;
      _selectedLatitude = null;
      _selectedLongitude = null;
    }

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

  Future<void> setDeliveryLocation(
    String name,
    String pinCode, {
    String? area,
    String? fullAddress,
    double? latitude,
    double? longitude,
  }) async {
    final cleanName = name.trim();
    final cleanPin = pinCode.trim();
    if (cleanName.isEmpty) return;

    _locationStatus = LocationSelectionStatus.selected;
    _selectedLocationName = cleanName;
    _selectedLocationPin = cleanPin.isNotEmpty ? cleanPin : null;
    _selectedFullAddress = (fullAddress != null && fullAddress.trim().isNotEmpty)
        ? fullAddress.trim()
        : cleanName;
    _selectedLatitude = latitude;
    _selectedLongitude = longitude;

    await _prefs.setString(AppConstants.locationStatusKey, 'SELECTED');
    await _prefs.setString(AppConstants.selectedLocationNameKey, cleanName);
    if (cleanPin.isNotEmpty) {
      await _prefs.setString(AppConstants.selectedLocationPinKey, cleanPin);
    } else {
      await _prefs.remove(AppConstants.selectedLocationPinKey);
    }
    await _prefs.setString(
      AppConstants.selectedLocationFullAddressKey,
      _selectedFullAddress!,
    );
    if (latitude != null && longitude != null) {
      await _prefs.setString(AppConstants.selectedLocationLatKey, latitude.toString());
      await _prefs.setString(AppConstants.selectedLocationLngKey, longitude.toString());
    } else {
      await _prefs.remove(AppConstants.selectedLocationLatKey);
      await _prefs.remove(AppConstants.selectedLocationLngKey);
    }

    if (!_recentLocations.any((l) => l['pinCode'] == cleanPin && l['name'] == cleanName)) {
      _recentLocations.insert(0, {
        'name': cleanName,
        'pinCode': cleanPin,
        'area': area ?? _selectedFullAddress ?? cleanName,
      });
      if (_recentLocations.length > 5) _recentLocations.removeLast();
    }
    notifyListeners();
  }

  Future<void> syncFromDefaultAddress(AddressModel? address) async {
    if (address == null) return;
    final shortName = address.label.isNotEmpty
        ? '${address.label} • ${address.city}'
        : address.city;
    await setDeliveryLocation(
      shortName,
      address.pincode,
      area: address.addressLine1,
      fullAddress: address.fullAddressText,
      latitude: address.latitude,
      longitude: address.longitude,
    );
  }

  Future<void> skipLocation() async {
    _locationStatus = LocationSelectionStatus.skipped;
    _selectedLocationName = null;
    _selectedLocationPin = null;
    _selectedFullAddress = null;
    _selectedLatitude = null;
    _selectedLongitude = null;
    await _prefs.setString(AppConstants.locationStatusKey, 'SKIPPED');
    await _prefs.remove(AppConstants.selectedLocationNameKey);
    await _prefs.remove(AppConstants.selectedLocationPinKey);
    await _prefs.remove(AppConstants.selectedLocationFullAddressKey);
    await _prefs.remove(AppConstants.selectedLocationLatKey);
    await _prefs.remove(AppConstants.selectedLocationLngKey);
    notifyListeners();
  }

  Future<void> clearLocationOnLogout() async {
    _locationStatus = LocationSelectionStatus.notSelected;
    _selectedLocationName = null;
    _selectedLocationPin = null;
    _selectedFullAddress = null;
    _selectedLatitude = null;
    _selectedLongitude = null;
    _recentLocations.clear();
    await _prefs.remove(AppConstants.locationStatusKey);
    await _prefs.remove(AppConstants.selectedLocationNameKey);
    await _prefs.remove(AppConstants.selectedLocationPinKey);
    await _prefs.remove(AppConstants.selectedLocationFullAddressKey);
    await _prefs.remove(AppConstants.selectedLocationLatKey);
    await _prefs.remove(AppConstants.selectedLocationLngKey);
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
