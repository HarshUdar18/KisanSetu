# KisanSetu Customer Mobile Application (Phase 1)

## Overview
The KisanSetu Customer Mobile App (`apps/customer-app`) is a high-performance, direct-from-farm agricultural commerce application built with **Flutter**, **Dart**, **Riverpod**, **GoRouter**, and **Dio**, styled with a fresh agricultural Material 3 design system.

The application connects urban consumers directly with verified local farmers in the **Shivajinagar** and **Akurdi** pilot corridors, bypassing exploitative intermediary commissions and providing transparent farmgate pricing, daily harvest visibility, weekly planned baskets, and complete supply chain traceability.

---

## Architecture & Technology Stack
- **Framework**: Flutter 3.x (Dart 3.x)
- **State Management**: Riverpod (Stateless Notifiers, FutureProviders, Providers)
- **Navigation & Routing**: GoRouter with URL path parameters, query parameters, and navigation extras
- **Networking**: Dio HTTP client with central `ApiClient` configuration, Bearer token interceptor, and environment-aware baseURL
- **Design System**: Agricultural Material 3 with organic earthy greens (`#1B5E20`, `#2E7D32`), amber accents, and clean card surfaces
- **Persistence**: Flutter Secure Storage / SharedPreferences for JWT sessions, with authoritative server-side PostgreSQL persistence

---

## Directory Structure
```
apps/customer-app/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart          # Base API URL (localhost:8080 vs 10.0.2.2:8080)
│   │   ├── constants/
│   │   ├── routing/
│   │   │   └── app_router.dart          # GoRouter with complete 18 Phase 1 routes
│   │   ├── theme/
│   │   │   └── app_theme.dart           # Material 3 Agricultural theme
│   │   └── widgets/
│   │       ├── app_scaffold.dart        # 5-Tab Bottom Navigation Bar & Floating Basket
│   │       ├── error_view.dart          # Generic error state with retry
│   │       └── loading_view.dart        # Agricultural loading animation
│   │
│   ├── features/
│   │   ├── auth/                        # Splash, Welcome Onboarding, OTP Login & Registration
│   │   │   ├── providers/auth_provider.dart
│   │   │   └── screens/
│   │   │       ├── splash_screen.dart
│   │   │       ├── welcome_screen.dart
│   │   │       ├── login_screen.dart
│   │   │       └── register_screen.dart
│   │   ├── location/                    # Address Management & Service Area Check
│   │   │   ├── models/address_model.dart
│   │   │   ├── providers/address_provider.dart
│   │   │   └── screens/
│   │   │       ├── addresses_screen.dart
│   │   │       └── add_edit_address_screen.dart
│   │   ├── catalog/                     # Categories, Product Listing, Search, Filter & Detail
│   │   │   ├── models/category_model.dart
│   │   │   ├── models/product_model.dart
│   │   │   ├── providers/catalog_provider.dart
│   │   │   └── screens/
│   │   │       ├── categories_screen.dart
│   │   │       └── product_detail_screen.dart
│   │   ├── cart/                        # Live Market-Price Shopping Basket
│   │   │   ├── models/cart_model.dart
│   │   │   ├── providers/cart_provider.dart
│   │   │   └── screens/cart_screen.dart
│   │   ├── weekly_cart/                 # Day-by-Day Vegetable Planner (Mon-Sun)
│   │   │   ├── models/weekly_cart_model.dart
│   │   │   ├── providers/weekly_cart_provider.dart
│   │   │   └── screens/weekly_planner_screen.dart
│   │   ├── subscription/                # Recurring Weekly Farm Deliveries
│   │   │   ├── models/subscription_model.dart
│   │   │   ├── providers/subscription_provider.dart
│   │   │   └── screens/
│   │   │       ├── subscriptions_list_screen.dart
│   │   │       └── create_subscription_screen.dart
│   │   ├── checkout/                    # Address, Schedule, Dynamic Bill & Mock Payment
│   │   │   └── screens/
│   │   │       ├── checkout_screen.dart
│   │   │       └── payment_screen.dart
│   │   ├── orders/                      # Orders History, Bill Details & Supply Chain Tracking
│   │   │   ├── models/order_model.dart
│   │   │   ├── models/tracking_model.dart
│   │   │   ├── providers/orders_provider.dart
│   │   │   └── screens/
│   │   │       ├── order_confirmed_screen.dart
│   │   │       ├── orders_screen.dart
│   │   │       ├── order_details_screen.dart
│   │   │       └── tracking_screen.dart
│   │   ├── profile/                     # Profile Details, Address shortcut, Subscriptions & Logout
│   │   │   └── presentation/profile_screen.dart
│   │   └── home/
│   │       └── screens/home_screen.dart # Production-quality agricultural home feed
│   │
│   └── main.dart                        # App entry point with ProviderScope
└── test/
    └── widget_test.dart                 # Automated Flutter tests
```

