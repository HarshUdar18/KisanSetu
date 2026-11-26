import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kisansetu_customer_app/core/constants/app_constants.dart';
import 'package:kisansetu_customer_app/core/network/dio_client.dart';
import 'package:kisansetu_customer_app/core/providers/app_settings_provider.dart';
import 'package:kisansetu_customer_app/core/storage/storage_service.dart';
import 'package:kisansetu_customer_app/features/auth/providers/auth_provider.dart';
import 'package:kisansetu_customer_app/features/auth/screens/login_screen.dart';
import 'package:kisansetu_customer_app/features/auth/screens/otp_verification_screen.dart';
import 'package:kisansetu_customer_app/features/cart/providers/cart_provider.dart';
import 'package:kisansetu_customer_app/features/catalog/providers/catalog_provider.dart';
import 'package:kisansetu_customer_app/features/home/screens/home_screen.dart';
import 'package:kisansetu_customer_app/features/location/providers/address_provider.dart';
import 'package:kisansetu_customer_app/features/location/screens/select_location_screen.dart';
import 'package:kisansetu_customer_app/features/weekly_cart/providers/weekly_cart_provider.dart';
import 'package:provider/provider.dart';

class _FakeBackendAdapter implements HttpClientAdapter {
  final bool devExposeOtp;
  final List<Map<String, dynamic>> savedAddresses;
  String? lastGeneratedOtp;
  bool otpConsumed = false;

  _FakeBackendAdapter({
    this.devExposeOtp = true,
    List<Map<String, dynamic>>? initialAddresses,
  }) : savedAddresses = List<Map<String, dynamic>>.from(initialAddresses ?? const []);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path;
    if (path.endsWith('/auth/request-otp')) {
      lastGeneratedOtp = '482910';
      otpConsumed = false;
      final data = <String, dynamic>{
        'phone': '9876543211',
        'message': 'OTP dispatched successfully.',
        'expiresInSeconds': 300,
        'resendCooldownSeconds': 30,
      };
      if (devExposeOtp) {
        data['developmentOtp'] = lastGeneratedOtp;
      }
      return _jsonResponse(200, {'success': true, 'data': data});
    }

    if (path.endsWith('/auth/verify-otp')) {
      final body = options.data as Map<String, dynamic>? ?? {};
      final otp = body['otp'] as String?;
      if (otpConsumed || otp != lastGeneratedOtp) {
        return _jsonResponse(400, {
          'success': false,
          'message': 'Invalid or expired OTP.',
        });
      }
      otpConsumed = true;
      return _jsonResponse(200, {
        'success': true,
        'data': {
          'token': 'jwt-access-token',
          'refreshToken': 'refresh-token-123',
          'userId': 'a0000000-0000-0000-0000-000000000002',
          'identifier': '9876543211',
          'roles': ['ROLE_CUSTOMER'],
        },
      });
    }

    if (path.endsWith('/users/me')) {
      return _jsonResponse(200, {
        'success': true,
        'data': {
          'id': 'a0000000-0000-0000-0000-000000000002',
          'phone': '9876543211',
          'email': 'customer@kisansetu.com',
          'fullName': 'Ananya Deshmukh',
          'roles': ['ROLE_CUSTOMER'],
        },
      });
    }

    if (path.endsWith('/addresses') && options.method == 'GET') {
      return _jsonResponse(200, {'success': true, 'data': savedAddresses});
    }

    if (path.endsWith('/addresses') && options.method == 'POST') {
      final body = Map<String, dynamic>.from(options.data as Map);
      final created = {
        'id': 'addr-created-1',
        ...body,
        'isDefault': true,
      };
      savedAddresses.add(created);
      return _jsonResponse(201, {'success': true, 'data': created});
    }

    if (path.contains('/addresses/') && path.endsWith('/default')) {
      return _jsonResponse(200, {'success': true, 'data': savedAddresses.first});
    }

