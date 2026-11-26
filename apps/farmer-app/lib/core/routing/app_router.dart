import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/farmer_scaffold.dart';
import '../widgets/system_state_screen.dart';
import '../../features/advisory/screens/advisory_and_weather_screens.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/auth_screens.dart';
import '../../features/collection/screens/collection_screens.dart';
import '../../features/dashboard/screens/farmer_dashboard_screen.dart';
import '../../features/demand/screens/demand_screens.dart';
import '../../features/kyc/screens/kyc_screens.dart';
import '../../features/location/screens/location_screens.dart';
import '../../features/notifications/screens/notification_screens.dart';
import '../../features/onboarding/screens/onboarding_flow_screens.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/produce/screens/produce_screens.dart';
import '../../features/profile/screens/profile_screens.dart';
import '../../features/schemes/screens/schemes_screens.dart';
import '../../features/settlements/screens/settlements_screens.dart';
import '../../features/store/screens/store_screens.dart';
import '../../features/support/screens/settings_and_support_screens.dart';
import '../../features/surplus/screens/surplus_and_inventory_screens.dart';

const _publicRoutes = {
  '/splash',
  '/select-language',
  '/welcome',
  '/onboarding',
  '/location-primer',
  '/location-permission-denied',
  '/select-farm-location',
  '/farm-map-picker',
  '/collection-points',
  '/login',
  '/register',
  '/otp-verify',
  '/forgot-password',
};

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final loc = state.uri.path;
    if (_publicRoutes.contains(loc)) return null;
    final auth = context.read<FarmerAuthProvider>();
    if (!auth.isAuthenticated) {
      return '/login';
    }
    return null;
  },
  routes: [
    // Module 1: Splash & Onboarding
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(
      path: '/select-language',
      builder: (_, state) =>
          SelectLanguageScreen(fromSettings: state.extra == true),
    ),
    GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),

    // Module 2: Location & Collection Points
    GoRoute(
        path: '/location-primer',
        builder: (_, _) => const LocationPrimerScreen()),
    GoRoute(
        path: '/location-permission-denied',
        builder: (_, _) => const LocationPermissionDeniedScreen()),
    GoRoute(
        path: '/select-farm-location',
        builder: (_, _) => const SelectFarmLocationScreen()),
    GoRoute(
        path: '/farm-map-picker',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return FarmMapPickerScreen(
            autoDetect: extra?['autoDetect'] as bool? ?? true,
          );
        }),
    GoRoute(
        path: '/collection-points',
        builder: (_, _) => const CollectionPointsScreen()),

    // Module 3: Notifications
    GoRoute(
        path: '/notification-primer',
        builder: (_, _) => const NotificationPrimerScreen()),
    GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationCentreScreen()),
    GoRoute(
        path: '/notification-preferences',
        builder: (_, _) => const NotificationPreferencesScreen()),

    // Module 4: Authentication
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
    GoRoute(
      path: '/otp-verify',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OtpVerificationScreen(
          phone: extra['phone'] as String? ?? '9876543212',
          fromRegistration: extra['fromRegistration'] as bool? ?? false,
        );
      },
    ),
    GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen()),

    // Module 5: Farmer KYC
    GoRoute(path: '/kyc', builder: (_, _) => const KycIdentityScreen()),
    GoRoute(
      path: '/kyc/land-records',
      builder: (_, state) => LandRecordScreen(
        kycData: state.extra as Map<String, dynamic>? ?? {},
      ),
    ),
    GoRoute(
      path: '/kyc/bank-dbt',
      builder: (_, state) => BankDbtScreen(
        kycData: state.extra as Map<String, dynamic>? ?? {},
      ),
    ),
    GoRoute(
        path: '/kyc/certificate',
        builder: (_, _) => const KycCertificateScreen()),

    // 5-Tab Primary Farmer Shell
    ShellRoute(
      builder: (context, state, child) {
        final p = state.uri.path;
        final idx = p.startsWith('/produce')
            ? 1
            : p.startsWith('/demand')
                ? 2
                : p.startsWith('/settlements')
                    ? 3
                    : p.startsWith('/profile')
                        ? 4
                        : 0;
        return FarmerScaffold(selectedIndex: idx, child: child);
      },
      routes: [
        GoRoute(
            path: '/dashboard',
            builder: (_, _) => const FarmerDashboardScreen()),
        GoRoute(path: '/produce', builder: (_, _) => const MyProduceScreen()),
        GoRoute(
            path: '/demand', builder: (_, _) => const MarketDemandScreen()),
        GoRoute(
            path: '/settlements',
            builder: (_, _) => const WeeklySettlementsScreen()),
        GoRoute(
            path: '/profile', builder: (_, _) => const FarmerProfileScreen()),
      ],
    ),

    // Module 7: Profile & Farm Management
    GoRoute(path: '/edit-profile', builder: (_, _) => const EditProfileScreen()),
    GoRoute(path: '/farm-plots', builder: (_, _) => const FarmPlotsScreen()),
    GoRoute(
        path: '/fpo-affiliation',
        builder: (_, _) => const FpoAffiliationScreen()),

    // Module 8: Produce Management
    GoRoute(
        path: '/produce/add-category',
        builder: (_, _) => const AddProduceCategoryScreen()),
    GoRoute(
      path: '/produce/add-details',
      builder: (_, state) => AddProduceDetailsScreen(
        data: state.extra as Map<String, dynamic>? ?? {},
      ),
    ),
    GoRoute(
      path: '/produce/lot/:id',
      builder: (_, state) =>
          ProduceLotQrScreen(lotId: state.pathParameters['id']!),
    ),
    GoRoute(
        path: '/produce/sowing-schedule',
        builder: (_, _) => const SowingScheduleScreen()),

    // Module 9: Demand & Mandi
    GoRoute(
      path: '/demand/escrow/:id',
      builder: (_, state) =>
          BulkEscrowScreen(demandId: state.pathParameters['id']!),
    ),
    GoRoute(
        path: '/mandi-rates', builder: (_, _) => const MandiSpotRatesScreen()),
    GoRoute(
        path: '/mandi-compare', builder: (_, _) => const MandiCompareScreen()),

    // Module 10 & 12: Surplus & Inventory
    GoRoute(path: '/surplus', builder: (_, _) => const SurplusScreen()),
    GoRoute(path: '/surplus/add', builder: (_, _) => const AddSurplusScreen()),
    GoRoute(path: '/inventory', builder: (_, _) => const InventoryScreen()),

    // Module 11: Collection, QC & Cold-Chain Logistics
    GoRoute(
        path: '/collection',
        builder: (_, _) => const CollectionDashboardScreen()),
    GoRoute(
        path: '/collection/gate-pass', builder: (_, _) => const GatePassScreen()),
    GoRoute(
        path: '/collection/handover',
        builder: (_, _) => const FarmgateHandoverScreen()),
    GoRoute(
        path: '/collection/weighbridge',
        builder: (_, _) => const WeighbridgeSlipScreen()),
    GoRoute(path: '/qc/assay', builder: (_, _) => const ApmcAssayScreen()),
    GoRoute(path: '/qc/dispute', builder: (_, _) => const QcDisputeScreen()),
    GoRoute(
        path: '/logistics',
        builder: (_, _) => const ColdChainLogisticsScreen()),
    GoRoute(
        path: '/logistics/gps',
        builder: (_, _) => const TransporterGpsScreen()),
    GoRoute(
        path: '/logistics/telemetry',
        builder: (_, _) => const TelemetryScreen()),

    // Module 13: Settlements, Wallet & Finance
    GoRoute(
        path: '/settlements/passbook',
        builder: (_, _) => const PassbookStatementsScreen()),
    GoRoute(
        path: '/settlements/dbt-ledger',
        builder: (_, _) => const DbtEscrowLedgerScreen()),
    GoRoute(path: '/wallet', builder: (_, _) => const KisanWalletScreen()),
    GoRoute(
        path: '/wallet/withdraw',
        builder: (_, _) => const BankWithdrawalScreen()),
    GoRoute(
        path: '/finance/invoice',
        builder: (_, _) => const FarmerTaxInvoiceScreen()),
    GoRoute(
        path: '/finance/balance-sheet',
        builder: (_, _) => const BalanceSheetScreen()),
    GoRoute(
        path: '/finance/crop-profit',
        builder: (_, _) => const CropProfitScreen()),

    // Module 14 & 15: AI Advisory & Weather
    GoRoute(
        path: '/advisory',
        builder: (_, _) => const AdvisoryDashboardScreen()),
    GoRoute(
        path: '/advisory/voice-ai',
        builder: (_, _) => const VoiceAiAssistantScreen()),
    GoRoute(
        path: '/advisory/price-forecast',
        builder: (_, _) => const PriceForecastScreen()),
    GoRoute(
        path: '/advisory/drone-map',
        builder: (_, _) => const DroneScoutingScreen()),
    GoRoute(
        path: '/advisory/pest-alerts',
        builder: (_, _) => const PestAlertsScreen()),
    GoRoute(
        path: '/advisory/ask-agronomist',
        builder: (_, _) => const AskAgronomistScreen()),
    GoRoute(
        path: '/community', builder: (_, _) => const CommunityForumScreen()),
    GoRoute(path: '/weather', builder: (_, _) => const WeatherScreen()),

    // Module 16: Government Schemes
    GoRoute(
        path: '/schemes', builder: (_, _) => const SchemesDashboardScreen()),
    GoRoute(
        path: '/schemes/pm-kisan',
        builder: (_, _) => const PmKisanTrackerScreen()),
    GoRoute(
        path: '/schemes/pmfby',
        builder: (_, _) => const PmfbyInsuranceScreen()),
    GoRoute(
        path: '/schemes/kcc', builder: (_, _) => const KccTrackerScreen()),

    // Module 17: Farmer Store
    GoRoute(path: '/store', builder: (_, _) => const FarmerStoreScreen()),
    GoRoute(
        path: '/store/bio-fertilizer',
        builder: (_, _) => const BioFertilizerScreen()),
    GoRoute(
        path: '/store/group-pool', builder: (_, _) => const GroupPoolScreen()),
    GoRoute(
        path: '/store/checkout',
        builder: (_, _) => const StoreCheckoutScreen()),
    GoRoute(
        path: '/store/chc', builder: (_, _) => const ChcMachineryScreen()),

    // Module 18: Settings & Support
    GoRoute(
        path: '/settings', builder: (_, _) => const FarmerSettingsScreen()),
    GoRoute(path: '/support', builder: (_, _) => const FarmerSupportScreen()),
    GoRoute(
        path: '/knowledge-hub',
        builder: (_, _) => const KnowledgeHubScreen()),

    // Module 19: System & Offline States
    GoRoute(
        path: '/offline-sync',
        builder: (_, _) => const OfflineSyncVaultScreen()),
    GoRoute(
      path: '/kyc-restricted',
      builder: (_, _) => const FarmerSystemStateScreen(
        type: FarmerSystemStateType.kycRestricted,
      ),
    ),
    GoRoute(
      path: '/maintenance',
      builder: (_, _) => const FarmerSystemStateScreen(
        type: FarmerSystemStateType.maintenance,
      ),
    ),
    GoRoute(
      path: '/error/:type',
      builder: (_, state) => FarmerSystemStateScreen(
        type: state.pathParameters['type'] == 'session'
            ? FarmerSystemStateType.sessionExpired
            : FarmerSystemStateType.serverError,
      ),
    ),
  ],
);
