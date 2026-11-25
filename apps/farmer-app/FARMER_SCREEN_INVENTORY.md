# Kisan Setu — Farmer Screen Inventory

Maps all **57 Stitch Screen Designs** (`farmer app ui/<folder>`) and **290 Checklist Items** across Modules 1–19.

| Module | Checklist Items | Stitch Designs Covered | Route(s) |
|---|---|---|---|
| **1. Splash & Onboarding** | 1–9 | Design system (`DESIGN.md`) | `/splash`, `/select-language`, `/welcome`, `/onboarding` |
| **2. Location & Collection Point** | 10–29 | `collection_center_slot_booking_gate_pass`, `fpo_affiliation_land_settings` | `/location-primer`, `/location-permission-denied`, `/select-farm-location`, `/farm-map-picker`, `/collection-points` |
| **3. Notifications** | 30–48 | Design system (`DESIGN.md`) | `/notification-primer`, `/notifications`, `/notification-preferences` |
| **4. Authentication** | 49–62 | Design system (`DESIGN.md`) | `/login`, `/register`, `/otp-verify`, `/forgot-password` |
| **5. Farmer KYC** | 63–82 | `farmer_kyc_digital_identity`, `land_record_verification_7_12`, `kyc_verification_smart_certificate`, `bank_account_dbt_setup` | `/kyc`, `/kyc/land-records`, `/kyc/bank-dbt`, `/kyc/certificate` |
| **6. Farmer Dashboard** | 83–92 | `farmer_dashboard` | `/dashboard` |
| **7. Profile & Farmstead** | 93–108 | `farmer_profile_farmstead_overview`, `farm_plots_soil_health_management`, `fpo_affiliation_land_settings` | `/profile`, `/edit-profile`, `/farm-plots`, `/fpo-affiliation` |
| **8. Produce Management** | 109–136 | `my_produce_management`, `add_new_produce_crop_category`, `add_new_produce_quantity_price_harvest`, `crop_portfolio_sowing_schedule`, `produce_lot_details_qr_stamping` | `/produce`, `/produce/add-category`, `/produce/add-details`, `/produce/lot/:id`, `/produce/sowing-schedule` |
| **9. Demand & Orders** | 137–154 | `market_demand_orders`, `bulk_escrow_agreement_dispatch`, `daily_apmc_mandi_rates_live_spot_ticker`, `multi_mandi_price_comparison_distance_matrix` | `/demand`, `/demand/escrow/:id`, `/mandi-rates`, `/mandi-compare` |
| **10. Surplus Produce** | 155–168 | `surplus_produce_management`, `list_surplus_batch` | `/surplus`, `/surplus/add` |
| **11. Collection & Quality** | 169–183 | `collection_center_slot_booking_gate_pass`, `mandi_arrival_pre_registration_gate_slot_pass`, `farmgate_dispatch_handover`, `weighbridge_intake_tare_slip`, `apmc_lab_assay_grade_card`, `qc_grade_dispute_re_sampling_request`, `cold_chain_logistics_overview`, `live_transporter_gps_tracking`, `temperature_and_humidity_telemetry` | `/collection`, `/collection/gate-pass`, `/collection/handover`, `/collection/weighbridge`, `/qc/assay`, `/qc/dispute`, `/logistics`, `/logistics/gps`, `/logistics/telemetry` |
| **12. Inventory** | 184–191 | `my_produce_management`, `produce_lot_details_qr_stamping` | `/inventory` |
| **13. Payments & Settlements** | 192–207 | `weekly_settlements_passbook`, `settlement_passbook_statements`, `dbt_escrow_payouts_transit_ledger`, `kisan_wallet_financial_overview`, `bank_withdrawal_instant_transfer`, `gst_exempt_farmer_tax_invoice_sales_receipt`, `annual_farm_balance_sheet_p_l_statement`, `crop_wise_cost_of_cultivation_profit_margin` | `/settlements`, `/settlements/passbook`, `/settlements/dbt-ledger`, `/wallet`, `/wallet/withdraw`, `/finance/invoice`, `/finance/balance-sheet`, `/finance/crop-profit` |
| **14. AI Farming Assistance** | 208–218 | `voice_ai_multilingual_farming_assistant_soil_diagnosis`, `agronomic_advisory_crop_calendar`, `ai_crop_price_forecast_selling_recommendation`, `ai_drone_scouting_multispectral_map`, `pest_outbreak_ai_diagnosis`, `ask_agronomist_share_field_tip`, `farmer_audio_voice_note_q_a_discussion` | `/advisory`, `/advisory/voice-ai`, `/advisory/price-forecast`, `/advisory/drone-map`, `/advisory/pest-alerts`, `/advisory/ask-agronomist`, `/community` |
| **15. Weather** | 219–226 | `weather_intelligence_micro_climate` | `/weather` |
| **16. Government Schemes** | 227–234 | `government_schemes_subsidies_dashboard`, `pm_kisan_dbt_installment_tracker`, `crop_insurance_pmfby_claim_settlement`, `kisan_credit_card_kcc_limit_loan_interest_subvention_tracker` | `/schemes`, `/schemes/pm-kisan`, `/schemes/pmfby`, `/schemes/kcc` |
| **17. Farmer Store** | 235–245 | `fpo_collective_input_marketplace`, `fpo_agri_input_store_subsidized_bio_fertilizer_booking`, `input_group_purchase_pool_bulk_discount`, `fpo_input_order_summary_subsidized_billing`, `farm_machinery_custom_hiring_center_chc` | `/store`, `/store/bio-fertilizer`, `/store/group-pool`, `/store/checkout`, `/store/chc` |
| **18. Settings & Support** | 246–264 | `farmer_helpdesk_ticket_redressal_taluka_csc_centers`, `success_stories_farmer_knowledge_hub` | `/settings`, `/support`, `/knowledge-hub` |
| **19. System & Exception States** | 265–290 | `offline_mode_local_sync_vault` | `/offline-sync`, `/error/:type`, `/kyc-restricted`, `/maintenance` |
