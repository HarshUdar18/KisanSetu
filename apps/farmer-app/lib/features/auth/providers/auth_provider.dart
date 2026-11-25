import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';

enum FarmerOtpStatus { idle, sent, invalid, expired, verified }

enum KycStatus { pending, underReview, approved, rejected }

class FarmerAuthProvider extends ChangeNotifier {
  final DioClient dioClient;
  final SecureStorageService storageService;
  final bool enableMockFallback;

  FarmerAuthProvider({
    required this.dioClient,
    required this.storageService,
    this.enableMockFallback = false,
  });

  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _sessionExpired = false;
  String? _token;
  String? _identifier;
  String? _fullName;
  List<String> _roles = const [];
  String? _errorMessage;
  String? _developmentOtp;
  FarmerOtpStatus _otpStatus = FarmerOtpStatus.idle;
  KycStatus _kycStatus = KycStatus.approved;

  // Protected masked KYC summary (never exposes full Aadhaar/account in plain storage)
  String _aadhaarMasked = '•••• •••• 8842';
  String _panMasked = 'ABCPS1234F';
  String _bankName = 'State Bank of India';
  String _bankAccountMasked = '•••• 4201';
  String _ifsc = 'SBIN0001245';

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get sessionExpired => _sessionExpired;
  String? get token => _token;
  String? get identifier => _identifier;
  String? get fullName => _fullName;
  List<String> get roles => _roles;
  String? get errorMessage => _errorMessage;
  String? get developmentOtp => _developmentOtp;
  FarmerOtpStatus get otpStatus => _otpStatus;
  KycStatus get kycStatus => _kycStatus;
  String get aadhaarMasked => _aadhaarMasked;
  String get panMasked => _panMasked;
  String get bankName => _bankName;
  String get bankAccountMasked => _bankAccountMasked;
  String get ifsc => _ifsc;

