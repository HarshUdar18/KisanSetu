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
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(
      path: '/select-language',
      builder: (_, state) =>
          SelectLanguageScreen(fromSettings: state.extra == true),
    ),
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

    // Module 2: Location & Collection Points
    GoRoute(
        path: '/location-primer',
        builder: (_, __) => const LocationPrimerScreen()),
    GoRoute(
        path: '/location-permission-denied',
        builder: (_, __) => const LocationPermissionDeniedScreen()),
    GoRoute(
        path: '/select-farm-location',
        builder: (_, __) => const SelectFarmLocationScreen()),
    GoRoute(
        path: '/farm-map-picker',
        builder: (_, __) => const FarmMapPickerScreen()),
    GoRoute(
        path: '/collection-points',
        builder: (_, __) => const CollectionPointsScreen()),

    // Module 3: Notifications
    GoRoute(
        path: '/notification-primer',
        builder: (_, __) => const NotificationPrimerScreen()),
    GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationCentreScreen()),
    GoRoute(
        path: '/notification-preferences',
        builder: (_, __) => const NotificationPreferencesScreen()),

    // Module 4: Authentication
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
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
        builder: (_, __) => const ForgotPasswordScreen()),

    // Module 5: Farmer KYC
    GoRoute(path: '/kyc', builder: (_, __) => const KycIdentityScreen()),
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
        builder: (_, __) => const KycCertificateScreen()),

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
            builder: (_, __) => const FarmerDashboardScreen()),
        GoRoute(path: '/produce', builder: (_, __) => const MyProduceScreen()),
        GoRoute(
            path: '/demand', builder: (_, __) => const MarketDemandScreen()),
        GoRoute(
            path: '/settlements',
            builder: (_, __) => const WeeklySettlementsScreen()),
        GoRoute(
            path: '/profile', builder: (_, __) => const FarmerProfileScreen()),
      ],
    ),

    // Module 7: Profile & Farm Management
    GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
    GoRoute(path: '/farm-plots', builder: (_, __) => const FarmPlotsScreen()),
    GoRoute(
        path: '/fpo-affiliation',
        builder: (_, __) => const FpoAffiliationScreen()),

    // Module 8: Produce Management
    GoRoute(
        path: '/produce/add-category',
        builder: (_, __) => const AddProduceCategoryScreen()),
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
        builder: (_, __) => const SowingScheduleScreen()),

    // Module 9: Demand & Mandi
    GoRoute(
      path: '/demand/escrow/:id',
      builder: (_, state) =>
          BulkEscrowScreen(demandId: state.pathParameters['id']!),
    ),
    GoRoute(
        path: '/mandi-rates', builder: (_, __) => const MandiSpotRatesScreen()),
    GoRoute(
        path: '/mandi-compare', builder: (_, __) => const MandiCompareScreen()),

    // Module 10 & 12: Surplus & Inventory
    GoRoute(path: '/surplus', builder: (_, __) => const SurplusScreen()),
    GoRoute(path: '/surplus/add', builder: (_, __) => const AddSurplusScreen()),
    GoRoute(path: '/inventory', builder: (_, __) => const InventoryScreen()),

    // Module 11: Collection, QC & Cold-Chain Logistics
    GoRoute(
        path: '/collection',
        builder: (_, __) => const CollectionDashboardScreen()),
    GoRoute(
        path: '/collection/gate-pass', builder: (_, __) => const GatePassScreen()),
    GoRoute(
        path: '/collection/handover',
        builder: (_, __) => const FarmgateHandoverScreen()),
    GoRoute(
        path: '/collection/weighbridge',
        builder: (_, __) => const WeighbridgeSlipScreen()),
    GoRoute(path: '/qc/assay', builder: (_, __) => const ApmcAssayScreen()),
    GoRoute(path: '/qc/dispute', builder: (_, __) => const QcDisputeScreen()),
    GoRoute(
        path: '/logistics',
        builder: (_, __) => const ColdChainLogisticsScreen()),
    GoRoute(
        path: '/logistics/gps',
        builder: (_, __) => const TransporterGpsScreen()),
    GoRoute(
        path: '/logistics/telemetry',
        builder: (_, __) => const TelemetryScreen()),

    // Module 13: Settlements, Wallet & Finance
    GoRoute(
        path: '/settlements/passbook',
        builder: (_, __) => const PassbookStatementsScreen()),
    GoRoute(
        path: '/settlements/dbt-ledger',
        builder: (_, __) => const DbtEscrowLedgerScreen()),
    GoRoute(path: '/wallet', builder: (_, __) => const KisanWalletScreen()),
    GoRoute(
        path: '/wallet/withdraw',
        builder: (_, __) => const BankWithdrawalScreen()),
    GoRoute(
        path: '/finance/invoice',
        builder: (_, __) => const FarmerTaxInvoiceScreen()),
    GoRoute(
        path: '/finance/balance-sheet',
        builder: (_, __) => const BalanceSheetScreen()),
    GoRoute(
        path: '/finance/crop-profit',
        builder: (_, __) => const CropProfitScreen()),

    // Module 14 & 15: AI Advisory & Weather
    GoRoute(
        path: '/advisory',
        builder: (_, __) => const AdvisoryDashboardScreen()),
    GoRoute(
        path: '/advisory/voice-ai',
        builder: (_, __) => const VoiceAiAssistantScreen()),
    GoRoute(
        path: '/advisory/price-forecast',
        builder: (_, __) => const PriceForecastScreen()),
    GoRoute(
        path: '/advisory/drone-map',
        builder: (_, __) => const DroneScoutingScreen()),
    GoRoute(
        path: '/advisory/pest-alerts',
        builder: (_, __) => const PestAlertsScreen()),
    GoRoute(
        path: '/advisory/ask-agronomist',
        builder: (_, __) => const AskAgronomistScreen()),
    GoRoute(
        path: '/community', builder: (_, __) => const CommunityForumScreen()),
    GoRoute(path: '/weather', builder: (_, __) => const WeatherScreen()),

    // Module 16: Government Schemes
    GoRoute(
        path: '/schemes', builder: (_, __) => const SchemesDashboardScreen()),
    GoRoute(
        path: '/schemes/pm-kisan',
        builder: (_, __) => const PmKisanTrackerScreen()),
    GoRoute(
        path: '/schemes/pmfby',
        builder: (_, __) => const PmfbyInsuranceScreen()),
    GoRoute(
        path: '/schemes/kcc', builder: (_, __) => const KccTrackerScreen()),

    // Module 17: Farmer Store
    GoRoute(path: '/store', builder: (_, __) => const FarmerStoreScreen()),
    GoRoute(
        path: '/store/bio-fertilizer',
        builder: (_, __) => const BioFertilizerScreen()),
    GoRoute(
        path: '/store/group-pool', builder: (_, __) => const GroupPoolScreen()),
    GoRoute(
        path: '/store/checkout',
        builder: (_, __) => const StoreCheckoutScreen()),
    GoRoute(
        path: '/store/chc', builder: (_, __) => const ChcMachineryScreen()),

    // Module 18: Settings & Support
    GoRoute(
        path: '/settings', builder: (_, __) => const FarmerSettingsScreen()),
    GoRoute(path: '/support', builder: (_, __) => const FarmerSupportScreen()),
    GoRoute(
        path: '/knowledge-hub',
        builder: (_, __) => const KnowledgeHubScreen()),

    // Module 19: System & Offline States
    GoRoute(
        path: '/offline-sync',
        builder: (_, __) => const OfflineSyncVaultScreen()),
    GoRoute(
      path: '/kyc-restricted',
      builder: (_, __) => const FarmerSystemStateScreen(
        type: FarmerSystemStateType.kycRestricted,
      ),
    ),
    GoRoute(
      path: '/maintenance',
      builder: (_, __) => const FarmerSystemStateScreen(
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
