# Kisan Setu — Farmer API Integration

> Based on inspection of `backend/spring-boot-application` controllers (`AuthController`, `FarmerController`, `CatalogController`, `PricingController`, `ServiceAreaController`, `UserController`).
> All endpoints are prefixed with `/api/v1`. Unimplemented endpoints use clearly isolated mock services in `lib/core/services/mock_farmer_services.dart`.

| Feature | Endpoint | Method | Auth | Status | Mock Fallback / Notes |
|---|---|---|---|---|---|
| **Auth — Register** | `/auth/register` | POST | Public | Integrated | `role: ROLE_FARMER` |
| **Auth — Login** | `/auth/login` | POST | Public | Integrated | Verifies `ROLE_FARMER` or `ROLE_ADMIN` |
| **Auth — Request/Verify OTP** | `/auth/request-otp`, `/auth/verify-otp` | POST | Public | Integrated | Dev fallback `123456` |
| **Auth — Logout** | `/auth/logout` | POST | Bearer | Integrated | Clears secure storage |
| **Farmer Profile** | `/farmer/profile` | GET | Bearer (`ROLE_FARMER`) | Integrated | Farmstead, land, crop category |
| **Dashboard Summary** | `/farmer/dashboard-summary` | GET | Bearer (`ROLE_FARMER`) | Integrated | Active listings, collections, settlement balance |
| **Produce Listings** | `/farmer/listings`, `/farmer/listings/{id}` | GET, POST, PUT | Bearer (`ROLE_FARMER`) | Integrated | Separate from master product catalog |
| **Listing Availability** | `/farmer/listings/{id}/availability` | PATCH | Bearer (`ROLE_FARMER`) | Integrated | Toggle availability & stock quantity |
| **Master Catalog & Prices** | `/categories`, `/products`, `/prices` | GET | Public | Integrated | Used when adding new produce |
| **Service Areas / Hubs** | `/service-areas` | GET | Public | Integrated | Collection hub verification |
| **KYC & Land 7/12** | `/farmer/kyc/*` | GET, POST | Bearer | Mock Fallback | Backend KYC endpoints pending; sensitive docs not stored in plain text |
| **Demand & Bulk Escrow** | `/farmer/demand`, `/farmer/orders` | GET, POST | Bearer | Mock Fallback | Isolated mock demand & escrow agreements |
| **Surplus Produce** | `/farmer/surplus` | GET, POST, DELETE | Bearer | Mock Fallback | Isolated mock surplus batches |
| **Collection, Weighbridge & QC** | `/farmer/collections`, `/farmer/qc` | GET, POST | Bearer | Mock Fallback | Gate pass, tare slip, APMC lab assay, QC dispute |
| **Settlements & DBT Ledger** | `/farmer/settlements`, `/farmer/wallet` | GET, POST | Bearer | Mock Fallback | Weekly Friday settlement cycle & passbook |
| **AI Advisory & Weather** | `ai-service /health`, `/advisory`, `/weather` | GET, POST | Bearer | Mock Fallback | Presents AI as guidance; weather clearly labeled |
| **Govt Schemes & Farmer Store** | `/schemes`, `/store/products`, `/store/orders` | GET, POST | Bearer | Mock Fallback | Prototype store & scheme info with source/dates |