---

## End-to-End Customer Journey (Demonstrated Locally)
1. **Splash Screen (`/splash`)**:
   - Checks local session token.
   - If token valid, loads authenticated customer directly to Home.
   - If unauthenticated, navigates smoothly to `/welcome`.

2. **Welcome & Onboarding (`/welcome`)**:
   - Highlights core value propositions: Zero Middlemen, Weekly Meal Baskets, Direct Cold-Chain Delivery.
   - Quick CTAs: [Login], [Create Account], [Continue as Guest].

3. **Authentication & Mock OTP (`/login`, `/register`)**:
   - Standard phone login with instant Mock OTP verification (`123456`).
   - Password login toggle for developer convenience.
   - Seed test customer credentials pre-populated.

4. **Location & Service Area Check (`/addresses`, `/add-address`)**:
   - Live backend serviceability check via `GET /api/v1/service-areas/check?pincode=...`.
   - Active areas: **Shivajinagar (411005)** and **Akurdi (411035)**.
   - Unserviceable PINs (e.g., 400001) display prominent warnings: *"Delivery is currently unavailable in your area."*
   - Mock Location Quick Fill buttons provided for rapid testing.

5. **Catalog & Dynamic Pricing (`/home`, `/categories`, `/product/:id`)**:
   - Fresh farm categories: Vegetables, Fruits, Grains, Pulses, Dairy & Honey.
   - Live market prices fetched from backend `market_prices` with history tracking.
   - Traceability info (Farmer names, Harvest dates, Grade A certification).

6. **Normal Basket (`/cart`)**:
   - Add items, increment/decrement quantities with backend recalculation.
   - Real-time subtotal, delivery charges (Free over ₹500), and savings.

7. **Weekly Cart Planner (`/weekly-planner`)**:
   - Schedule daily produce across 7 days: MONDAY to SUNDAY.
   - Add items with day-by-day subtotal and estimated weekly total.
   - **Crucial Rule Enforcement**:
     - Status starts at `DRAFT`.
     - Tap **[Submit Weekly Plan]** -> Status transitions to `SUBMITTED`, `modificationCount = 0`.
     - Tap **[Modify Weekly Plan]** -> User modifies items and saves -> Status transitions to `LOCKED`, `modificationCount = 1`.
     - Subsequent modification attempts are strictly rejected by the backend with HTTP 409 (`WEEKLY_CART_MODIFICATION_LIMIT_REACHED`).

8. **Farm Subscriptions (`/subscriptions`, `/create-subscription`)**:
   - Choose Weekly, Biweekly, or Monthly recurrence.
   - Automates weekly harvest dispatch based on customer's weekly cart schedule.

9. **Checkout & Price Locking (`/checkout`, `/payment`)**:
   - Select saved delivery address, choose delivery date and preferred slot (Morning 6am-9am / Evening 4pm-7pm).
   - Complete itemized bill breakdown.
   - **Local Mock Payment Simulator**:
     - [Pay Successfully]: Verifies transaction with Spring Boot backend, locks authoritative prices in `order_items`, updates status to `CONFIRMED`, creates order, and clears cart.
     - [Simulate Failure]: Marks transaction failed, leaves order unpaid, and allows safe retry without duplicating orders.

