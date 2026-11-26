import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/providers/farmer_settings_provider.dart';
import 'core/routing/app_router.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/demand/providers/demand_provider.dart';
import 'features/produce/providers/produce_provider.dart';
import 'features/settlements/providers/settlements_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KisanSetuFarmerApp());
}

class KisanSetuFarmerApp extends StatelessWidget {
  const KisanSetuFarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = FlutterSecureStorageImpl();
    final preferencesService = PreferencesService();
    final dioClient = DioClient(storageService: storageService);

    return MultiProvider(
      providers: [
        Provider<DioClient>.value(value: dioClient),
        ChangeNotifierProvider(
          create: (_) => FarmerSettingsProvider(preferencesService),
        ),
        ChangeNotifierProvider(
          create: (_) => FarmerAuthProvider(
            dioClient: dioClient,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProduceProvider(dioClient: dioClient),
        ),
        ChangeNotifierProvider(
          create: (_) => DemandProvider(dioClient: dioClient),
        ),
        ChangeNotifierProvider(
          create: (_) => SettlementsProvider(dioClient: dioClient),
        ),
      ],
      child: Consumer<FarmerSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'Kisan Setu Farmer',
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
