# Kisan Setu — Admin API Integration

> Based on inspection of `AdminController.java`, `AuthController.java`, `CatalogController.java`, `PricingController.java`, and `ServiceAreaController.java`.

| Feature | Endpoint | Method | Auth / Role | Status | Missing / Mock Notes |
|---|---|---|---|---|---|
| **Admin Login** | `/api/v1/auth/login` | POST | Public | Integrated | Verifies `ROLE_ADMIN` |
| **Current Admin** | `/api/v1/users/me` | GET | Bearer (`ROLE_ADMIN`) | Integrated | Restores session |
| **List All Users** | `/api/v1/admin/users` | GET | Bearer (`ROLE_ADMIN`) | Integrated | Used in Customers, Farmers & Admin Users |
| **List Categories** | `/api/v1/admin/categories` | GET | Bearer (`ROLE_ADMIN`) | Integrated | Master Product Catalogue |
| **Create Category** | `/api/v1/admin/categories` | POST | Bearer (`ROLE_ADMIN`) | Integrated | Master Product Catalogue |
| **Products & Prices** | `/api/v1/products`, `/api/v1/prices` | GET | Public | Integrated | Master SKU & market rates |
| **Update Price** | `/api/v1/prices/{productId}` | PUT | Bearer (`ROLE_ADMIN`) | Integrated | Authoritative market rate update |
| **Service Areas** | `/api/v1/service-areas` | GET | Public | Integrated | Hub & corridor directory |
| **FPO / KYC / Listings / Demand / Orders / Collections / QC / Warehouses / Inventory / Logistics / Settlements / Store / Coupons / Notifications / Support / RBAC / Settings** | `/api/v1/admin/*` | GET, POST, PUT | Bearer (`ROLE_ADMIN`) | Mock Fallback | Isolated mock services in `src/services/mockAdminData.ts` clearly labeled as prototype/mock until backend endpoints are added |
