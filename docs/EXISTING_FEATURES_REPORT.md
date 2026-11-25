# EXISTING_FEATURES_REPORT.md — Feature Classification

**Date:** 2026-11-25  
**Classification Key:**
- ✅ **Fully Implemented** — UI + Backend + Integration verified
- 🟡 **UI Only** — Flutter/React screens exist, no backend endpoint
- 🔵 **Backend Only** — Endpoint exists, not called from frontend
- 🟠 **Partially Integrated** — Both exist but integration incomplete
- 🔴 **Mock Only** — Hard-coded or seeded data, no real integration
- ⬛ **Not Implemented** — Feature missing from both frontend and backend

---

## Authentication & User Management

| Feature | Customer App | Farmer App | Admin Panel | Backend | Classification |
|---------|-------------|-----------|-------------|---------|----------------|
| Register (phone + password) | ✅ | ✅ | N/A | ✅ `POST /auth/register` | ✅ Fully Implemented |
| Login (phone/email + password) | ✅ | ✅ | ✅ | ✅ `POST /auth/login` | ✅ Fully Implemented |
| OTP Request | ✅ | ✅ | N/A | ✅ `POST /auth/send-otp` | 🟠 Mock OTP (always 123456) |
| OTP Verification | ✅ | ✅ | N/A | ✅ `POST /auth/verify-otp` | 🟠 Mock OTP |
| Logout | ✅ | ✅ | ✅ | ✅ `POST /auth/logout` | ✅ Fully Implemented |
| Refresh Token | 🔴 | 🔴 | 🔴 | ✅ entity exists | ⬛ Not Integrated |
| Forgot Password | ✅ UI | ✅ UI | ✅ UI | ⬛ No endpoint | 🟡 UI Only |
| Session Check (`/users/me`) | ✅ | ✅ | N/A | ✅ `GET /users/me` | ✅ Fully Implemented |
| Update Profile | ✅ | ✅ | N/A | ✅ `PUT /users/me` | 🟠 Partially Integrated |
| Change Password | ✅ UI | ✅ UI | N/A | ⬛ | 🟡 UI Only |
| Delete Account | ✅ UI | N/A | N/A | ⬛ | 🟡 UI Only |

---

## Catalog & Products

| Feature | Customer App | Admin Panel | Backend | Classification |
|---------|-------------|-------------|---------|----------------|
| List Categories | ✅ | ✅ | ✅ `GET /api/v1/categories` | ✅ Fully Implemented |
| Create Category (Admin) | N/A | ✅ | ✅ `POST /api/v1/admin/categories` | ✅ Fully Implemented |
| List Products | ✅ | ✅ | ✅ `GET /api/v1/products` | ✅ Fully Implemented |
| Product Detail | ✅ local | N/A | ⬛ No `GET /products/{id}` | 🔴 Mock Only |
| Search Products | ✅ local filter | N/A | ⬛ No search endpoint | 🔴 Client-Side Only |
| Filter by Category | ✅ local filter | N/A | ⬛ No query param support | 🔴 Client-Side Only |
| Product Reviews | ✅ UI | N/A | ⬛ | 🟡 UI Only |
| Farmer Profile (from customer) | ✅ UI | N/A | ⬛ No public farmer profile endpoint | 🟡 UI Only |
| FPO Network | ✅ UI | N/A | ⬛ | 🟡 UI Only |
| Product Pricing | ✅ seeded | ✅ | ✅ `GET/PUT /api/v1/prices/{productId}` | 🟠 Partially Integrated |

---

## Cart & Weekly Cart

| Feature | Customer App | Backend | Classification |
|---------|-------------|---------|----------------|
| Fetch Cart | ✅ | ✅ `GET /api/v1/cart` | 🟠 Live with fallback |
| Add to Cart | ✅ | ✅ `POST /api/v1/cart/items` | 🟠 Live with local fallback |
| Update Cart Item | ✅ | ✅ `PUT /api/v1/cart/items/{id}` | 🟠 Live with local fallback |
| Remove Cart Item | ✅ | ✅ `DELETE /api/v1/cart/items/{id}` | 🟠 Live with local fallback |
| Clear Cart | ✅ | ✅ `DELETE /api/v1/cart` | 🟠 Partially Integrated |
| Apply Coupon | ✅ UI | ⬛ | 🟡 UI Only |
| Weekly Cart Create | ✅ | ✅ `POST /api/v1/weekly-cart` | 🟠 Partially Integrated |
| Weekly Cart Assign Days | ✅ | ✅ | 🟠 Partially Integrated |
| Weekly Cart Fetch | ✅ | ✅ | 🟠 Partially Integrated |

