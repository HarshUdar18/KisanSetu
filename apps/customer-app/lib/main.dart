import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/providers/app_settings_provider.dart';
import 'core/routing/app_router.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/catalog/providers/catalog_provider.dart';
import 'features/location/providers/address_provider.dart';
import 'features/notifications/providers/notifications_provider.dart';
import 'features/orders/providers/orders_provider.dart';
import 'features/subscription/providers/subscription_provider.dart';
import 'features/weekly_cart/providers/weekly_cart_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KisanSetuCustomerApp());
}

class KisanSetuCustomerApp extends StatelessWidget {
  final SecureStorageService? storageService;
  final PreferencesService? preferencesService;

  const KisanSetuCustomerApp({
    super.key,
    this.storageService,
    this.preferencesService,
  });

  @override
  Widget build(BuildContext context) {
    final storage = storageService ?? FlutterSecureStorageImpl();
    final prefs = preferencesService ?? PreferencesService();
    final dioClient = DioClient(storageService: storage);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppSettingsProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            dioClient: dioClient,
            storageService: storage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AddressProvider(dioClient: dioClient),
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(dioClient: dioClient),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(dioClient: dioClient),
        ),
        ChangeNotifierProvider(
          create: (_) => WeeklyCartProvider(dioClient: dioClient),
        ),
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(dioClient: dioClient),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(dioClient: dioClient),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationsProvider(dioClient: dioClient),
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'Kisan Setu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
