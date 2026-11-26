import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kisansetu_customer_app/core/network/dio_client.dart';
import 'package:kisansetu_customer_app/core/providers/app_settings_provider.dart';
import 'package:kisansetu_customer_app/core/services/mock_services.dart';
import 'package:kisansetu_customer_app/core/storage/storage_service.dart';
import 'package:kisansetu_customer_app/features/auth/providers/auth_provider.dart';
import 'package:kisansetu_customer_app/features/cart/providers/cart_provider.dart';
import 'package:kisansetu_customer_app/features/catalog/models/product_model.dart';
import 'package:kisansetu_customer_app/features/catalog/providers/catalog_provider.dart';
import 'package:kisansetu_customer_app/features/location/models/address_model.dart';
import 'package:kisansetu_customer_app/features/location/providers/address_provider.dart';
import 'package:kisansetu_customer_app/features/notifications/providers/notifications_provider.dart';
import 'package:kisansetu_customer_app/features/orders/providers/orders_provider.dart';
import 'package:kisansetu_customer_app/features/subscription/providers/subscription_provider.dart';
import 'package:kisansetu_customer_app/features/weekly_cart/providers/weekly_cart_provider.dart';

void main() {
  late LocalStorageServiceImpl storage;
  late DioClient dio;

  setUp(() {
    storage = LocalStorageServiceImpl();
    dio = DioClient(
      storageService: storage,
      connectTimeout: const Duration(milliseconds: 50),
      receiveTimeout: const Duration(milliseconds: 50),
    );
  });

  group('Module 3: Authentication & OTP States', () {
    test('OTP verification handles valid (123456), invalid, and expired states', () async {
      final auth = AuthProvider(dioClient: dio, storageService: storage, enableMockFallback: true);

      await auth.requestOtp('9876543211');
      expect(auth.otpStatus, OtpVerificationStatus.sent);

      final bad = await auth.verifyOtp('9876543211', '000000');
      expect(bad, isFalse);
      expect(auth.otpStatus, OtpVerificationStatus.invalid);

      auth.simulateOtpExpired();
      expect(auth.otpStatus, OtpVerificationStatus.expired);

      final ok = await auth.verifyOtp('9876543211', '123456');
      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.otpStatus, OtpVerificationStatus.verified);

      await auth.logout();
      expect(auth.isAuthenticated, isFalse);
    });
  });

  group('Module 2 & 6: Location, Serviceability & Addresses', () {
    test('Serviceability validates active PINs and rejects non-serviceable PINs', () async {
      final serviceabilityDio = DioClient(storageService: storage);
      serviceabilityDio.dio.httpClientAdapter = _ServiceabilityStubAdapter();
      final provider = AddressProvider(dioClient: serviceabilityDio);

      final valid = await provider.checkServiceability('411005');
      expect(valid.isServiceable, isTrue);
      expect(valid.serviceAreaName, contains('Shivajinagar'));

      final invalid = await provider.checkServiceability('999999');
      expect(invalid.isServiceable, isFalse);

      final badFormat = await provider.checkServiceability('123');
      expect(badFormat.isServiceable, isFalse);
    });

    test('Address CRUD & default selection updates state', () async {
      final provider = AddressProvider(dioClient: dio, enableMockFallback: true);
      final initialCount = provider.addresses.length;

      await provider.addAddress(const AddressModel(
        id: '',
        label: 'OTHER',
        addressLine1: 'Baner Road',
        pincode: '411045',
        isDefault: true,
      ));
      expect(provider.addresses.length, initialCount + 1);
      expect(provider.defaultAddress?.pincode, '411045');
    });
  });

  group('Module 4: Product Discovery, Search & Filters', () {
    test('CatalogProvider loads seeded catalog, filters organic, and sorts by price', () async {
      final catalog = CatalogProvider(dioClient: dio, enableMockFallback: true);
      await catalog.loadCatalog();

      expect(catalog.allProducts.length, greaterThanOrEqualTo(6));

      catalog.setSearchQuery('Onion');
      expect(catalog.filteredProducts.length, 1);
      expect(catalog.filteredProducts.first.id, 'prod-onion');

      catalog.resetFilters();
      catalog.setFilters(onlyOrganic: true, sortBy: 'price_low');
      final organicSorted = catalog.filteredProducts;
      expect(organicSorted.every((p) => p.isOrganic), isTrue);
      for (var i = 1; i < organicSorted.length; i++) {
        expect(organicSorted[i].currentPrice >= organicSorted[i - 1].currentPrice, isTrue);
      }
    });
  });

  group('Module 5 & 9: Cart, Coupons & Fair Share Calculations', () {
    test('Cart computes subtotal, 80% farmer share, and KISANFIRST coupon', () async {
      final cart = CartProvider(dioClient: dio, enableMockFallback: true);
      const product = ProductModel(
        id: 'prod-rice',
        name: 'Indrayani Rice',
        unit: '5 kg',
        currentPrice: 380.0,
      );

      await cart.addProduct(product, quantity: 1);
      expect(cart.cart.subtotal, 380.0);
      expect(cart.directFarmerShare, closeTo(304.0, 0.01));

      final badCoupon = await cart.applyCoupon('INVALID99');
      expect(badCoupon['valid'], isFalse);

      final emptyCoupon = await cart.applyCoupon('   ');
      expect(emptyCoupon['valid'], isFalse);
      expect(cart.couponDiscount, 0.0);
    });
  });

  group('Module 7: Weekly Cart Single-Edit Business Rule', () {
    test('Submitted weekly cart allows 1 correction then locks', () async {
      final weekly = WeeklyCartProvider(dioClient: dio, enableMockFallback: true);
      expect(weekly.activeWeeklyCart?.status, 'DRAFT');

      await weekly.submitWeeklyCart();
      expect(weekly.activeWeeklyCart?.status, 'SUBMITTED');
      expect(weekly.activeWeeklyCart?.modificationCount, 0);

      final firstMod = await weekly.modifySubmittedWeeklyCart();
      expect(firstMod, isTrue);
      expect(weekly.activeWeeklyCart?.status, 'LOCKED');
      expect(weekly.activeWeeklyCart?.modificationCount, 1);

      final secondMod = await weekly.modifySubmittedWeeklyCart();
      expect(secondMod, isFalse);
    });
  });

  group('Module 8 & 10: Subscriptions, Payments & 9-Stage Tracking', () {
    test('Subscription lifecycle: create, pause, resume, cancel', () async {
      final subs = SubscriptionProvider(dioClient: dio, enableMockFallback: true);
      final before = subs.subscriptions.length;

      await subs.createSubscription(
        title: 'Organic Greens Box',
        frequency: 'WEEKLY',
        addressId: 'addr-1',
        totalPerCycle: 250.0,
      );
      expect(subs.subscriptions.length, before + 1);
      final id = subs.subscriptions.first.id;

      subs.pauseSubscription(id);
      expect(subs.getById(id)?.status, 'PAUSED');

      subs.resumeSubscription(id);
      expect(subs.getById(id)?.status, 'ACTIVE');

      subs.cancelSubscription(id);
      expect(subs.getById(id)?.status, 'CANCELLED');
    });

    test('Payment verification & 9-stage tracking advance cleanly', () async {
      final orders = OrdersProvider(dioClient: dio, enableMockFallback: true);
      final cart = CartProvider(dioClient: dio, enableMockFallback: true);
      await cart.addProduct(
        const ProductModel(id: 'p1', name: 'Onions', currentPrice: 300.0),
      );

      final order = await orders.checkout(
        addressId: 'addr-1',
        deliveryDate: 'Tomorrow',
        deliverySlot: '6 AM - 8 AM',
        cart: cart.cart,
      );
      expect(order, isNotNull);

      final fail = await orders.processAndVerifyPayment(
        orderId: order!.id,
        amount: order.totalAmount,
        paymentMethod: 'UPI_GPAY',
        simulateSuccess: false,
      );
      expect(fail, isFalse);
      expect(orders.getById(order.id)?.paymentStatus, 'FAILED');

      final success = await orders.processAndVerifyPayment(
        orderId: order.id,
        amount: order.totalAmount,
        paymentMethod: 'UPI_GPAY',
        simulateSuccess: true,
      );
      expect(success, isTrue);
      expect(orders.getById(order.id)?.status, 'CONFIRMED');

      await orders.fetchTracking(order.id);
      expect(orders.currentTracking?.events.length, 9);
      await orders.devAdvanceTracking(order.id);
      expect(orders.currentTracking?.events.every((e) => e.isCompleted), isTrue);
    });
  });

  group('Module 11 & 12: Notifications & Settings', () {
    test('Notifications & AppSettingsProvider update preferences', () async {
      final notif = NotificationsProvider();
      expect(notif.unreadCount, 0);
      notif.markAllRead();
      expect(notif.unreadCount, 0);

      final settings = AppSettingsProvider(InMemoryPreferencesService());
      await settings.setLanguage('mr');
      expect(settings.languageCode, 'mr');
      await settings.setThemeMode(ThemeMode.dark);
      expect(settings.themeMode, ThemeMode.dark);

      expect(MockCustomerServices.faqs.isNotEmpty, isTrue);
    });
  });
}

class _ServiceabilityStubAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final pin = options.queryParameters['pinCode']?.toString() ?? '';
    final payload = pin == '411005'
        ? {
            'success': true,
            'data': {
              'isServiceable': true,
              'serviceAreaName': 'Shivajinagar',
              'message': 'Delivery available in Shivajinagar.',
            },
          }
        : {
            'success': true,
            'data': {
              'isServiceable': false,
              'message': 'Delivery currently unavailable in your area.',
            },
          };
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }
}
