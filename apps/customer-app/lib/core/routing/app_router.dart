import 'package:go_router/go_router.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/system_state_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/catalog/screens/catalog_filter_screen.dart';
import '../../features/catalog/screens/categories_screen.dart';
import '../../features/catalog/screens/farmer_profile_screen.dart';
import '../../features/catalog/screens/fpo_network_screen.dart';
import '../../features/catalog/screens/product_detail_screen.dart';
import '../../features/catalog/screens/product_reviews_screen.dart';
import '../../features/catalog/screens/search_screen.dart';
import '../../features/checkout/screens/apply_coupon_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/checkout/screens/payment_failed_screen.dart';
import '../../features/checkout/screens/payment_processing_screen.dart';
import '../../features/checkout/screens/payment_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/location/models/address_model.dart';
import '../../features/location/screens/add_edit_address_screen.dart';
import '../../features/location/screens/addresses_screen.dart';
import '../../features/location/screens/confirm_address_tagging_screen.dart';
import '../../features/location/screens/location_permission_denied_screen.dart';
import '../../features/location/screens/location_primer_screen.dart';
import '../../features/location/screens/map_location_picker_screen.dart';
import '../../features/location/screens/select_location_screen.dart';
import '../../features/location/screens/serviceability_status_screen.dart';
import '../../features/notifications/screens/notification_centre_screen.dart';
import '../../features/notifications/screens/notification_preferences_screen.dart';
import '../../features/notifications/screens/notification_primer_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/select_language_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/orders/screens/cancel_order_screen.dart';
import '../../features/orders/screens/live_tracking_detail_screen.dart';
import '../../features/orders/screens/order_confirmed_screen.dart';
import '../../features/orders/screens/order_details_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/orders/screens/tax_invoice_screen.dart';
import '../../features/orders/screens/tracking_screen.dart';
import '../../features/profile/screens/account_security_screen.dart';
import '../../features/profile/screens/delete_account_screen.dart';
import '../../features/profile/screens/delivery_preferences_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/kisan_wallet_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/subscription/screens/create_subscription_screen.dart';
import '../../features/subscription/screens/edit_schedule_screen.dart';
import '../../features/subscription/screens/pause_subscription_screen.dart';
import '../../features/subscription/screens/subscription_details_screen.dart';
import '../../features/subscription/screens/subscriptions_list_screen.dart';
import '../../features/support/screens/faq_screen.dart';
import '../../features/support/screens/help_support_screen.dart';
import '../../features/support/screens/live_support_chat_screen.dart';
import '../../features/support/screens/raise_ticket_screen.dart';
import '../../features/weekly_cart/screens/weekly_day_planner_screen.dart';
import '../../features/weekly_cart/screens/weekly_planner_screen.dart';
import '../../features/weekly_cart/screens/weekly_submitted_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Module 1: Splash & Onboarding
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(
      path: '/select-language',
      builder: (_, state) =>
          SelectLanguageScreen(fromSettings: state.extra == true),
    ),
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (_, state) {
        final step = int.tryParse(state.uri.queryParameters['step'] ?? '0') ?? 0;
        return OnboardingScreen(initialStep: step);
      },
    ),

    // Module 2: Location & Permissions
    GoRoute(path: '/location-primer', builder: (_, __) => const LocationPrimerScreen()),
    GoRoute(
      path: '/location-permission-denied',
      builder: (_, __) => const LocationPermissionDeniedScreen(),
    ),
    GoRoute(path: '/select-location', builder: (_, __) => const SelectLocationScreen()),
    GoRoute(path: '/map-picker', builder: (_, __) => const MapLocationPickerScreen()),
    GoRoute(
      path: '/serviceability-check',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ServiceabilityStatusScreen(
          pinCode: extra['pinCode'] as String? ?? '411038',
          areaName: extra['name'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/confirm-address',
      builder: (_, state) => ConfirmAddressTaggingScreen(
        locationData: state.extra as Map<String, dynamic>? ?? {},
      ),
    ),

    // Module 3: Authentication
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: '/otp-verify',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OtpVerificationScreen(
          phone: extra['phone'] as String? ?? '9876543211',
          fromRegistration: extra['fromRegistration'] as bool? ?? false,
        );
      },
    ),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),

    // 5-Tab Main Shell (Home, Categories, Weekly Cart, Orders, Profile)
    ShellRoute(
      builder: (context, state, child) {
        final loc = state.uri.path;
        final idx = loc.startsWith('/categories')
            ? 1
            : loc.startsWith('/weekly-planner')
                ? 2
                : loc.startsWith('/orders')
                    ? 3
                    : loc.startsWith('/profile')
                        ? 4
                        : 0;
        return AppScaffold(selectedIndex: idx, child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/categories',
          builder: (_, state) => CategoriesScreen(
            initialCategory: state.uri.queryParameters['category'],
          ),
        ),
        GoRoute(
          path: '/weekly-planner',
          builder: (_, __) => const WeeklyPlannerScreen(),
        ),
        GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // Module 4: Catalog, Search, Product & Farmer Details
    GoRoute(path: '/catalog', builder: (_, __) => const CatalogFilterScreen()),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) =>
          ProductDetailScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/product/:id/reviews',
      builder: (_, state) =>
          ProductReviewsScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/farmer/:id',
      builder: (_, state) =>
          FarmerProfileScreen(farmerId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/fpo-network', builder: (_, __) => const FpoNetworkScreen()),

    // Module 5 & 6: Cart & Addresses
    GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
    GoRoute(path: '/addresses', builder: (_, __) => const AddressesScreen()),
    GoRoute(
      path: '/add-address',
      builder: (_, state) => AddEditAddressScreen(
        existingAddress: state.extra as AddressModel?,
      ),
    ),

    // Module 7: Weekly Cart Sub-screens
    GoRoute(
      path: '/weekly-planner/day/:day',
      builder: (_, state) =>
          WeeklyDayPlannerScreen(day: state.pathParameters['day']!),
    ),
    GoRoute(
      path: '/weekly-planner/submitted',
      builder: (_, __) => const WeeklySubmittedScreen(),
    ),

    // Module 8: Subscriptions
    GoRoute(
      path: '/subscriptions',
      builder: (_, __) => const SubscriptionsListScreen(),
    ),
    GoRoute(
      path: '/create-subscription',
      builder: (_, __) => const CreateSubscriptionScreen(),
    ),
    GoRoute(
      path: '/subscriptions/:id',
      builder: (_, state) => SubscriptionDetailsScreen(
        subscriptionId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/subscriptions/:id/edit',
      builder: (_, state) => EditScheduleScreen(
        subscriptionId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/subscriptions/:id/pause',
      builder: (_, state) => PauseSubscriptionScreen(
        subscriptionId: state.pathParameters['id']!,
      ),
    ),

    // Module 9: Checkout & Payment
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
    GoRoute(path: '/apply-coupon', builder: (_, __) => const ApplyCouponScreen()),
    GoRoute(
      path: '/payment',
      builder: (_, state) => PaymentScreen(
        checkoutData: state.extra as Map<String, dynamic>? ?? {},
      ),
    ),
    GoRoute(
      path: '/payment-processing',
      builder: (_, state) => PaymentProcessingScreen(
        paymentData: state.extra as Map<String, dynamic>? ?? {},
      ),
    ),
    GoRoute(
      path: '/payment-failed',
      builder: (_, state) => PaymentFailedScreen(
        paymentData: state.extra as Map<String, dynamic>? ?? {},
      ),
    ),

    // Module 10: Orders & Tracking
    GoRoute(
      path: '/order-confirmed',
      builder: (_, state) => OrderConfirmedScreen(
        confirmationData: state.extra as Map<String, dynamic>? ?? {},
      ),
    ),
    GoRoute(
      path: '/orders/:id',
      builder: (_, state) =>
          OrderDetailsScreen(orderId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/orders/:id/cancel',
      builder: (_, state) =>
          CancelOrderScreen(orderId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/orders/:id/invoice',
      builder: (_, state) =>
          TaxInvoiceScreen(orderId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/tracking/:id',
      builder: (_, state) =>
          TrackingScreen(orderId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/tracking/:id/live',
      builder: (_, state) =>
          LiveTrackingDetailScreen(orderId: state.pathParameters['id']!),
    ),

    // Module 11: Notifications
    GoRoute(
      path: '/notification-primer',
      builder: (_, __) => const NotificationPrimerScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationCentreScreen(),
    ),
    GoRoute(
      path: '/notification-preferences',
      builder: (_, __) => const NotificationPreferencesScreen(),
    ),

    // Module 12: Profile & Settings
    GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
    GoRoute(
      path: '/account-security',
      builder: (_, __) => const AccountSecurityScreen(),
    ),
    GoRoute(
      path: '/delivery-preferences',
      builder: (_, __) => const DeliveryPreferencesScreen(),
    ),
    GoRoute(path: '/delete-account', builder: (_, __) => const DeleteAccountScreen()),
    GoRoute(path: '/wallet', builder: (_, __) => const KisanWalletScreen()),
    GoRoute(path: '/harvest-impact', builder: (_, __) => const HarvestImpactScreen()),
    GoRoute(path: '/farm-visits', builder: (_, __) => const FarmVisitScreen()),

    // Module 13: Support
    GoRoute(path: '/support', builder: (_, __) => const HelpSupportScreen()),
    GoRoute(path: '/faq', builder: (_, __) => const FaqScreen()),
    GoRoute(path: '/raise-ticket', builder: (_, __) => const RaiseTicketScreen()),
    GoRoute(path: '/support-chat', builder: (_, __) => const LiveSupportChatScreen()),

    // Module 14: System & Exception States
    GoRoute(
      path: '/maintenance',
      builder: (_, __) =>
          const SystemStateScreen(type: SystemStateType.maintenance),
    ),
    GoRoute(
      path: '/session-expired',
      builder: (_, __) =>
          const SystemStateScreen(type: SystemStateType.sessionExpired),
    ),
    GoRoute(
      path: '/error/:type',
      builder: (_, state) {
        final t = state.pathParameters['type'];
        final type = t == 'no-internet'
            ? SystemStateType.noInternet
            : t == 'server'
                ? SystemStateType.serverError
                : t == 'unauthorized'
                    ? SystemStateType.unauthorized
                    : SystemStateType.generalError;
        return SystemStateScreen(type: type);
      },
    ),
  ],
);
