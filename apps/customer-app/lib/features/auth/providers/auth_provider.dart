import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';

enum OtpVerificationStatus { idle, sent, invalid, expired, verified }

class AuthProvider extends ChangeNotifier {
  final DioClient dioClient;
  final SecureStorageService storageService;
  final bool enableMockFallback;

  AuthProvider({
    required this.dioClient,
    required this.storageService,
    this.enableMockFallback = false,
  });

  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isGuest = false;
  bool _sessionExpired = false;
  String? _token;
  String? _identifier;
  String? _countryCode = '+91';
  String? _fullName;
  String? _email;
  List<String> _roles = const [];
  String? _errorMessage;
  String? _otpChallengePhone;
  String _otpChallengeCountryCode = '+91';
  String? _developmentOtp;
  int _resendCooldownSeconds = 30;
  int _otpExpiresInSeconds = 300;
  OtpVerificationStatus _otpStatus = OtpVerificationStatus.idle;
  Map<String, dynamic> _capabilities = const {
    'phoneOtp': true,
    'exposeDevOtp': false,
  };

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _isGuest;
  bool get sessionExpired => _sessionExpired;
  String? get token => _token;
  String? get identifier => _identifier;
  String? get countryCode => _countryCode;
  String? get fullName => _fullName;
  String? get email => _email;
  List<String> get roles => _roles;
  String? get errorMessage => _errorMessage;
  String? get otpChallengePhone => _otpChallengePhone;
  String get otpChallengeCountryCode => _otpChallengeCountryCode;
  String? get developmentOtp => _developmentOtp;
  int get resendCooldownSeconds => _resendCooldownSeconds;
  int get otpExpiresInSeconds => _otpExpiresInSeconds;
  OtpVerificationStatus get otpStatus => _otpStatus;
  Map<String, dynamic> get capabilities => _capabilities;

  static const Set<String> _placeholderNames = {
    'kisan',
    'kisan setu customer',
    'customer',
    'user',
    'setukar',
    'neighbor',
  };

  bool get hasRealName {
    final name = _fullName?.trim();
    if (name == null || name.isEmpty) return false;
    if (RegExp(r'^\+?[0-9\s\-]{7,}$').hasMatch(name)) return false;
    if (_placeholderNames.contains(name.toLowerCase())) return false;
    return true;
  }

  String get greetingFirstName {
    if (!hasRealName) return 'SetuKar';
    return _fullName!.trim().split(RegExp(r'\s+')).first;
  }

  String get firstName {
    if (!hasRealName) return '';
    return _fullName!.trim().split(RegExp(r'\s+')).first;
  }

  String get lastName {
    if (!hasRealName) return '';
    final parts = _fullName!.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return '';
    return parts.sublist(1).join(' ');
  }

  /// Normalizes a mobile number by stripping whitespace, formatting characters,
  /// and leading country/trunk prefixes (`+91`, `91`, `0` for India).
  static String normalizePhoneNumber(String raw, {String countryCode = '+91'}) {
    var clean = raw.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final cc = countryCode.trim();
    if (cc == '+91' || cc == '91' || cc.isEmpty) {
      if (clean.startsWith('+91')) {
        clean = clean.substring(3);
      } else if (clean.startsWith('91') && clean.length == 12) {
        clean = clean.substring(2);
      } else if (clean.startsWith('0') && clean.length == 11) {
        clean = clean.substring(1);
      }
      return clean;
    }
    final normalizedCc = cc.startsWith('+') ? cc : '+$cc';
    final ccDigits = normalizedCc.substring(1);
    var digits = clean.startsWith('+') ? clean.substring(1) : clean;
    if (digits.startsWith(ccDigits) && digits.length > ccDigits.length + 5) {
      digits = digits.substring(ccDigits.length);
    }
    return '$normalizedCc$digits';
  }

