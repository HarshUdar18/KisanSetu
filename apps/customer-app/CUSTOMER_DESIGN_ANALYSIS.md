# Kisan Setu — Customer Design Analysis

> **Primary Source of Truth**: `customer_side/stitch_kisan_setu_mobile_app/` (74 screen designs + `kisan_setu/DESIGN.md`)

## 1. Executive Summary
The Google Stitch Customer App design for **Kisan Setu** defines a high-trust, warm-agrarian Material Design 3 mobile application tailored for direct farm-to-consumer (F2C) and FPO-to-consumer agricultural commerce. Every screen is built for high outdoor/indoor legibility, minimum 48×48dp touch targets, transparent farmer-direct pricing, and real-time 9-stage harvest-to-doorstep traceability.

## 2. Shell & Layout Architecture
Inspection of the 74 Stitch `code.html` files reveals three distinct shell archetypes (`<meta name="shell-type">`):

1. **`mobile_blank` (11 screens)**
   - Used for Splash, Welcome, Language Selection, 3 Onboarding slides, Login, Registration, OTP Verification, OTP Incorrect/Expired, Forgot Password, and Maintenance.
   - Full-bleed `SafeArea` canvas (`#005128` for Splash, `#F2FCF2` for all others) without top app bar or bottom navigation.
2. **`mobile_tab` (10 screens)**
   - Used for top-level destinations: `home_dashboard`, `product_categories`, `product_loading_skeleton`, `weekly_cart_planner`, `my_orders`, `order_tracking_overview`, `subscription_overview`, `fpo_farmer_network_chronicles`, `customer_profile`, `empty_cart`.
   - Features:
     - **Sticky Top Header (`h-16` / 64dp)**: Kisan Setu brand mark, clickable Delivery Location pill (`Deliver to: Kothrud, Pune 411038`), Search button, Cart icon with Harvest Gold badge count, and circular Profile avatar.
     - **5-Tab Bottom Navigation Bar**: `Home`, `Categories`, `Weekly Cart`, `Orders`, `Profile` with `primary` (`#005128`) active indicator and `on-surface-variant` (`#3F4940`) inactive state.
3. **`mobile_stack` (53 screens)**
   - Used for all drill-down, modal, checkout, payment, address, tracking, settings, support, and exception screens.
   - Features a 64dp top app bar with a `48×48dp` back arrow, screen title (`headline-sm`), optional trailing action (help/search/avatar), and `SafeArea` sticky bottom action bar where applicable (Cart, Checkout, Payment, Weekly Day Planner, Product Details).

## 3. Visual & UX Patterns Observed
- **Surface Hierarchy**:
  - Canvas background: `#F2FCF2` (soft sage-mint off-white).
  - Elevated cards: `#FFFFFF` (`surface-container-lowest`) with `12px`–`16px` border radius and subtle green-tinted ambient shadow (`0px 2px 6px rgba(20, 40, 25, 0.04)`).
  - Tonal containers: `#ECF6EC` (`surface-container-low`), `#E6F1E7` (`surface-container`), `#E1EBE1` (`surface-container-high`).
- **Agrarian Trust Signals**:
  - Freshness badges (`Harvested 4h ago`, `Picked Today`, `Grade A Certified`) in `#FFDF95` / `#8FF9AA` pills.
  - **Direct Fair Share Impact** bar in Shopping Cart & Checkout showing exact percentage going to FPOs/Farmers (e.g., 80% Farmer Share, 14% Logistics, 6% Bio Pack).
  - **Voice Search (`mic`)** inside search bars for vernacular accessibility.
  - **Marathi / Hindi / English** multilingual support (`select_language_screen`, product names like `Desi Red Onions (कांदा)`).
- **Empty, Loading & Error States**:
  - Dedicated Stitch designs exist for `product_loading_skeleton`, `empty_cart`, `empty_search_recommendations`, `empty_notifications`, `no_internet_connection`, `server_error`, `maintenance_screen`, `delivery_not_available`, `location_permission_denied_settings_guidance`, `notification_settings_guidance`, `payment_failed_retry`, `otp_incorrect_retry`, `otp_expired_resend_options`.

## 4. Existing Workspace vs. Design Alignment
- **Existing `apps/customer-app`** had a Phase 1–3 prototype branded "KrishiConnect" using `flutter_riverpod`, `#1B5E20` theme, and an in-memory `LocalStorageServiceImpl`.
- **Target State**: Upgrade `apps/customer-app` to the full **Kisan Setu** Stitch Design System (`#005128` / `#146B3A` / `#F2FCF2` / `#F4BF1B` / `Inter`), migrate state management to **`provider`** (`MultiProvider` + `ChangeNotifier`), persist tokens with **`flutter_secure_storage`** and preferences with **`shared_preferences`**, and implement all 74 Stitch screens and 220 checklist states while preserving and extending existing Spring Boot API integrations.