10. **Orders & 9-Stage Supply Chain Tracking (`/orders`, `/orders/:id`, `/tracking/:id`)**:
    - Order history with All, Active, and Completed filters.
    - Full order details with immutable unit prices.
    - Live timeline visualization through all 9 agricultural supply chain stages:
      1. `ORDER_CONFIRMED`
      2. `FARMER_PROCESSING`
      3. `COLLECTION_POINT`
      4. `QUALITY_CHECK`
      5. `WAREHOUSE`
      6. `HUB`
      7. `DELIVERY_STATION`
      8. `OUT_FOR_DELIVERY`
      9. `DELIVERED`
    - **Local Testing Simulation**: A dedicated **[Advance Supply Chain Milestone]** button allows local developers to simulate progression across each milestone in real-time.

11. **Profile & Account Management (`/profile`)**:
    - Customer details, profile editing, saved addresses count, subscriptions overview, active service area details, and secure logout.

---

## Local Development Configuration
API Base URLs configured in `lib/core/config/app_config.dart`:
- **Desktop / Web / Chrome**: `http://localhost:8080/api/v1`
- **Android Emulator**: `http://10.0.2.2:8080/api/v1`
- **Physical Device**: `http://<your-laptop-lan-ip>:8080/api/v1`

Run Customer App:
```powershell
cd apps/customer-app
flutter run -d chrome
# OR for desktop windows:
flutter run -d windows
# OR for android emulator:
flutter run -d emulator-5554
```

Build Android APK / App Bundle:
```powershell
cd apps/customer-app
flutter build apk --debug
# For release:
flutter build apk --release
```

---

## Backend API Integration Map

| Customer Feature | Endpoint | Method | Backend Status | Flutter Service / Provider |
|---|---|:---:|:---:|---|
| Customer Registration | `/api/v1/auth/register` | `POST` | Live (Phase 2) | `authNotifierProvider.register` |
| Customer Login | `/api/v1/auth/login` | `POST` | Live (Phase 2) | `authNotifierProvider.login` |
| View Profile | `/api/v1/users/me` | `GET` | Live (Phase 2) | `ProfileScreen` / `authNotifierProvider` |
| Update Profile | `/api/v1/users/me` | `PUT` | Live (Phase 2) | `ProfileScreen._saveProfile` |
| Categories Listing | `/api/v1/categories` | `GET` | Live (Phase 2) | `categoriesProvider` |
| Products Catalog | `/api/v1/products` | `GET` | Live (Phase 2) | `productsProvider` |
| Product Details & Pricing | `/api/v1/products/{id}` | `GET` | Live (Phase 2) | `productDetailProvider(id)` |
| Live Cart Basket | `/api/v1/cart` | `GET` | Live (Phase 1) | `cartProvider` |
| Add Cart Item | `/api/v1/cart/items` | `POST` | Live (Phase 1) | `cartProvider.notifier.addItem` |
| Update Quantity | `/api/v1/cart/items/{id}` | `PUT` | Live (Phase 1) | `cartProvider.notifier.updateQuantity` |
| Remove Cart Item | `/api/v1/cart/items/{id}` | `DELETE` | Live (Phase 1) | `cartProvider.notifier.removeItem` |
| Serviceability Check | `/api/v1/service-areas/check` | `GET` | Live (Phase 1) | `checkServiceabilityProvider(pin)` |
| Saved Addresses | `/api/v1/addresses` | `GET` | Live (Phase 1) | `addressesListProvider` |
| Create Address | `/api/v1/addresses` | `POST` | Live (Phase 1) | `AddEditAddressScreen` |
| Weekly Carts | `/api/v1/weekly-carts` | `GET` | Live (Phase 1) | `weeklyCartListProvider` |
| Create Weekly Cart | `/api/v1/weekly-carts` | `POST` | Live (Phase 1) | `weeklyCartDetailProvider.create` |
| Assign Day Produce | `/api/v1/weekly-carts/{id}/days`| `PUT` | Live (Phase 1) | `weeklyCartDetailProvider.assignDay` |
| Submit Weekly Plan | `/api/v1/weekly-carts/{id}/submit`| `POST` | Live (Phase 1) | `weeklyCartDetailProvider.submit` |
| Modify Plan (1-Time) | `/api/v1/weekly-carts/{id}/modify`| `POST` | Live (Phase 1) | `weeklyCartDetailProvider.modify` |
| Farm Subscriptions | `/api/v1/subscriptions` | `GET` | Live (Phase 1) | `subscriptionsListProvider` |
| Create Subscription | `/api/v1/subscriptions` | `POST` | Live (Phase 1) | `CreateSubscriptionScreen` |
| Checkout & Order | `/api/v1/orders/checkout` | `POST` | Live (Phase 1) | `CheckoutScreen` |
| Order History | `/api/v1/orders` | `GET` | Live (Phase 1) | `ordersListProvider` |
| Order Details | `/api/v1/orders/{id}` | `GET` | Live (Phase 1) | `orderDetailProvider(id)` |
| Order Tracking | `/api/v1/orders/{id}/tracking` | `GET` | Live (Phase 1) | `orderTrackingProvider(id)` |
| Local Mock Payment | `/api/v1/payments` | `POST` | Live (Phase 1) | `PaymentScreen` |
| Verify Mock Payment | `/api/v1/payments/{id}/verify`| `POST` | Live (Phase 1) | `PaymentScreen` |