  /// Validates the mobile number for the selected country code.
  static String? validatePhoneNumber(String raw, {String countryCode = '+91'}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 'Please enter your mobile number.';
    }
    if (RegExp(r'[A-Za-z@]').hasMatch(trimmed)) {
      return 'Enter digits only for your mobile number.';
    }
    final normalized = normalizePhoneNumber(trimmed, countryCode: countryCode);
    if (countryCode.trim() == '+91') {
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(normalized)) {
        return 'Please enter a valid 10-digit Indian mobile number.';
      }
      return null;
    }
    if (!RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(normalized)) {
      return 'Please enter a valid mobile number.';
    }
    return null;
  }

  String get formattedPhoneDisplay {
    final phone = _otpChallengePhone ?? _identifier ?? '';
    if (_otpChallengeCountryCode == '+91' && phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    if (phone.startsWith('+')) return phone;
    return '$_otpChallengeCountryCode $phone';
  }

  Future<void> fetchCapabilities() async {
    try {
      final res = await dioClient.get('/auth/capabilities');
      final data = res.data['data'];
      if (data is Map<String, dynamic>) {
        _capabilities = data;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> checkSession() async {
    var token = await storageService.read(AppConstants.tokenKey);
    final refreshToken = await storageService.read(AppConstants.refreshTokenKey);

    if ((token == null || token.isEmpty) &&
        (refreshToken != null && refreshToken.isNotEmpty)) {
      token = await _tryRefreshSession(refreshToken);
    }

    if (token == null || token.isEmpty) {
      _isAuthenticated = false;
      _token = null;
      notifyListeners();
      return;
    }

    try {
      final response = await dioClient.get('/users/me');
      final data = response.data['data'] as Map<String, dynamic>;
      _isAuthenticated = true;
      _isGuest = false;
      _sessionExpired = false;
      _token = await storageService.read(AppConstants.tokenKey) ?? token;
      await _applyUserProfileMap(data);
      notifyListeners();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _clearStoredTokens();
        _isAuthenticated = false;
        _token = null;
      } else {
        // Offline / server unreachable: keep customer logged in using stored tokens & cached profile
        await _restoreCachedProfile();
        _isAuthenticated = true;
        _isGuest = false;
        _sessionExpired = false;
        _token = token;
      }
      notifyListeners();
    } catch (_) {
      await _restoreCachedProfile();
      _isAuthenticated = true;
      _isGuest = false;
      _token = token;
      notifyListeners();
    }
  }

  Future<String?> _tryRefreshSession(String refreshToken) async {
    try {
      final res = await dioClient.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      final data = res.data['data'] as Map<String, dynamic>?;
      final newToken = data?['token'] as String?;
      final newRefresh = data?['refreshToken'] as String?;
      if (newToken != null && newToken.isNotEmpty) {
        await storageService.write(AppConstants.tokenKey, newToken);
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await storageService.write(AppConstants.refreshTokenKey, newRefresh);
        }
        return newToken;
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _clearStoredTokens();
      }
    } catch (_) {}
    return null;
  }

  Future<void> _applyUserProfileMap(Map<String, dynamic> data) async {
    _identifier = (data['phone'] ?? data['phoneNumber'] ?? data['identifier']) as String?;
    final rawName = (data['fullName'] as String?)?.trim();
    _fullName = (rawName != null && rawName.isNotEmpty) ? rawName : null;
    _email = (data['email'] as String?)?.trim();
    _roles = List<String>.from(data['roles'] ?? const ['ROLE_CUSTOMER']);
    await storageService.write(
      AppConstants.userKey,
      jsonEncode({
        'phone': _identifier,
        'fullName': _fullName,
        'email': _email,
        'roles': _roles,
      }),
    );
  }

  Future<void> _restoreCachedProfile() async {
    final raw = await storageService.read(AppConstants.userKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _identifier = decoded['phone'] as String?;
        _fullName = decoded['fullName'] as String?;
        _email = decoded['email'] as String?;
        _roles = List<String>.from(decoded['roles'] ?? const ['ROLE_CUSTOMER']);
      }
    } catch (_) {}
  }

  Future<void> _fetchCustomerProfile() async {
    try {
      final response = await dioClient.get('/users/me');
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        await _applyUserProfileMap(data);
      }
    } catch (_) {}
  }

  void continueAsGuest() {
    _isAuthenticated = false;
    _isGuest = true;
    _sessionExpired = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> requestOtp(String rawPhone, {String countryCode = '+91'}) async {
    final validationError = validatePhoneNumber(rawPhone, countryCode: countryCode);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    final normalized = normalizePhoneNumber(rawPhone, countryCode: countryCode);
    _isLoading = true;
    _errorMessage = null;
    _developmentOtp = null;
    _otpStatus = OtpVerificationStatus.idle;
    notifyListeners();

    try {
      final response = await dioClient.post('/auth/request-otp', data: {
        'identifier': normalized,
        'phone': normalized,
        'countryCode': countryCode,
      });
      final data = response.data['data'] as Map<String, dynamic>?;
      final devOtp = data?['developmentOtp'] as String?;
      _developmentOtp = (devOtp != null && devOtp.trim().isNotEmpty) ? devOtp.trim() : null;
      _resendCooldownSeconds = (data?['resendCooldownSeconds'] as num?)?.toInt() ?? 30;
      _otpExpiresInSeconds = (data?['expiresInSeconds'] as num?)?.toInt() ?? 300;
      _otpChallengePhone = normalized;
      _otpChallengeCountryCode = countryCode;
      _otpStatus = OtpVerificationStatus.sent;
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      if (enableMockFallback) {
        _otpChallengePhone = normalized;
        _otpChallengeCountryCode = countryCode;
        _otpStatus = OtpVerificationStatus.sent;
        notifyListeners();
        return true;
      }
      final serverMsg = (e.response?.data is Map<String, dynamic>)
          ? (e.response!.data['message'] as String?)
          : null;
      _errorMessage = (serverMsg != null && serverMsg.trim().isNotEmpty)
          ? serverMsg.trim()
          : 'Unable to send OTP right now. Please check your connection.';
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      if (enableMockFallback) {
        _otpChallengePhone = normalized;
        _otpChallengeCountryCode = countryCode;
        _otpStatus = OtpVerificationStatus.sent;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Unable to send OTP. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void simulateOtpExpired() {
    _otpStatus = OtpVerificationStatus.expired;
    _errorMessage = 'Verification code has expired. Please request a new OTP.';
    notifyListeners();
  }

  Future<bool> verifyOtp(
    String rawPhone,
    String otp, {
    String countryCode = '+91',
  }) async {
    final cleanOtp = otp.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(cleanOtp)) {
      _otpStatus = OtpVerificationStatus.invalid;
      _errorMessage = 'Please enter a valid 6-digit verification code.';
      notifyListeners();
      return false;
    }

    final normalized = normalizePhoneNumber(rawPhone, countryCode: countryCode);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await dioClient.post('/auth/verify-otp', data: {
        'identifier': normalized,
        'phone': normalized,
        'countryCode': countryCode,
        'otp': cleanOtp,
        'role': 'ROLE_CUSTOMER',
      });
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
      final token = data['token'] as String? ?? '';
      final refreshToken = data['refreshToken'] as String?;
      if (token.isEmpty) {
        throw Exception('Missing access token');
      }

      await storageService.write(AppConstants.tokenKey, token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await storageService.write(AppConstants.refreshTokenKey, refreshToken);
      }

      _isAuthenticated = true;
      _isGuest = false;
      _sessionExpired = false;
      _token = token;
      _countryCode = countryCode;
      _identifier = (data['identifier'] as String?) ?? normalized;
      _roles = List<String>.from(data['roles'] ?? const ['ROLE_CUSTOMER']);

      await _fetchCustomerProfile();

      _isLoading = false;
      _otpStatus = OtpVerificationStatus.verified;
      _developmentOtp = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (enableMockFallback && cleanOtp == '123456') {
        const devToken = 'dev-jwt-token-kisansetu';
        await storageService.write(AppConstants.tokenKey, devToken);
        await storageService.write(AppConstants.refreshTokenKey, 'dev-refresh-token');
        _isLoading = false;
        _isAuthenticated = true;
        _isGuest = false;
        _sessionExpired = false;
        _token = devToken;
        _identifier = normalized;
        _fullName = 'Kisan Setu Customer';
        _email = null;
        _roles = const ['ROLE_CUSTOMER'];
        _otpStatus = OtpVerificationStatus.verified;
        _developmentOtp = null;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      final serverMsg = (e.response?.data is Map<String, dynamic>)
          ? (e.response!.data['message'] as String?)
          : null;
      final msgLower = (serverMsg ?? '').toLowerCase();
      _otpStatus = msgLower.contains('expired')
          ? OtpVerificationStatus.expired
          : OtpVerificationStatus.invalid;
      _errorMessage = (serverMsg != null && serverMsg.trim().isNotEmpty)
          ? serverMsg.trim()
          : 'Invalid or expired OTP. Please check and try again.';
      notifyListeners();
      return false;
    } catch (_) {
      if (enableMockFallback && cleanOtp == '123456') {
        const devToken = 'dev-jwt-token-kisansetu';
        await storageService.write(AppConstants.tokenKey, devToken);
        await storageService.write(AppConstants.refreshTokenKey, 'dev-refresh-token');
        _isLoading = false;
        _isAuthenticated = true;
        _isGuest = false;
        _sessionExpired = false;
        _token = devToken;
        _identifier = normalized;
        _fullName = 'Kisan Setu Customer';
        _email = null;
        _roles = const ['ROLE_CUSTOMER'];
        _otpStatus = OtpVerificationStatus.verified;
        _developmentOtp = null;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _otpStatus = OtpVerificationStatus.invalid;
      _errorMessage = 'Invalid or expired OTP. Please check and try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    await _fetchCustomerProfile();
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String fullName,
    String? email,
    String? pincode,
    String? defaultAddress,
  }) async {
    _isLoading = true;
    notifyListeners();
    final trimmedName = fullName.trim();
    try {
      final res = await dioClient.put('/users/me', data: {
        'fullName': trimmedName,
        'email': ?email,
        'pincode': ?pincode,
        'defaultDeliveryAddress': ?defaultAddress,
      });
      final data = res.data['data'];
      if (data is Map<String, dynamic>) {
        await _applyUserProfileMap(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {
      // Update local state even if offline
    }
    _fullName = trimmedName.isNotEmpty ? trimmedName : _fullName;
    if (email != null) _email = email;
    await storageService.write(
      AppConstants.userKey,
      jsonEncode({
        'phone': _identifier,
        'fullName': _fullName,
        'email': _email,
        'roles': _roles,
      }),
    );
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void triggerSessionExpired() {
    _isAuthenticated = false;
    _sessionExpired = true;
    _token = null;
    notifyListeners();
  }

  Future<void> _clearStoredTokens() async {
    await storageService.delete(AppConstants.tokenKey);
    await storageService.delete(AppConstants.refreshTokenKey);
    await storageService.delete(AppConstants.userKey);
  }

  Future<void> logout() async {
    final refreshToken = await storageService.read(AppConstants.refreshTokenKey);
    try {
      await dioClient.post('/auth/logout', data: {
        if (refreshToken != null && refreshToken.isNotEmpty) 'refreshToken': refreshToken,
      });
    } catch (_) {}
    await _clearStoredTokens();
    _isAuthenticated = false;
    _isGuest = false;
    _sessionExpired = false;
    _token = null;
    _identifier = null;
    _fullName = null;
    _email = null;
    _roles = const [];
    _otpChallengePhone = null;
    _developmentOtp = null;
    _errorMessage = null;
    _otpStatus = OtpVerificationStatus.idle;
    notifyListeners();
  }
}
