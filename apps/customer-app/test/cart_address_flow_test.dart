import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kisansetu_customer_app/core/network/dio_client.dart';
import 'package:kisansetu_customer_app/core/providers/app_settings_provider.dart';
import 'package:kisansetu_customer_app/core/storage/storage_service.dart';
import 'package:kisansetu_customer_app/features/auth/providers/auth_provider.dart';
import 'package:kisansetu_customer_app/features/cart/providers/cart_provider.dart';
import 'package:kisansetu_customer_app/features/cart/screens/cart_screen.dart';
import 'package:kisansetu_customer_app/features/catalog/models/product_model.dart';
import 'package:kisansetu_customer_app/features/location/providers/address_provider.dart';
import 'package:kisansetu_customer_app/features/location/screens/map_location_screen.dart';
import 'package:provider/provider.dart';

class _CartFlowInterceptor extends Interceptor {
  final List<Map<String, dynamic>> addresses;

  _CartFlowInterceptor(this.addresses);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    if (path.endsWith('/users/me')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'phone': '+919876543210',
            'fullName': 'Harsh Patil',
            'roles': ['ROLE_CUSTOMER'],
          },
        },
      ));
      return;
    }
    if (path.endsWith('/addresses') && options.method == 'GET') {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'data': addresses},
      ));
      return;
    }
    if (path.endsWith('/service-areas/check') ||
        path.endsWith('/locations/serviceability')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'isServiceable': true,
            'serviceable': true,
            'serviceAreaName': 'Nigdi',
            'message': 'Delivery available in Nigdi.',
          },
        },
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
  testWidgets(
      'CartScreen shows Add Address prompt when customer has no saved address',
      (WidgetTester tester) async {
    final storage = LocalStorageServiceImpl();
    final prefs = InMemoryPreferencesService();
    final dio = DioClient(storageService: storage);
    dio.dio.interceptors.insert(0, _CartFlowInterceptor([]));

    final auth = AuthProvider(dioClient: dio, storageService: storage);
    await tester.runAsync(() async {
      await storage.write('kisansetu_auth_token', 'tok-1');
      await auth.checkSession();
    });

    final addressProvider = AddressProvider(dioClient: dio);
    final settings = AppSettingsProvider(prefs);
    final cartProvider = CartProvider(dioClient: dio, enableMockFallback: true);
    await tester.runAsync(() async {
      await cartProvider.addProduct(
        const ProductModel(
          id: 'p1',
          name: 'Fresh Spinach (Palak)',
          unit: 'bunch',
          currentPrice: 20,
        ),
      );
    });

    final router = GoRouter(
      initialLocation: '/cart',
      routes: [
        GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
        GoRoute(
          path: '/map-location',
          builder: (_, _) => const Scaffold(body: Text('Map Location Screen')),
        ),
        GoRoute(
          path: '/checkout',
          builder: (_, _) => const Scaffold(body: Text('Checkout Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: addressProvider),
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: cartProvider),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('Add your delivery address'), findsOneWidget);
    expect(
      find.text(
        'Please add your delivery address before proceeding with your order.',
      ),
      findsOneWidget,
    );
    expect(find.text('Add Address'), findsOneWidget);
    expect(find.text('Not Now'), findsOneWidget);

    // Tapping Proceed to Checkout redirects to map location instead of checkout
    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pumpAndSettle();
    expect(find.text('Map Location Screen'), findsOneWidget);
    expect(find.text('Checkout Screen'), findsNothing);
    expect(cartProvider.cart.itemCount, 1);
  });

  testWidgets(
      'CartScreen displays existing saved address and preserves cart items',
      (WidgetTester tester) async {
    final storage = LocalStorageServiceImpl();
    final prefs = InMemoryPreferencesService();
    final dio = DioClient(storageService: storage);
    dio.dio.interceptors.insert(
      0,
      _CartFlowInterceptor([
        {
          'id': 'addr-1',
          'label': 'Home',
          'addressLine1': 'Flat 302, Sai Krupa',
          'city': 'Pune',
          'state': 'Maharashtra',
          'pincode': '411044',
          'isDefault': true,
        },
      ]),
    );

    final auth = AuthProvider(dioClient: dio, storageService: storage);
    await tester.runAsync(() async {
      await storage.write('kisansetu_auth_token', 'tok-1');
      await auth.checkSession();
    });

    final addressProvider = AddressProvider(dioClient: dio);
    final settings = AppSettingsProvider(prefs);
    final cartProvider = CartProvider(dioClient: dio, enableMockFallback: true);
    await tester.runAsync(() async {
      await cartProvider.addProduct(
        const ProductModel(
          id: 'p1',
          name: 'Fresh Spinach (Palak)',
          unit: 'bunch',
          currentPrice: 20,
        ),
      );
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: addressProvider),
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: cartProvider),
        ],
        child: const MaterialApp(home: CartScreen()),
      ),
    );
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('Deliver to: Home • Pune'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
    expect(find.text('Fresh Spinach (Palak)'), findsOneWidget);
  });

  testWidgets('MapLocationScreen renders search, current location, and CTA',
      (WidgetTester tester) async {
    final storage = LocalStorageServiceImpl();
    final dio = DioClient(storageService: storage);
    dio.dio.interceptors.insert(0, _CartFlowInterceptor([]));
    final addressProvider = AddressProvider(dioClient: dio);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: addressProvider,
        child: const MaterialApp(
          home: MapLocationScreen(autoLocateOnInit: false),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('SELECT DELIVERY LOCATION'), findsOneWidget);
    expect(find.text('Search for location'), findsOneWidget);
    expect(find.text('Go to current location'), findsOneWidget);
    expect(find.text('Complete address details'), findsOneWidget);
  });
}