---

## Orders & Checkout

| Feature | Customer App | Backend | Classification |
|---------|-------------|---------|----------------|
| Checkout (create order) | ✅ | ✅ `POST /api/v1/orders/checkout` | 🟠 Live with mock fallback |
| Fetch Orders | ✅ | ✅ `GET /api/v1/orders` | 🟠 Live with seeded fallback |
| Order Details | ✅ | ✅ `GET /api/v1/orders/{id}` | 🟠 Partially Integrated |
| Cancel Order | ✅ | ✅ `POST /api/v1/orders/{id}/cancel` | 🟠 Partially Integrated |
| Order Tracking | ✅ | ✅ `GET /api/v1/tracking/order/{id}` | 🟠 Partially Integrated |
| Live Tracking (map) | ✅ UI | ⬛ No location update endpoint | 🟡 UI Only |
| Tax Invoice | ✅ UI | ⬛ No invoice endpoint | 🟡 UI Only |
| Order Confirmed Screen | ✅ | ✅ | ✅ Fully Implemented |

---

## Payment

| Feature | Customer App | Backend | Classification |
|---------|-------------|---------|----------------|
| Initiate Payment | ✅ | ✅ `POST /api/v1/payments/initiate` | 🔴 Mock Gateway Only |
| Payment Status | ✅ | ✅ `GET /api/v1/payments/{id}` | 🔴 Mock Gateway Only |
| Payment Failed Screen | ✅ | ✅ | 🔴 Mock Gateway Only |
| Razorpay / UPI integration | ⬛ | ⬛ No real gateway | ⬛ Not Implemented |
| Kisan Wallet (prepaid balance) | ✅ UI | ⬛ No wallet endpoint | 🟡 UI Only |
| Refund | ⬛ | ⬛ | ⬛ Not Implemented |

---

## Subscriptions

| Feature | Customer App | Backend | Classification |
|---------|-------------|---------|----------------|
| List Subscriptions | ✅ | ✅ `GET /api/v1/subscriptions` | 🟠 Partially Integrated |
| Create Subscription | ✅ | ✅ `POST /api/v1/subscriptions` | 🟠 Partially Integrated |
| Subscription Details | ✅ | ✅ | 🟠 Partially Integrated |
| Pause/Resume Subscription | ✅ | ✅ | 🟠 Partially Integrated |
| Edit Schedule | ✅ | ✅ | 🟠 Partially Integrated |

---

## Farmer Features

| Feature | Farmer App | Admin Panel | Backend | Classification |
|---------|-----------|-------------|---------|----------------|
| Farmer Registration | ✅ | ✅ | ✅ | 🟠 OTP is mock |
| Farmer Login | ✅ | N/A | ✅ | 🟠 Partially Integrated |
| KYC Identity Submission | ✅ UI | ✅ UI | ⬛ No KYC controller | 🟡 UI Only |
| KYC Document Upload | ✅ UI | ✅ UI | ⬛ | 🟡 UI Only |
| KYC Review (Admin) | N/A | ✅ UI | ⬛ | 🟡 UI Only |
| Farmer Profile (view/edit) | ✅ | N/A | ✅ `GET/PUT /api/v1/farmers/me` | 🔴 Mock Only |
| Farm Plot Management | ✅ UI | N/A | ⬛ | 🟡 UI Only |
| FPO Association | ✅ UI | ✅ UI | ⬛ | 🟡 UI Only |
| Produce Listing (Add) | ✅ | N/A | ✅ `POST /api/v1/farmers/listings` | 🔴 Mock Only |
| Produce Listing (List) | ✅ | ✅ UI | ✅ `GET /api/v1/farmers/listings` | 🔴 Mock in App |
| Update Availability | ✅ UI | N/A | ✅ `PUT /api/v1/farmers/listings/{id}/availability` | 🔴 Mock Only |
| Surplus Produce | ✅ UI | N/A | ⬛ No surplus endpoint | 🟡 UI Only |
| Demand Requests | ✅ UI | ✅ UI | ⬛ No demand module | 🟡 UI Only |
| Accept Demand | ✅ UI | N/A | ⬛ | 🟡 UI Only |
| Collection Gate Pass | ✅ UI | ✅ UI | ⬛ No collection controller | 🟡 UI Only |
| Quality Inspection | ✅ UI | ✅ UI | ⬛ Stub only | 🟡 UI Only |
| Weighbridge Record | ✅ UI | ✅ UI | ⬛ | 🟡 UI Only |
| Cold Chain Tracking | ✅ UI | ✅ UI | ⬛ | 🟡 UI Only |
| Settlement (view) | ✅ UI | ✅ UI | ⬛ Stub only | 🟡 UI Only |
| Settlement (DBT authorize) | N/A | ✅ UI | ⬛ | 🟡 UI Only |
| Advisory / Weather | ✅ UI | N/A | ⬛ No weather API | 🟡 UI Only |
| Govt Schemes | ✅ UI | N/A | ⬛ Stub only | 🟡 UI Only |
| Farmer Store | ✅ UI | ✅ UI | ⬛ Stub only | 🟡 UI Only |

