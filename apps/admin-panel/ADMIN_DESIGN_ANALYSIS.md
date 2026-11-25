# Kisan Setu — Admin Design Analysis

> **Primary Source of Truth**: `Admin_ui/` (43 Stitch screen designs + `kisan_setu/DESIGN.md`)

## 1. Executive Summary
The Google Stitch Admin Web Panel designs for **Kisan Setu** establish an enterprise agricultural supply-chain & governance command center. It uses the unified Kisan Setu Material 3 palette (`#005128` Deep Field Green, `#F2FCF2` Sage-Mint Canvas, `#FFFFFF` Elevated Cards, `#F4BF1B` Harvest Gold) optimized for dense operational tables, multi-stage supply chain tracking, KYC document auditing, escrow clearing, and cold-chain fleet telematics.

## 2. Layout & Shell Architecture
- **Auth Shell** (`admin_login_access_portal`, `admin_2fa_multi_factor_verification`, `admin_password_recovery_reset`, `admin_session_timeout_account_lock`):
  - Two-column split card on `#F2FCF2` canvas: left column for realm selector (`HQ / Super Admin`, `Hub Ops & QC`, `Finance & Escrow`) and credentials; right column for live operational broadcast, escrow clearing status, and NOC emergency desk.
- **Enterprise Admin Shell** (`master_admin_dashboard` and all operational modules):
  - **Collapsible Left Sidebar (`256px` / `72px`)**: Grouped into `MAIN`, `STAKEHOLDERS`, `SUPPLY CHAIN & CATALOG`, `FINANCE & COMMERCE`, and `SYSTEM & GOVERNANCE` with `#005128` active pill, permission-filtered items, and bottom Admin identity footer.
  - **Sticky Top Header (`64px`)**: Breadcrumbs, Global Search (`Ctrl+K`), Service Health badge, Date Range selector, `+ Quick Action` CTA, Notification drawer trigger, Help, and Admin Profile dropdown.
  - **Main Workspace**: 4-column KPI summary cards, Supply vs Demand velocity charts, Regional Cluster performance table, Operational Alerts panel, and paginated Consignment/Data tables with slide-over detail drawers.
