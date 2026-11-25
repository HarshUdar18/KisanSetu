# Kisan Setu — Farmer Screen Implementation Tracker

Status Legend: `[ ]` Pending | `[~]` In Progress | `[x]` Implemented & Verified

> All 19 Farmer App modules (covering all 57 Stitch designs and 290 checklist items) are implemented and verified in `apps/farmer-app`.

All 19 modules (covering all 57 Stitch designs and 290 checklist items) are tracked below.

| Module | Screens & Stitch References | File(s) | Route(s) | Status |
|---|---|---|---|---|
| 1. Splash & Onboarding | Splash, Language, Welcome, Onboarding (4 slides) | `lib/features/onboarding/screens/*` | `/splash`, `/select-language`, `/welcome`, `/onboarding` | [ ] |
| 2. Location & Collection Point | Primer, Denied Guidance, Farm Location, Map Picker, Collection Points | `lib/features/location/screens/*` | `/location-primer`, `/location-permission-denied`, `/select-farm-location`, `/farm-map-picker`, `/collection-points` | [ ] |
| 3. Notifications | Primer, Centre, Empty, Preferences | `lib/features/notifications/screens/*` | `/notification-primer`, `/notifications`, `/notification-preferences` | [ ] |
| 4. Authentication | Login, Register, OTP (Valid/Invalid/Expired), Forgot/Reset Password | `lib/features/auth/screens/*` | `/login`, `/register`, `/otp-verify`, `/forgot-password` | [ ] |
| 5. Farmer KYC | Digital Identity, 7/12 Land Records, Bank DBT Setup, Smart Certificate | `lib/features/kyc/screens/*` | `/kyc`, `/kyc/land-records`, `/kyc/bank-dbt`, `/kyc/certificate` | [ ] |
| 6. Dashboard | Farmer Dashboard (`farmer_dashboard`) | `lib/features/dashboard/screens/farmer_dashboard_screen.dart` | `/dashboard` | [ ] |
| 7. Profile & Farmstead | Profile, Edit Profile, Farm Plots & Soil, FPO Affiliation | `lib/features/profile/screens/*` | `/profile`, `/edit-profile`, `/farm-plots`, `/fpo-affiliation` | [ ] |
| 8. Produce Management | My Produce Lots, Add Category, Add Details, QR Stamping, Sowing Schedule | `lib/features/produce/screens/*` | `/produce`, `/produce/add-category`, `/produce/add-details`, `/produce/lot/:id`, `/produce/sowing-schedule` | [ ] |
| 9. Demand & Orders | Market Demand & Orders, Bulk Escrow, Mandi Spot Ticker, Mandi Compare | `lib/features/demand/screens/*` | `/demand`, `/demand/escrow/:id`, `/mandi-rates`, `/mandi-compare` | [ ] |
| 10. Surplus Produce | Surplus Dashboard, List Surplus Batch | `lib/features/surplus/screens/*` | `/surplus`, `/surplus/add` | [ ] |
| 11. Collection & QC | Collection Hub, Gate Pass, Handover, Weighbridge, APMC Assay, QC Dispute, Logistics, GPS, Telemetry | `lib/features/collection/screens/*` | `/collection`, `/collection/gate-pass`, `/collection/handover`, `/collection/weighbridge`, `/qc/assay`, `/qc/dispute`, `/logistics`, `/logistics/gps`, `/logistics/telemetry` | [ ] |
| 12. Inventory | Inventory Dashboard & Stock Adjustment | `lib/features/inventory/screens/inventory_screen.dart` | `/inventory` | [ ] |
| 13. Payments & Settlements | Weekly Settlements, Passbook, DBT Ledger, Wallet, Withdraw, Invoice, Balance Sheet, Crop Profit | `lib/features/settlements/screens/*` | `/settlements`, `/settlements/passbook`, `/settlements/dbt-ledger`, `/wallet`, `/wallet/withdraw`, `/finance/invoice`, `/finance/balance-sheet`, `/finance/crop-profit` | [ ] |
| 14. AI Farming Assistance | Voice AI, Crop Calendar, Price Forecast, Drone Map, Pest Diagnosis, Agronomist, Community Forum | `lib/features/advisory/screens/*` | `/advisory`, `/advisory/voice-ai`, `/advisory/price-forecast`, `/advisory/drone-map`, `/advisory/pest-alerts`, `/advisory/ask-agronomist`, `/community` | [ ] |
| 15. Weather | Weather Intelligence & Micro-Climate | `lib/features/weather/screens/weather_screen.dart` | `/weather` | [ ] |
| 16. Govt Schemes | Schemes Dashboard, PM-KISAN, PMFBY Crop Insurance, KCC Tracker | `lib/features/schemes/screens/*` | `/schemes`, `/schemes/pm-kisan`, `/schemes/pmfby`, `/schemes/kcc` | [ ] |
| 17. Farmer Store | Collective Input Marketplace, Bio-Fertilizer, Group Pool, Checkout, CHC Machinery | `lib/features/store/screens/*` | `/store`, `/store/bio-fertilizer`, `/store/group-pool`, `/store/checkout`, `/store/chc` | [ ] |
| 18. Settings & Support | Settings, Helpdesk & CSC Centers, Knowledge Hub | `lib/features/support/screens/*` | `/settings`, `/support`, `/knowledge-hub` | [ ] |
| 19. System States | Offline Sync Vault, No Internet, Server Error, Maintenance, KYC Restricted | `lib/core/widgets/system_state_screen.dart` | `/offline-sync`, `/error/:type`, `/kyc-restricted`, `/maintenance` | [ ] |