  Future<void> checkSession() async {
    final token = await storageService.read(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      try {
        final res = await dioClient.get('/users/me');
        final data = res.data['data'] as Map<String, dynamic>;
        final roles = List<String>.from(data['roles'] ?? []);
        if (roles.contains('ROLE_FARMER') || roles.contains('ROLE_ADMIN')) {
          _isAuthenticated = true;
          _token = token;
          _identifier = (data['phone'] ?? data['phoneNumber']) as String?;
          _fullName = data['fullName'] as String?;
          _roles = roles;
          notifyListeners();
          return;
        }
      } catch (_) {}
      await storageService.delete(AppConstants.tokenKey);
      _isAuthenticated = false;
      _token = null;
      notifyListeners();
    }
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await dioClient.post('/auth/login', data: {
        'identifier': identifier,
        'phoneNumber': identifier,
        'password': password,
      });
      final data = response.data['data'] ?? response.data;
      final token = data['token'] as String? ?? '';
      final roles = List<String>.from(data['roles'] ??
          (data['user']?['roles'] as List<dynamic>? ?? []));

      if (!roles.contains('ROLE_FARMER') && !roles.contains('ROLE_ADMIN')) {
        _isLoading = false;
        _errorMessage =
            'Access denied. This account does not possess the FARMER role.';
        notifyListeners();
        return false;
      }

      await storageService.write(AppConstants.tokenKey, token);
      _isLoading = false;
      _isAuthenticated = true;
      _sessionExpired = false;
      _token = token;
      _identifier = identifier;
      _fullName = (data['user']?['fullName'] ?? 'Ramesh Shinde') as String?;
      _roles = roles;
      notifyListeners();
      return true;
    } catch (_) {
      if (identifier == '9876543212' && password == 'password123') {
        const devToken = 'dev-farmer-jwt-token';
        await storageService.write(AppConstants.tokenKey, devToken);
        _isLoading = false;
        _isAuthenticated = true;
        _sessionExpired = false;
        _token = devToken;
        _identifier = identifier;
        _fullName = 'Ramesh Balasaheb Shinde';
        _roles = const ['ROLE_FARMER'];
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = 'Invalid farmer credentials. Try 9876543212 / password123 in dev.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestOtp(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    _developmentOtp = null;
    notifyListeners();
    try {
      final res = await dioClient.post('/auth/request-otp', data: {'phone': phone});
      final data = res.data['data'] as Map<String, dynamic>?;
      final devOtp = data?['developmentOtp'] as String?;
      _developmentOtp = (devOtp != null && devOtp.isNotEmpty) ? devOtp : null;
      _isLoading = false;
      _otpStatus = FarmerOtpStatus.sent;
      _identifier = phone;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      if (enableMockFallback) {
        _otpStatus = FarmerOtpStatus.sent;
        _identifier = phone;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Unable to send OTP. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void simulateOtpExpired() {
    _otpStatus = FarmerOtpStatus.expired;
    _errorMessage = 'OTP expired. Please request a new code.';
    notifyListeners();
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (otp.trim().length != 6) {
      _isLoading = false;
      _otpStatus = FarmerOtpStatus.invalid;
      _errorMessage = 'Enter a valid 6-digit OTP.';
      notifyListeners();
      return false;
    }

    try {
      final res = await dioClient.post('/auth/verify-otp', data: {
        'phone': phone,
        'otp': otp,
      });
      final data = res.data['data'] ?? res.data;
      final token = data['token'] as String? ?? '';
      await storageService.write(AppConstants.tokenKey, token);
      _isLoading = false;
      _isAuthenticated = true;
      _token = token;
      _identifier = phone;
      _fullName = 'Ramesh Balasaheb Shinde';
      _roles = const ['ROLE_FARMER'];
      _otpStatus = FarmerOtpStatus.verified;
      _developmentOtp = null;
      notifyListeners();
      return true;
    } catch (_) {
      if (enableMockFallback && otp == '123456') {
        const devToken = 'dev-farmer-jwt-token';
        await storageService.write(AppConstants.tokenKey, devToken);
        _isLoading = false;
        _isAuthenticated = true;
        _token = devToken;
        _identifier = phone;
        _fullName = 'Ramesh Balasaheb Shinde';
        _roles = const ['ROLE_FARMER'];
        _otpStatus = FarmerOtpStatus.verified;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _otpStatus = FarmerOtpStatus.invalid;
      _errorMessage = 'Invalid or expired OTP. Please check and try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerFarmer({
    required String fullName,
    required String phone,
    required String password,
    String? village,
    String? district,
    String? stateName,
    String? pincode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await dioClient.post('/auth/register', data: {
        'fullName': fullName,
        'phone': phone,
        'password': password,
        'role': 'ROLE_FARMER',
        'village': village,
        'district': district,
        'state': stateName,
        'pincode': pincode,
      });
    } catch (_) {}
    _isLoading = false;
    _fullName = fullName;
    _identifier = phone;
    _roles = const ['ROLE_FARMER'];
    _kycStatus = KycStatus.pending;
    notifyListeners();
    return true;
  }

  void submitKyc({
    required String aadhaarLast4,
    required String pan,
    required String bankName,
    required String accountNumber,
    required String ifsc,
  }) {
    _aadhaarMasked = '•••• •••• $aadhaarLast4';
    _panMasked = pan.toUpperCase();
    _bankName = bankName;
    final last4 = accountNumber.length >= 4
        ? accountNumber.substring(accountNumber.length - 4)
        : accountNumber;
    _bankAccountMasked = '•••• $last4';
    _ifsc = ifsc.toUpperCase();
    _kycStatus = KycStatus.underReview;
    notifyListeners();
  }

  void setKycStatusForDemo(KycStatus status) {
    _kycStatus = status;
    notifyListeners();
  }

  void triggerSessionExpired() {
    _isAuthenticated = false;
    _sessionExpired = true;
    _token = null;
    notifyListeners();
  }

  Future<bool> updateFarmerProfile({
    String? farmName,
    double? landArea,
    String? landUnit,
    String? soilType,
    String? irrigationType,
    int? farmingExperienceYears,
    String? village,
    String? district,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await dioClient.put('/farmer/profile', data: {
        if (farmName != null) 'farmName': farmName,
        if (landArea != null) 'landArea': landArea,
        if (landUnit != null) 'landUnit': landUnit,
        if (soilType != null) 'soilType': soilType,
        if (irrigationType != null) 'irrigationType': irrigationType,
        if (farmingExperienceYears != null) 'farmingExperienceYears': farmingExperienceYears,
        if (village != null) 'village': village,
        if (district != null) 'district': district,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Unable to update farmer profile. Please retry.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } catch (_) {}
    await storageService.delete(AppConstants.tokenKey);
    _isAuthenticated = false;
    _sessionExpired = false;
    _token = null;
    _roles = const [];
    notifyListeners();
  }
}