    if (path.endsWith('/locations/geocode')) {
      return _jsonResponse(200, {
        'success': true,
        'data': [
          {
            'latitude': 18.5314,
            'longitude': 73.8446,
            'displayName': 'FC Road, Shivajinagar, Pune, Maharashtra, 411005, India',
            'village': 'Shivajinagar',
            'district': 'Pune',
            'state': 'Maharashtra',
            'pincode': '411005',
            'country': 'India',
          }
        ],
      });
    }

    if (path.endsWith('/categories') || path.endsWith('/products') || path.endsWith('/weekly-carts')) {
      return _jsonResponse(200, {'success': true, 'data': []});
    }

    if (path.endsWith('/cart')) {
      return _jsonResponse(200, {
        'success': true,
        'data': {
          'id': 'cart-1',
          'items': [],
          'itemCount': 0,
          'subtotal': 0.0,
          'deliveryFee': 0.0,
          'logisticsFee': 0.0,
          'taxAmount': 0.0,
          'totalAmount': 0.0,
        },
      });
    }

    if (path.endsWith('/auth/logout')) {
      return _jsonResponse(200, {'success': true, 'data': null});
    }

    return _jsonResponse(404, {'success': false, 'message': 'Not found: $path'});
  }

  ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> payload) {
    final json = _encodeJson(payload);
    return ResponseBody.fromString(
      json,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  String _encodeJson(Object? value) {
    if (value == null) return 'null';
    if (value is bool || value is num) return value.toString();
    if (value is String) {
      final escaped = value
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll('\n', '\\n');
      return '"$escaped"';
    }
    if (value is List) {
      return '[${value.map(_encodeJson).join(',')}]';
    }
    if (value is Map) {
      final entries = value.entries
          .map((e) => '${_encodeJson(e.key.toString())}:${_encodeJson(e.value)}')
          .join(',');
      return '{$entries}';
    }
    return '"$value"';
  }
}

Widget _buildTestHarness({
  required DioClient dio,
  required LocalStorageServiceImpl storage,
  required AppSettingsProvider settings,
  required AuthProvider auth,
  required AddressProvider addressProvider,
  String initialLocation = '/login',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/otp-verify',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            phone: extra['phone'] as String? ?? '9876543211',
            countryCode: extra['countryCode'] as String? ?? '+91',
            initialCooldownSeconds: extra['cooldown'] as int? ?? 30,
          );
        },
      ),
      GoRoute(path: '/select-location', builder: (_, _) => const SelectLocationScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    ],
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: addressProvider),
      ChangeNotifierProvider(create: (_) => CatalogProvider(dioClient: dio)),
      ChangeNotifierProvider(create: (_) => CartProvider(dioClient: dio)),
      ChangeNotifierProvider(create: (_) => WeeklyCartProvider(dioClient: dio)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  test('Phone number normalization and validation reject invalid inputs', () {
    expect(AuthProvider.validatePhoneNumber('9876543211'), isNull);
    expect(AuthProvider.normalizePhoneNumber(' +91 98765 43211 '), '9876543211');
    expect(AuthProvider.normalizePhoneNumber('09876543211'), '9876543211');
    expect(AuthProvider.validatePhoneNumber('12345'), isNotNull);
    expect(AuthProvider.validatePhoneNumber('abcde12345'), isNotNull);
  });

  testWidgets(
      'Phone -> OTP (Dev OTP shown) -> Verify -> Location Selection (Search/Confirm) -> Dashboard without Pilot Corridor',
      (tester) async {
    final storage = LocalStorageServiceImpl();
    final dio = DioClient(storageService: storage);
    dio.dio.httpClientAdapter = _FakeBackendAdapter(devExposeOtp: true);
    final settings = AppSettingsProvider(InMemoryPreferencesService());
    final auth = AuthProvider(dioClient: dio, storageService: storage);
    final addr = AddressProvider(dioClient: dio);

    await tester.pumpWidget(_buildTestHarness(
      dio: dio,
      storage: storage,
      settings: settings,
      auth: auth,
      addressProvider: addr,
    ));

    // Phone screen checks: no Google, no password, has Skip
    expect(find.text('Welcome to Kisan Setu'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.textContaining('Google'), findsNothing);
    expect(find.textContaining('Password'), findsNothing);

    await tester.enterText(find.byType(TextField), '9876543211');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // OTP screen checks: shows Development OTP: 482910 and Change mobile number
    expect(find.text('Verify your mobile number'), findsOneWidget);
    expect(find.text('Development OTP: 482910'), findsOneWidget);
    expect(find.text('Change mobile number'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '482910');
    await tester.pump();
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    // Location Selection screen checks
    expect(find.text('Select your location'), findsOneWidget);
    expect(find.text('Use My Current Location'), findsOneWidget);
    expect(find.text('No saved addresses yet. Use your current location or search above to set your delivery address.'), findsOneWidget);

    // Manual debounced search
    await tester.enterText(
      find.widgetWithText(TextField, 'Search your area, street, city, or PIN code'),
      'Shivajinagar',
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Shivajinagar, Pune'), findsOneWidget);
    await tester.tap(find.text('Shivajinagar, Pune'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm Location'));
    await tester.pumpAndSettle();

    // Dashboard opened without Active Pilot Corridor
    expect(find.textContaining('Namaste, Ananya'), findsOneWidget);
    expect(find.textContaining('Active Pilot Corridor'), findsNothing);
    expect(settings.isLocationSelected, isTrue);
    expect(await storage.read(AppConstants.tokenKey), 'jwt-access-token');
    expect(await storage.read(AppConstants.refreshTokenKey), 'refresh-token-123');
  });

  testWidgets('Guest Skip from Phone screen opens Dashboard with NOT_SELECTED location',
      (tester) async {
    final storage = LocalStorageServiceImpl();
    final dio = DioClient(storageService: storage);
    dio.dio.httpClientAdapter = _FakeBackendAdapter();
    final settings = AppSettingsProvider(InMemoryPreferencesService());
    final auth = AuthProvider(dioClient: dio, storageService: storage);
    final addr = AddressProvider(dioClient: dio);

    await tester.pumpWidget(_buildTestHarness(
      dio: dio,
      storage: storage,
      settings: settings,
      auth: auth,
      addressProvider: addr,
    ));

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(auth.isGuest, isTrue);
    expect(auth.isAuthenticated, isFalse);
    expect(settings.locationStatusCode, 'NOT_SELECTED');
    expect(find.text('Select delivery location'), findsOneWidget);
    expect(find.textContaining('Kothrud'), findsNothing);
  });

  testWidgets('Location Skip marks NOT_SELECTED and never fabricates coordinates',
      (tester) async {
    final storage = LocalStorageServiceImpl();
    final dio = DioClient(storageService: storage);
    dio.dio.httpClientAdapter = _FakeBackendAdapter(devExposeOtp: false);
    final settings = AppSettingsProvider(InMemoryPreferencesService());
    final auth = AuthProvider(dioClient: dio, storageService: storage);
    final addr = AddressProvider(dioClient: dio);

    await tester.pumpWidget(_buildTestHarness(
      dio: dio,
      storage: storage,
      settings: settings,
      auth: auth,
      addressProvider: addr,
      initialLocation: '/select-location',
    ));

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(settings.locationStatusCode, 'NOT_SELECTED');
    expect(settings.selectedLatitude, isNull);
    expect(settings.selectedLongitude, isNull);
    expect(find.text('Select delivery location'), findsOneWidget);
  });

  testWidgets('Production response omits Development OTP in OTP screen',
      (tester) async {
    final storage = LocalStorageServiceImpl();
    final dio = DioClient(storageService: storage);
    dio.dio.httpClientAdapter = _FakeBackendAdapter(devExposeOtp: false);
    final settings = AppSettingsProvider(InMemoryPreferencesService());
    final auth = AuthProvider(dioClient: dio, storageService: storage);
    final addr = AddressProvider(dioClient: dio);

    await tester.pumpWidget(_buildTestHarness(
      dio: dio,
      storage: storage,
      settings: settings,
      auth: auth,
      addressProvider: addr,
    ));

    await tester.enterText(find.byType(TextField), '9876543211');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Verify your mobile number'), findsOneWidget);
    expect(find.textContaining('Development OTP'), findsNothing);
    expect(auth.developmentOtp, isNull);

    await tester.enterText(find.byType(TextField), '482910');
    await tester.pump();
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    expect(find.text('Select your location'), findsOneWidget);
  });

  test('Session persists tokens across restart and revokes them on logout', () async {
    final storage = LocalStorageServiceImpl();
    final dio = DioClient(storageService: storage);
    dio.dio.httpClientAdapter = _FakeBackendAdapter(devExposeOtp: false);

    final auth = AuthProvider(dioClient: dio, storageService: storage);
    expect(await auth.requestOtp('9876543211'), isTrue);
    expect(auth.developmentOtp, isNull);
    expect(await auth.verifyOtp('9876543211', '482910'), isTrue);

    final restartedAuth = AuthProvider(dioClient: dio, storageService: storage);
    await restartedAuth.checkSession();
    expect(restartedAuth.isAuthenticated, isTrue);
    expect(restartedAuth.fullName, 'Ananya Deshmukh');

    // Simulate offline restart: customer remains logged in using stored tokens & cached profile
    final offlineDio = DioClient(
      storageService: storage,
      connectTimeout: const Duration(milliseconds: 20),
      receiveTimeout: const Duration(milliseconds: 20),
    );
    final offlineAuth = AuthProvider(dioClient: offlineDio, storageService: storage);
    await offlineAuth.checkSession();
    expect(offlineAuth.isAuthenticated, isTrue);
    expect(offlineAuth.fullName, 'Ananya Deshmukh');

    await restartedAuth.logout();
    expect(restartedAuth.isAuthenticated, isFalse);
    expect(await storage.read(AppConstants.tokenKey), isNull);
    expect(await storage.read(AppConstants.refreshTokenKey), isNull);
    expect(await storage.read(AppConstants.userKey), isNull);
  });

  testWidgets('Existing customer retrieves saved addresses on Location Selection and selects one',
      (tester) async {
    final storage = LocalStorageServiceImpl();
    final dio = DioClient(storageService: storage);
    dio.dio.httpClientAdapter = _FakeBackendAdapter(
      devExposeOtp: true,
      initialAddresses: [
        {
          'id': 'addr-existing-1',
          'label': 'HOME',
          'addressLine1': 'Flat 304, Green Park Heights',
          'addressLine2': 'Shivajinagar',
          'city': 'Pune',
          'state': 'Maharashtra',
          'pincode': '411005',
          'latitude': 18.5314,
          'longitude': 73.8446,
          'isDefault': true,
        },
        {
          'id': 'addr-existing-2',
          'label': 'WORK',
          'addressLine1': 'AgroTech Park',
          'addressLine2': 'Akurdi',
          'city': 'Pune',
          'state': 'Maharashtra',
          'pincode': '411035',
          'latitude': 18.6495,
          'longitude': 73.7707,
          'isDefault': false,
        },
      ],
    );
    final settings = AppSettingsProvider(InMemoryPreferencesService());
    final auth = AuthProvider(dioClient: dio, storageService: storage);
    final addr = AddressProvider(dioClient: dio);

    await tester.pumpWidget(_buildTestHarness(
      dio: dio,
      storage: storage,
      settings: settings,
      auth: auth,
      addressProvider: addr,
    ));

    await tester.enterText(find.byType(TextField), '9876543211');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '482910');
    await tester.pump();
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(find.text('Select your location'), findsOneWidget);
    expect(find.text('Saved Addresses'), findsOneWidget);
    expect(find.text('See All'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('WORK'), findsOneWidget);

    await tester.tap(find.text('HOME'));
    await tester.pumpAndSettle();

    expect(settings.isLocationSelected, isTrue);
    expect(settings.selectedLocationPin, '411005');
    expect(find.textContaining('Namaste, Ananya'), findsOneWidget);
  });
}
