import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kisansetu_customer_app/core/network/dio_client.dart';
import 'package:kisansetu_customer_app/core/providers/app_settings_provider.dart';
import 'package:kisansetu_customer_app/core/storage/storage_service.dart';
import 'package:kisansetu_customer_app/features/auth/providers/auth_provider.dart';
import 'package:kisansetu_customer_app/features/location/models/address_model.dart';
import 'package:kisansetu_customer_app/features/location/providers/address_provider.dart';
import 'package:kisansetu_customer_app/features/location/screens/add_edit_address_screen.dart';
import 'package:provider/provider.dart';

class _FakeBackendInterceptor extends Interceptor {
  String storedFullName = '';
  final List<Map<String, dynamic>> savedAddresses = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    if (path.endsWith('/users/me') && options.method == 'GET') {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'phone': '+919876543210',
            'fullName': storedFullName,
            'roles': ['ROLE_CUSTOMER'],
          },
        },
      ));
      return;
    }
    if (path.endsWith('/users/me') && options.method == 'PUT') {
      final body = options.data as Map<String, dynamic>? ?? {};
      storedFullName = (body['fullName'] as String?) ?? storedFullName;
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'phone': '+919876543210',
            'fullName': storedFullName,
            'roles': ['ROLE_CUSTOMER'],
          },
        },
      ));
      return;
    }
    if (path.endsWith('/service-areas/check')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'isServiceable': true,
            'serviceAreaName': 'Nigdi',
            'message': 'Delivery available in Nigdi.',
          },
        },
      ));
      return;
    }
    if (path.endsWith('/addresses') && options.method == 'POST') {
      final body = Map<String, dynamic>.from(options.data as Map);
      body['id'] = 'addr-${savedAddresses.length + 1}';
      savedAddresses.add(body);
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: {'success': true, 'data': body},
      ));
      return;
    }
    if (path.endsWith('/addresses') && options.method == 'GET') {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'data': savedAddresses},
      ));
      return;
    }
    handler.resolve(Response(
      requestOptions: options,
      statusCode: 200,
      data: {'success': true, 'data': {}},
    ));
  }
}

void main() {
  test('Dynamic greeting defaults to SetuKar and updates with real name',
      () async {
    final storage = LocalStorageServiceImpl();
    final backend = _FakeBackendInterceptor();
    final dio = DioClient(
      storageService: storage,
    );
    dio.dio.interceptors.insert(0, backend);

    final auth = AuthProvider(dioClient: dio, storageService: storage);
    expect(auth.greetingFirstName, 'SetuKar');

    await storage.write('kisansetu_auth_token', 'tok-1');
    await auth.checkSession();
    expect(auth.greetingFirstName, 'SetuKar');

    await auth.updateProfile(fullName: 'Harsh Patil');
    expect(auth.greetingFirstName, 'Harsh');

    // Restart preserves saved name
    final restarted = AuthProvider(dioClient: dio, storageService: storage);
    await restarted.checkSession();
    expect(restarted.greetingFirstName, 'Harsh');
  });

  testWidgets(
      'AddEditAddressScreen validates required fields, updates Myself profile name, and keeps Someone else separate',
      (WidgetTester tester) async {
    final storage = LocalStorageServiceImpl();
    final prefs = InMemoryPreferencesService();
    final backend = _FakeBackendInterceptor();
    final dio = DioClient(
      storageService: storage,
    );
    dio.dio.interceptors.insert(0, backend);

    final auth = AuthProvider(dioClient: dio, storageService: storage);
    await tester.runAsync(() async {
      await storage.write('kisansetu_auth_token', 'tok-1');
      await auth.checkSession();
    });
    expect(auth.greetingFirstName, 'SetuKar');

    final addressProvider = AddressProvider(dioClient: dio);
    final settings = AppSettingsProvider(prefs);
    await settings.setDeliveryLocation(
      'Nigdi, Pune',
      '411044',
      area: 'Nigdi',
      fullAddress: 'Sector 24, Nigdi, Pune, Maharashtra 411044',
      latitude: 18.6512,
      longitude: 73.7689,
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (ctx, _) => Scaffold(
            body: TextButton(
              onPressed: () => ctx.push('/add-address'),
              child: const Text('Open Add Address'),
            ),
          ),
        ),
        GoRoute(
          path: '/add-address',
          builder: (_, state) => AddEditAddressScreen(
            existingAddress: state.extra as AddressModel?,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: addressProvider),
          ChangeNotifierProvider.value(value: settings),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Add Address'));
    await tester.pumpAndSettle();

    expect(find.text('SELECT DELIVERY LOCATION'), findsOneWidget);
    expect(find.text('Add your address details'), findsOneWidget);
    expect(find.text('Who are you ordering for?'), findsOneWidget);
    expect(find.text('Myself'), findsOneWidget);
    expect(find.text('Someone else'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Office'), findsOneWidget);
    expect(find.text('Others'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);

    // Button disabled while required fields are empty
    final confirmBtn = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Confirm address'),
    );
    expect(confirmBtn.onPressed, isNull);

    // Fill required fields for Myself
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'Flat / House number *'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Flat / House number *'),
      'Flat 302, Sai Krupa',
    );
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'First name *'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'First name *'),
      'Harsh',
    );
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'Last name *'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Last name *'),
      'Patil',
    );
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'Mobile number *'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mobile number *'),
      '9876543210',
    );
    await tester.pump();

    final enabledBtn = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Confirm address'),
    );
    expect(enabledBtn.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm address'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(backend.savedAddresses.length, 1);
    expect(backend.savedAddresses.first['recipientType'], 'MYSELF');
    expect(auth.greetingFirstName, 'Harsh');

    // Now test Someone else does NOT overwrite owner profile
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first))
        .clearSnackBars();
    await tester.pumpAndSettle();
    router.push(
      '/add-address',
      extra: const AddressModel(
        id: '',
        addressLine1: '',
        pincode: '411044',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Someone else'));
    await tester.pump();

    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'Flat / House number *'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Flat / House number *'),
      'B-12, Green Park',
    );
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'First name *'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'First name *'),
      'Rohan',
    );
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'Last name *'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Last name *'),
      'Deshmukh',
    );
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'Mobile number *'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mobile number *'),
      '9123456789',
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm address'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(backend.savedAddresses.length, 2);
    expect(backend.savedAddresses.last['recipientType'], 'SOMEONE_ELSE');
    expect(backend.savedAddresses.last['recipientFirstName'], 'Rohan');
    expect(auth.greetingFirstName, 'Harsh');
  });
}
