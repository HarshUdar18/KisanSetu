# Kisan Setu — Admin Screen Implementation Tracker

Status Legend: `[ ]` Pending | `[~]` In Progress | `[x]` Implemented & Verified

All 28 Admin Phases (covering all 43 Stitch designs) are tracked below.

| # | Module / Screen | Stitch Ref | Component Path | Route | UI | API | Test |
|---|---|---|---|---|---|---|---|
| 1 | Auth (Login, 2FA, Forgot, Locked, Unauth) | `admin_login_access_portal`, `admin_2fa_*` | `src/features/auth/AuthPages.tsx` | `/login`, `/2fa`, `/forgot-password`, `/session-locked`, `/unauthorized` | [x] | Live + Fallback | [x] |
| 2 | Master Admin Dashboard | `master_admin_dashboard` | `src/features/dashboard/DashboardPage.tsx` | `/dashboard` | [x] | Live + Mock | [x] |
| 3 | Customer Management | `farmer_management_directory` pattern | `src/features/customers/CustomersPage.tsx` | `/customers` | [x] | Live `/admin/users` | [x] |
| 4 | Farmer Management & 360 Profile | `farmer_management_directory`, `farmer_360_profile_land_records` | `src/features/farmers/FarmersPage.tsx` | `/farmers`, `/farmers/:id` | [x] | Live `/admin/users` | [x] |
| 5 | FPO Management & Registration | `fpo_hub_directory_*`, `add_register_new_fpo` | `src/features/fpos/FposPage.tsx` | `/fpos` | [x] | Mock | [x] |
| 6 | KYC Verification & Document Audit | `kyc_verification_document_audit_desk`, `farmer_kyc_document_audit_desk` | `src/features/kyc/KycPage.tsx` | `/kyc` | [x] | Mock | [x] |
| 7 | Product Catalogue & SKUs | `master_product_catalogue_*`, `master_sku_*` | `src/features/products/ProductsPage.tsx` | `/products` | [x] | Live `/admin/categories` & `/products` | [x] |
| 8 | Produce Listings & QR Audit | `produce_listings_sourcing_desk`, `produce_lot_dossier_*` | `src/features/produce/ProduceListingsPage.tsx` | `/produce` | [x] | Mock | [x] |
| 9 | Demand & Reverse Auction | `institutional_demand_*`, `dynamic_reverse_b2b_*` | `src/features/demand/DemandPage.tsx` | `/demand` | [x] | Mock | [x] |
| 10 | Order Management & Tracker | `order_management_multi_stage_sourcing_tracker` | `src/features/orders/OrdersPage.tsx` | `/orders` | [x] | Mock | [x] |
| 11 | Collection Management | `collection_point_operations_*` | `src/features/collections/CollectionsPage.tsx` | `/collections` | [x] | Mock | [x] |
| 12 | Quality Inspection & APMC Lab | `quality_inspection_apmc_lab_assay_desk` | `src/features/quality/QualityPage.tsx` | `/quality` | [x] | Mock | [x] |
| 13 | Warehouse Management | `warehouse_command_*`, `cold_storage_rack_*` | `src/features/warehouses/WarehousesPage.tsx` | `/warehouses` | [x] | Mock | [x] |
| 14 | Inventory & FIFO Watch | `perishable_inventory_health_fifo_expiry_watch` | `src/features/inventory/InventoryPage.tsx` | `/inventory` | [x] | Mock | [x] |
| 15 | Logistics & Fleet Telematics | `cold_chain_logistics_*`, `live_reefer_fleet_*` | `src/features/logistics/LogisticsPage.tsx` | `/logistics` | [x] | Mock | [x] |
| 16 | Payments, Escrow & Settlements | `escrow_clearing_*`, `direct_benefit_transfer_*`, `farmer_settlement_*` | `src/features/finance/FinancePages.tsx` | `/payments`, `/settlements` | [x] | Mock | [x] |
| 17 | Subscriptions, Store, Coupons | Platform Commerce Modules | `src/features/commerce/CommercePages.tsx` | `/subscriptions`, `/farmer-store`, `/promotions` | [x] | Mock | [x] |
| 18 | Notifications & Support | Platform Governance Modules | `src/features/governance/GovernancePages.tsx` | `/notifications`, `/support` | [x] | Mock | [x] |
| 19 | Reports & Financial Analytics | `platform_financial_p_l_*`, `apeda_*`, `apmc_*` | `src/features/analytics/AnalyticsPage.tsx` | `/analytics` | [x] | Mock | [x] |
| 20 | RBAC Users, Settings & Profile | `enterprise_role_based_access_control_*`, `platform_security_policies_*` | `src/features/admin/AdminSystemPages.tsx` | `/admin-users`, `/settings`, `/profile` | [x] | Live + Mock | [x] |
