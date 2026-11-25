# Kisan Setu — Admin Screen Inventory

Maps all **43 Stitch Screen Designs** (`Admin_ui/`) and **28 Admin Phases** to React routes.

| Phase / Module | Stitch Design Reference(s) | Route |
|---|---|---|
| Auth & Security | `admin_login_access_portal`, `admin_2fa_multi_factor_verification`, `admin_password_recovery_reset`, `admin_session_timeout_account_lock` | `/login`, `/2fa`, `/forgot-password`, `/session-locked`, `/unauthorized` |
| Dashboard | `master_admin_dashboard` | `/dashboard` |
| Customers | Designed via `farmer_management_directory` pattern | `/customers` |
| Farmers | `farmer_management_directory`, `farmer_360_profile_land_records` | `/farmers`, `/farmers/:id` |
| FPOs | `fpo_hub_directory_aggregator_details`, `add_register_new_fpo`, `fpo_statutory_compliance_audit_desk`, `fpo_collective_sourcing_pools_bulk_allocation_desk` | `/fpos` |
| KYC Verification | `kyc_verification_document_audit_desk`, `farmer_kyc_document_audit_desk`, `kyc_discrepancy_resolution_rejection_modal` | `/kyc` |
| Product Catalogue | `master_product_catalogue_taxonomy_engine`, `master_sku_configuration_apmc_price_band_desk` | `/products` |
| Produce Listings | `produce_listings_sourcing_desk`, `produce_lot_dossier_qr_stamping_audit` | `/produce` |
| Demand Management | `institutional_demand_aggregation_matching_engine`, `dynamic_reverse_b2b_auction_spot_procurement_desk`, `contract_farming_forward_sourcing_agreement_desk` | `/demand` |
| Order Management | `order_management_multi_stage_sourcing_tracker` | `/orders` |
| Collections | `collection_point_operations_intake_gate_pass_desk` | `/collections` |
| Quality Inspection | `quality_inspection_apmc_lab_assay_desk` | `/quality` |
| Warehouses | `warehouse_command_multi_facility_cold_hub_overview`, `cold_storage_rack_bin_allocation_planner`, `inter_hub_transfers_cross_dock_dispatch_desk` | `/warehouses` |
| Inventory | `perishable_inventory_health_fifo_expiry_watch` | `/inventory` |
| Logistics | `cold_chain_logistics_live_reefer_fleet_telematics_hub`, `live_reefer_fleet_telematics_gis_geofencing_command`, `multi_stop_reefer_route_planner_algorithmic_dispatch_optimizer`, `transporter_logistics_fleet_partner_performance_sla_settlement_ledger` | `/logistics` |
| Payments & Settlements | `escrow_clearing_perishable_sourcing_settlements_command`, `direct_benefit_transfer_dbt_pfms_bank_payout_gateway`, `farmer_settlement_statements_passbook_tax_invoicing_desk`, `gst_tax_reconciliation_s.no_54_exemption_ledger`, `statutory_deductions_apmc_market_cess_financial_audit_ledger` | `/payments`, `/settlements` |
| Subscriptions | Designed via platform system | `/subscriptions` |
| Farmer Store | Designed via platform system | `/farmer-store` |
| Coupons & Promotions | Designed via platform system | `/promotions` |
| Notifications | Designed via platform system | `/notifications` |
| Support & Complaints | Designed via platform system | `/support` |
| Reports & Analytics | `platform_financial_p_l_revenue_engine_gross_margin_analytics`, `apeda_agri_export_compliance_traceability_audit_desk`, `apmc_market_cess_state_statutory_audit_desk` | `/analytics` |
| Admin Users & RBAC | `enterprise_role_based_access_control_rbac_user_governance`, `immutable_security_forensic_audit_trail` | `/admin-users` |
| System Settings | `platform_security_policies_compliance_governance` | `/settings`, `/profile` |
