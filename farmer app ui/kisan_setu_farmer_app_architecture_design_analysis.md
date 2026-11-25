# PHASE 1 & PHASE 2: KISAN SETU FARMER APP — DESIGN SYSTEM & ARCHITECTURAL BLUEPRINT

## 1. Executive Summary & Design System Analysis
From an inspection of the existing **Kisan Setu** visual assets and Design System `{{DATA:DESIGN_SYSTEM:DESIGN_SYSTEM_2}}`:
- **Theme Name**: Kisan Setu Modern Agricultural Design System
- **Core Brand Primary**: `#146B3A` (Deep Forest Green / Ag-Tech Primary)
- **Primary Light / Container**: `#EAF5EC` / `#2E9B57`
- **Secondary Accent**: `#FFC928` / `#E5A800` (Warm Harvest Amber/Gold)
- **Background / Canvas**: `#F7F9F6` / `#F2FCF2`
- **Surface Cards**: `#FFFFFF` with `#E0E6DF` subtle border
- **Text Primary**: `#1A2E1F` (Deep Charcoal Green)
- **Text Secondary / Muted**: `#5A6B5D`
- **Semantic Badges**:
  - Success / Active: `#2E9B57` / `#D4EDDA`
  - Warning / Cutoff / Alert: `#E5A800` / `#FFF3CD`
  - Error / Urgent / Reversal: `#DC3545` / `#F8D7DA`
- **Border Radius**: 8px – 16px (`ROUND_EIGHT` standard for cards, 12px for inputs, 100px for pill badges)
- **Typography**: Inter / Google Sans (Headline 20-24px bold, Subheading 15-16px semibold, Body 13-14px regular, Caption/Badge 11-12px bold)

---

## 2. Technical Stack & Clean Architecture Blueprint
```
kisan_setu_farmer/
├── pubspec.yaml
├── README.md
├── analysis_options.yaml
└── lib/
    ├── main.dart                          # Independent Farmer App Entry Point
    ├── app/
    │   ├── app.dart                       # MaterialApp.router configuration
    │   ├── theme/                         # Kisan Setu Colors, Typography, Shapes
    │   └── router/                        # GoRouter declarative navigation map
    ├── core/
    │   ├── constants/                     # AppStrings, AssetConstants, StorageKeys
    │   ├── network/                       # DioClient, Interceptors, ErrorHandler
    │   ├── storage/                       # FlutterSecureStorage & SharedPrefs
    │   └── widgets/                       # Button, Card, Badge, Input, BottomSheet
    └── features/
        ├── module01_onboarding/           # Splash, Welcome, 4 Value Props, Lang
        ├── module02_location_permissions/ # GPS Prompts, Village/District, Map, Points
        ├── module03_notifications/        # Permission, Center, Category Preferences
        ├── module04_auth/                 # Mobile, OTP, Password, Reset, Session
        ├── module05_kyc/                  # Farmer/FPO, Land, Identity, Bank, Review
        ├── module06_dashboard/            # Dashboard, Quick Actions, Metric Counters
        ├── module07_profile/              # Farm Info, Land Info, FPO & Security
        ├── module08_produce/              # Listings, Add Crop, Grade, Units, Pricing
        ├── module09_demand_orders/        # Mandi Demand, Order Requests, Accept/Reject
        ├── module10_surplus/              # Surplus Batches, Bulk Buyers, Lock Rules
        ├── module11_collection/           # Slot, QR Check-in, Quality Grade & Lab
        ├── module12_inventory/            # Available vs Reserved vs Committed vs QC
        ├── module13_settlements/          # Passbook, Weekly DBT, Invoice & Deduction
        ├── module14_farming_assistant/    # Voice AI, Soil/Pest Advisory, Chat
        ├── module15_weather/              # 7-day Ag Forecast, Dew Alerts, Advisories
        ├── module16_schemes/              # PM-KISAN, Subsidies, Eligibility, Apply
        ├── module17_store/                # Seeds, Bio-Fertilizers, Ag Tools, Checkout
        ├── module18_settings_support/     # Helpdesk, Tickets, FAQs, Privacy, Terms
        └── module19_system_states/        # Offline, Maintenance, Skeletons, Errors
```

---

## 3. Screen Inventory & Flow Consolidation Matrix (All 19 Modules)
Every module contains dedicated models, state providers, and structured Flutter widgets.
- **Independent Application**: Runs on independent ports/packages (`com.kisansetu.farmer`), distinct from Customer App.
- **State Management**: MultiProvider with reactive state for ProduceListings, DemandReservations, KYCVerification, and WeeklySettlementLedgers.
- **No Direct DB Calls**: Pure REST DTO interfaces with Dio client and mock fallbacks for offline testing.
