import 'package:go_router/go_router.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/system_state_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
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
import '../../features/location/screens/map_location_screen.dart';
import '../../features/location/screens/select_location_screen.dart';
import '../../features/notifications/screens/notification_centre_screen.dart';
import '../../features/notifications/screens/notification_preferences_screen.dart';
import '../../features/notifications/screens/notification_primer_screen.dart';
import '../../features/onboarding/screens/select_language_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
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
    // Module 1: Splash -> Phone Number -> OTP Verification -> Location Selection -> Dashboard
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(
      path: '/select-language',
      builder: (_, state) =>
          SelectLanguageScreen(fromSettings: state.extra == true),
    ),
    GoRoute(
      path: '/select-location',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SelectLocationScreen(
          returnSelectionOnly: extra?['returnSelectionOnly'] == true,
        );
      },
    ),

    // Module 3: Phone OTP Authentication
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(
      path: '/otp-verify',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OtpVerificationScreen(
          phone: extra['phone'] as String? ?? '',
          countryCode: extra['countryCode'] as String? ?? '+91',
          initialCooldownSeconds: extra['cooldown'] as int? ?? 30,
        );
      },
    ),

    // 3-Item Floating Bottom Navigation Shell (Home, + Weekly Cart, Categories)
    ShellRoute(
      builder: (context, state, child) {
        final loc = state.uri.path;
        final idx = loc.startsWith('/categories')
            ? 1
            : loc.startsWith('/home')
            ? 0
            : -1;
        return AppScaffold(selectedIndex: idx, child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/categories',
          builder: (_, state) => CategoriesScreen(
            initialCategory: state.uri.queryParameters['category'],
          ),
        ),
        GoRoute(
          path: '/weekly-planner',
          builder: (_, _) => const WeeklyPlannerScreen(),
        ),
        GoRoute(path: '/orders', builder: (_, _) => const OrdersScreen()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      ],
    ),

    // Module 4: Catalog, Search, Product & Farmer Details
    GoRoute(path: '/catalog', builder: (_, _) => const CatalogFilterScreen()),
    GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
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
    GoRoute(path: '/fpo-network', builder: (_, _) => const FpoNetworkScreen()),

    // Module 5 & 6: Cart & Addresses
    GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
    GoRoute(
      path: '/addresses',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AddressesScreen(selectMode: extra?['selectMode'] == true);
      },
    ),
    GoRoute(
      path: '/map-location',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return MapLocationScreen(
          returnSelectionOnly: extra?['returnSelectionOnly'] == true,
        );
      },
    ),
    GoRoute(
      path: '/add-address',
      builder: (_, state) {
        final extra = state.extra;
        if (extra is AddressModel) {
          return AddEditAddressScreen(existingAddress: extra);
        }
        if (extra is Map<String, dynamic>) {
          return AddEditAddressScreen(
            existingAddress: extra['existingAddress'] as AddressModel?,
            initialLocation: extra['initialLocation'] as Map<String, dynamic>?,
          );
        }
        return const AddEditAddressScreen();
      },
    ),

    // Module 7: Weekly Cart Sub-screens
    GoRoute(
      path: '/weekly-planner/day/:day',
      builder: (_, state) =>
          WeeklyDayPlannerScreen(day: state.pathParameters['day']!),
    ),
    GoRoute(
      path: '/weekly-planner/submitted',
      builder: (_, _) => const WeeklySubmittedScreen(),
    ),

    // Module 8: Subscriptions
    GoRoute(
      path: '/subscriptions',
      builder: (_, _) => const SubscriptionsListScreen(),
    ),
    GoRoute(
      path: '/create-subscription',
      builder: (_, _) => const CreateSubscriptionScreen(),
    ),
    GoRoute(
      path: '/subscriptions/:id',
      builder: (_, state) => SubscriptionDetailsScreen(
        subscriptionId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/subscriptions/:id/edit',
      builder: (_, state) =>
          EditScheduleScreen(subscriptionId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/subscriptions/:id/pause',
      builder: (_, state) =>
          PauseSubscriptionScreen(subscriptionId: state.pathParameters['id']!),
    ),

    // Module 9: Checkout & Payment
    GoRoute(path: '/checkout', builder: (_, _) => const CheckoutScreen()),
    GoRoute(
      path: '/apply-coupon',
      builder: (_, _) => const ApplyCouponScreen(),
    ),
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
      builder: (_, _) => const NotificationPrimerScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, _) => const NotificationCentreScreen(),
    ),
    GoRoute(
      path: '/notification-preferences',
      builder: (_, _) => const NotificationPreferencesScreen(),
    ),

    // Module 12: Profile & Settings
    GoRoute(
      path: '/edit-profile',
      builder: (_, _) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/account-security',
      builder: (_, _) => const AccountSecurityScreen(),
    ),
    GoRoute(
      path: '/delivery-preferences',
      builder: (_, _) => const DeliveryPreferencesScreen(),
    ),
    GoRoute(
      path: '/delete-account',
      builder: (_, _) => const DeleteAccountScreen(),
    ),
    GoRoute(path: '/wallet', builder: (_, _) => const KisanWalletScreen()),
    GoRoute(
      path: '/harvest-impact',
      builder: (_, _) => const HarvestImpactScreen(),
    ),
    GoRoute(path: '/farm-visits', builder: (_, _) => const FarmVisitScreen()),

    // Module 13: Support
    GoRoute(path: '/support', builder: (_, _) => const HelpSupportScreen()),
    GoRoute(path: '/faq', builder: (_, _) => const FaqScreen()),
    GoRoute(
      path: '/raise-ticket',
      builder: (_, _) => const RaiseTicketScreen(),
    ),
    GoRoute(
      path: '/support-chat',
      builder: (_, _) => const LiveSupportChatScreen(),
    ),

    // Module 14: System & Exception States
    GoRoute(
      path: '/maintenance',
      builder: (_, _) =>
          const SystemStateScreen(type: SystemStateType.maintenance),
    ),
    GoRoute(
      path: '/session-expired',
      builder: (_, _) =>
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
