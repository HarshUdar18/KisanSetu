import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../models/address_model.dart';

class ServiceabilityResult {
  final bool isServiceable;
  final String? serviceAreaName;
  final String? message;

  const ServiceabilityResult({
    required this.isServiceable,
    this.serviceAreaName,
    this.message,
  });
}

class AddressProvider extends ChangeNotifier {
  final DioClient dioClient;
  final bool enableMockFallback;

  AddressProvider({required this.dioClient, this.enableMockFallback = false}) {
    if (enableMockFallback) {
      _addresses = _seededAddresses;
    }
  }

  List<AddressModel> _addresses = [];

  static const List<AddressModel> _seededAddresses = [
    AddressModel(
      id: 'addr-1',
      label: 'HOME',
      addressLine1: 'Flat 402, Green Meadows, Paud Road',
      addressLine2: 'Near MIT College, Kothrud',
      city: 'Pune',
      state: 'Maharashtra',
      pincode: '411038',
      isDefault: true,
    ),
    AddressModel(
      id: 'addr-2',
      label: 'WORK',
      addressLine1: 'Floor 3, AgroTech Park, FC Road',
      addressLine2: 'Shivajinagar',
      city: 'Pune',
      state: 'Maharashtra',
      pincode: '411005',
      isDefault: false,
    ),
  ];

  bool _isLoading = false;
  bool _isCheckingServiceability = false;
  ServiceabilityResult? _lastServiceability;
  String? _errorMessage;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  bool get isCheckingServiceability => _isCheckingServiceability;
  ServiceabilityResult? get lastServiceability => _lastServiceability;
  String? get errorMessage => _errorMessage;

  AddressModel? get defaultAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await dioClient.get('/addresses');
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      if (rawList.isNotEmpty) {
        _addresses = rawList
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAddress(AddressModel address) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await dioClient.post('/addresses', data: address.toJson());
      final created = response.data['data'];
      if (created is Map<String, dynamic>) {
        final model = AddressModel.fromJson(created);
        if (model.isDefault) {
          _addresses = _addresses.map((a) => _copyWithDefault(a, false)).toList();
        }
        _addresses.add(model);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {
      if (!enableMockFallback) {
        _errorMessage = 'Unable to save address. Please check your connection and retry.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    if (address.isDefault) {
      _addresses = _addresses.map((a) => _copyWithDefault(a, false)).toList();
    }
    _addresses.add(AddressModel(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
      label: address.label,
      addressLine1: address.addressLine1,
      addressLine2: address.addressLine2,
      city: address.city,
      state: address.state,
      pincode: address.pincode,
      latitude: address.latitude,
      longitude: address.longitude,
      isDefault: address.isDefault,
    ));
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      await dioClient.post('/addresses/$id/default');
    } catch (_) {}
    _addresses = _addresses
        .map((a) => _copyWithDefault(a, a.id == id))
        .toList();
    notifyListeners();
  }

  Future<void> deleteAddress(String id) async {
    try {
      await dioClient.delete('/addresses/$id');
    } catch (_) {}
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<ServiceabilityResult> checkServiceability(String pincode) async {
    final clean = pincode.trim();
    if (clean.length != 6) {
      const res = ServiceabilityResult(
        isServiceable: false,
        message: 'Invalid 6-digit PIN code',
      );
      _lastServiceability = res;
      notifyListeners();
      return res;
    }

    _isCheckingServiceability = true;
    notifyListeners();

    try {
      final response = await dioClient.get(
        '/service-areas/check',
        queryParameters: {'pinCode': clean, 'pincode': clean},
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      final serviceable =
          (data['isServiceable'] ?? data['serviceable']) as bool? ?? false;
      final areaObj = data['serviceArea'] as Map<String, dynamic>?;
      final name = (data['serviceAreaName'] ?? areaObj?['name']) as String?;
      final msg = data['message'] as String? ??
          (serviceable
              ? 'Delivery available in $name within 12 hours.'
              : 'Delivery currently unavailable in your area.');
      final res = ServiceabilityResult(
        isServiceable: serviceable,
        serviceAreaName: name,
        message: msg,
      );
      _lastServiceability = res;
      _isCheckingServiceability = false;
      notifyListeners();
      return res;
    } catch (_) {
      final pilotMap = {
        '411005': 'Shivajinagar Central Hub',
        '411035': 'Akurdi Agro Hub',
        '411038': 'Kothrud & Mulshi Cluster',
      };
      final area = pilotMap[clean];
      final res = area != null
          ? ServiceabilityResult(
              isServiceable: true,
              serviceAreaName: area,
              message: 'Delivery available in $area within 12 hours.',
            )
          : const ServiceabilityResult(
              isServiceable: false,
              message: 'Delivery currently unavailable in your area.',
            );
      _lastServiceability = res;
      _isCheckingServiceability = false;
      notifyListeners();
      return res;
    }
  }

  AddressModel _copyWithDefault(AddressModel a, bool isDefault) {
    return AddressModel(
      id: a.id,
      label: a.label,
      addressLine1: a.addressLine1,
      addressLine2: a.addressLine2,
      city: a.city,
      state: a.state,
      pincode: a.pincode,
      latitude: a.latitude,
      longitude: a.longitude,
      isDefault: isDefault,
    );
  }
}