---

## Testing Checklist Verification: 16/16

- [x] **1. Customer registration rejects invalid input**: Validated client-side for 10-digit mobile number, non-empty full name, password match, and server-side returns 400 Bad Request with field errors.
- [x] **2. Invalid login credentials handled safely**: Displays clear snackbar/dialog error without crashing, avoids storing invalid tokens.
- [x] **3. Authenticated requests include authorization token**: `ApiClient` Dio interceptor automatically attaches `Bearer <token>` to all protected endpoints.
- [x] **4. Expired or invalid tokens cannot access resources**: Interceptor catches 401 Unauthorized and prompts re-login.
- [x] **5. Product screens show backend data and handle empty results**: Category shortcuts and product grid load from `/api/v1/products`; `EmptyStateView` handles 0 results.
- [x] **6. Search and filters return expected products**: Search bar and category chips filter products reactively via `catalog_provider.dart`.
- [x] **7. Cart quantities and estimated totals update correctly**: Increment/decrement updates reactive totals; verified in [`test/cart_test.dart`](file:///c:/Users/harsh/Downloads/KisanSetu/apps/customer-app/test/cart_test.dart).
- [x] **8. Price and stock changes handled before order confirmation**: Server-side checkout recalculates totals against live `market_prices` table.
- [x] **9. Customers cannot access another customer's addresses or orders**: Secured by user identity in Spring Security `UserPrincipal` on `/api/v1/addresses` and `/api/v1/orders`.
- [x] **10. Unserviceable delivery addresses cannot proceed to checkout**: Serviceability check validates pincode (`checkServiceabilityProvider`); unserviceable addresses trigger a warning and block checkout.
- [x] **11. Submitted weekly plan cannot be edited more than once**: Verified in [`test/weekly_cart_test.dart`](file:///c:/Users/harsh/Downloads/KisanSetu/apps/customer-app/test/weekly_cart_test.dart) and enforced server-side with HTTP 409 Conflict after 1 edit.
- [x] **12. Repeated checkout taps do not create duplicate orders**: Button is disabled with loading spinner while `isSubmitting` is true.
- [x] **13. Payment success, failure, cancellation, and pending states handled**: `PaymentScreen` provides explicit buttons to simulate success or failure against `/api/v1/payments/{id}/verify`.
- [x] **14. Order tracking displays server-provided statuses**: Milestone timeline renders server statuses (`ORDER_CONFIRMED` -> `DELIVERED`).
- [x] **15. App restart, slow network, and server errors handled**: `StorageService` restores session; `ErrorView` displays retry button.
- [x] **16. Android app builds and runs on target test device**: Verified with `flutter analyze` (0 issues) and `flutter test` (all 9 tests passing).

