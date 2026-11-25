# Kisan Setu — Farmer Navigation Flow

## 1. Entry & Protected Auth Flow
```
/splash
  ├── (authenticated farmer) ───────────────────► /dashboard
  ├── (language not chosen) ────────────────────► /select-language ─► /welcome
  └── (returning unauthenticated) ──────────────► /welcome
                                                    ├── "Get Started" ─► /onboarding ─► /location-primer
                                                    └── "Farmer Login" ► /login ─► /otp-verify ─► /dashboard
```
All protected farmer routes (`/dashboard`, `/produce`, `/demand`, `/settlements`, `/profile`, `/kyc`, etc.) redirect to `/login` when unauthenticated (`GoRouter.redirect`).

## 2. Primary 5-Tab Bottom Navigation (`ShellRoute`)
| Tab | Label | Icon | Route |
|---|---|---|---|
| 0 | Dashboard | `agriculture` | `/dashboard` |
| 1 | My Produce | `eco` | `/produce` |
| 2 | Demand | `trending_up` | `/demand` |
| 3 | Settlements | `account_balance_wallet` | `/settlements` |
| 4 | Profile | `person` | `/profile` |

## 3. Core Workflow Flows
- **KYC**: `/kyc` (Aadhaar/PAN/KCC) -> `/kyc/land-records` (7/12 & 8A) -> `/kyc/bank-dbt` -> `/kyc/certificate`
- **Add Produce**: `/produce` -> `/produce/add-category` -> `/produce/add-details` -> `/produce/lot/:id` (QR Stamp)
- **Surplus**: `/surplus` -> `/surplus/add`
- **Collection & QC**: `/collection` -> `/collection/gate-pass` -> `/collection/handover` -> `/collection/weighbridge` -> `/qc/assay` -> `/qc/dispute`
- **Logistics**: `/logistics` -> `/logistics/gps` & `/logistics/telemetry`
- **Finance**: `/settlements` -> `/settlements/passbook` & `/settlements/dbt-ledger` & `/wallet` -> `/wallet/withdraw`
- **Advisory & Weather**: `/advisory` -> `/advisory/voice-ai`, `/advisory/price-forecast`, `/advisory/drone-map`, `/advisory/pest-alerts`, `/weather`
- **Schemes & Store**: `/schemes` -> `/schemes/pm-kisan`, `/schemes/pmfby`, `/schemes/kcc`; `/store` -> `/store/bio-fertilizer`, `/store/group-pool`, `/store/checkout`, `/store/chc`
