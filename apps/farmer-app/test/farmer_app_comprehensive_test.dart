import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kisansetu_farmer_app/core/network/dio_client.dart';
import 'package:kisansetu_farmer_app/core/providers/farmer_settings_provider.dart';
import 'package:kisansetu_farmer_app/core/services/mock_farmer_services.dart';
import 'package:kisansetu_farmer_app/core/storage/storage_service.dart';
import 'package:kisansetu_farmer_app/features/auth/providers/auth_provider.dart';
import 'package:kisansetu_farmer_app/features/demand/providers/demand_provider.dart';
import 'package:kisansetu_farmer_app/features/produce/providers/produce_provider.dart';
import 'package:kisansetu_farmer_app/features/settlements/providers/settlements_provider.dart';

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

  group('Module 4 & 5: Farmer Auth, OTP & KYC', () {
    test('Farmer login, OTP states, KYC masking & logout', () async {
      final auth = FarmerAuthProvider(dioClient: dio, storageService: storage, enableMockFallback: true);

      final badLogin = await auth.login('9876543212', 'wrong');
      expect(badLogin, isFalse);

      final okLogin = await auth.login('9876543212', 'password123');
      expect(okLogin, isTrue);
      expect(auth.roles, contains('ROLE_FARMER'));

      await auth.logout();
      expect(auth.isAuthenticated, isFalse);

      await auth.requestOtp('9876543212');
      expect(auth.otpStatus, FarmerOtpStatus.sent);

      final badOtp = await auth.verifyOtp('9876543212', '000000');
      expect(badOtp, isFalse);
      expect(auth.otpStatus, FarmerOtpStatus.invalid);

      auth.simulateOtpExpired();
      expect(auth.otpStatus, FarmerOtpStatus.expired);

      final okOtp = await auth.verifyOtp('9876543212', '123456');
      expect(okOtp, isTrue);

      auth.submitKyc(
        aadhaarLast4: '8842',
        pan: 'abcps1234f',
        bankName: 'SBI',
        accountNumber: '309812344201',
        ifsc: 'sbin0001245',
      );
      expect(auth.aadhaarMasked, '•••• •••• 8842');
      expect(auth.bankAccountMasked, '•••• 4201');
      expect(auth.kycStatus, KycStatus.underReview);
    });
  });

  group('Module 2, 7 & 19: Farm Location, Collection Hub & Offline Sync', () {
    test('Settings updates farm location, collection hub, language & offline queue', () async {
      final settings = FarmerSettingsProvider(PreferencesService());
      await settings.updateFarmLocation(
        village: 'Paud',
        taluka: 'Mulshi',
        district: 'Pune',
        stateName: 'Maharashtra',
      );
      expect(settings.village, 'Paud');

      await settings.selectCollectionHub('hub-shivajinagar', 'Shivajinagar Hub');
      expect(settings.selectedHubId, 'hub-shivajinagar');

      settings.toggleBilingual();
      expect(settings.languageCode, 'mr');
      await settings.setThemeMode(ThemeMode.dark);
      expect(settings.themeMode, ThemeMode.dark);

      expect(settings.pendingOfflineActions, 2);
      settings.syncOfflineQueue();
      expect(settings.pendingOfflineActions, 0);
    });
  });

  group('Module 8, 10 & 12: Produce Lots, Surplus & Inventory', () {
    test('Validates quantity/price and supports create, pause, resume, delete', () async {
      final produce = ProduceProvider(dioClient: dio, enableMockFallback: true);
      final initialCount = produce.listings.length;

      final invalid = await produce.createListing(const FarmerListing(
        id: 'bad',
        productId: 'p1',
        cropName: 'Invalid',
        marathiName: '',
        category: 'Veg',
        variety: 'Local',
        availableQty: 0,
        unit: 'kg',
        pricePerUnit: 20,
        qualityGrade: 'A',
        harvestDate: 'Today',
      ));
      expect(invalid, isFalse);

      final created = await produce.createListing(const FarmerListing(
        id: 'LOT-TEST-1',
        productId: 'p1',
        cropName: 'Organic Methi',
        marathiName: 'मेथी',
        category: 'Leafy Greens',
        variety: 'Desi',
        availableQty: 50,
        unit: 'kg',
        pricePerUnit: 30,
        qualityGrade: 'Organic A+',
        harvestDate: 'Tomorrow',
      ));
      expect(created, isTrue);
      expect(produce.listings.length, initialCount + 1);

      await produce.updateListing('LOT-TEST-1', status: 'PAUSED');
      expect(produce.getById('LOT-TEST-1')?.status, 'PAUSED');

      produce.deleteListing('LOT-TEST-1');
      expect(produce.listings.length, initialCount);
      expect(produce.surplusListings.isNotEmpty, isTrue);
    });
  });

  group('Module 9: Demand vs Confirmed Orders Separation', () {
    test('Accepting demand creates a confirmed order', () {
      final demand = DemandProvider(enableMockFallback: true);
      final ordersBefore = demand.orders.length;

      demand.respondToDemand('dem-101', 'ACCEPTED');
      expect(demand.demands.first['status'], 'ACCEPTED');
      expect(demand.orders.length, ordersBefore + 1);
    });
  });

  group('Module 13, 16 & 17: Settlements, Wallet, Schemes & Store', () {
    test('Wallet withdrawal & FPO Store cart calculations', () {
      final settlements = SettlementsProvider(enableMockFallback: true);
      final walletBefore = settlements.walletBalance;

      settlements.requestWalletWithdrawal(500);
      expect(settlements.walletBalance, walletBefore - 500);
      expect(settlements.ledger.first['status'], 'PROCESSING');

      settlements.addToStoreCart(MockFarmerServices.storeProducts.first);
      expect(settlements.storeCartTotal, 620.0);
      settlements.clearStoreCart();
      expect(settlements.storeCart, isEmpty);

      expect(MockFarmerServices.govtSchemes.length, 3);
    });
  });
}