---

## Admin Features

| Feature | Admin Panel | Backend | Classification |
|---------|-------------|---------|----------------|
| Admin Login | ✅ | ✅ | ✅ Fully Implemented |
| User Management | ✅ | ✅ | ✅ Fully Implemented |
| Customer List | ✅ | ✅ `/admin/users` | 🟠 Partially (no customer-specific filter) |
| Farmer List | ✅ | ✅ `/admin/users` | 🟠 Partially |
| FPO Management | ✅ UI | ⬛ No FPO endpoint | 🟡 UI Only |
| KYC Management | ✅ UI | ⬛ | 🟡 UI Only |
| Product Catalogue | ✅ | ✅ | ✅ Fully Implemented |
| Produce Listings | ✅ UI | ⬛ No admin produce endpoint | 🟡 UI Only |
| Demand Management | ✅ UI | ⬛ | 🟡 UI Only |
| Order Management | ✅ UI | ⬛ No admin orders endpoint | 🟡 UI Only |
| Collections | ✅ UI | ⬛ | 🟡 UI Only |
| Quality Inspection | ✅ UI | ⬛ | 🟡 UI Only |
| Warehouse | ✅ UI | ⬛ | 🟡 UI Only |
| Inventory | ✅ UI | ⬛ | 🟡 UI Only |
| Logistics | ✅ UI | ⬛ | 🟡 UI Only |
| Payment Management | ✅ UI | ⬛ | 🟡 UI Only |
| Settlement (DBT Auth) | ✅ UI | ⬛ | 🟡 UI Only |
| Subscriptions | ✅ UI | ⬛ No admin sub endpoint | 🟡 UI Only |
| Notifications | ✅ UI | ⬛ | 🟡 UI Only |
| Support Tickets | ✅ UI | ⬛ | 🟡 UI Only |
| Analytics Dashboard | ✅ UI | ⬛ | 🟡 UI Only |
| Admin User Management | ✅ UI | ⬛ | 🟡 UI Only |
| Settings | ✅ UI | ⬛ | 🟡 UI Only |

---

## Infrastructure & Cross-Cutting

| Feature | Status | Classification |
|---------|--------|----------------|
| PostgreSQL (via Docker) | ✅ Configured | ✅ Ready |
| Redis (via Docker) | ✅ Configured | 🔴 Not Used |
| RabbitMQ (via Docker) | ✅ Configured | 🔴 Zero events published |
| JWT Authentication | ✅ | ✅ Fully Implemented |
| CORS | ⚠️ Wildcard `*` in dev | 🟠 Dev Only |
| Swagger UI | ✅ | ✅ Available at `/swagger-ui.html` |
| Flyway Migrations | ✅ | ✅ 9 migrations applied |
| API Gateway | ⬛ | ⬛ Not Implemented |
| Push Notifications (FCM) | ⬛ | ⬛ Not Implemented |
| SMS OTP (real) | ⬛ | ⬛ Not Implemented |
| File/Image Upload | ⬛ | ⬛ Stub only |
