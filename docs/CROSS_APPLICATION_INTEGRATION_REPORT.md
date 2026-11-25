# CROSS_APPLICATION_INTEGRATION_REPORT.md

**Date:** 2026-11-25

This document maps every integration point between the three frontend applications and the backend.

---

## Integration Matrix

### Legend
- ✅ Working end-to-end
- 🟠 Partial (errors handled with fallback)
- 🔴 Mock/stub only
- ⬛ Not implemented

| API Endpoint | Customer App | Farmer App | Admin Panel | Backend Impl |
|-------------|-------------|-----------|-------------|-------------|
| `POST /auth/register` | ✅ | ✅ | N/A | ✅ |
| `POST /auth/login` | ✅ | ✅ | ✅ | ✅ |
| `POST /auth/send-otp` | ✅ | ✅ | N/A | 🔴 Mock |
| `POST /auth/verify-otp` | ✅ | ✅ | N/A | 🔴 Mock |
| `POST /auth/logout` | ✅ | ✅ | ✅ | ✅ |
| `GET /users/me` | ✅ | ✅ | N/A | ✅ |
| `PUT /users/me` | 🟠 | ⬛ | N/A | ✅ |
| `GET /users/me/addresses` | 🟠 | N/A | N/A | ✅ |
| `POST /users/me/addresses` | 🟠 | N/A | N/A | ✅ |
| `PUT /users/me/addresses/{id}` | 🟠 | N/A | N/A | ✅ |
| `DELETE /users/me/addresses/{id}` | 🟠 | N/A | N/A | ✅ |
| `GET /categories` | ✅ | N/A | ✅ | ✅ |
| `POST /admin/categories` | N/A | N/A | ✅ | ✅ |
| `GET /products` | ✅ | N/A | ✅ | ✅ |
| `GET /products/{id}` | 🔴 | N/A | N/A | ⬛ Missing |
| `GET /cart` | 🟠 | N/A | N/A | ✅ |
| `POST /cart/items` | 🟠 | N/A | N/A | ✅ |
| `PUT /cart/items/{id}` | 🟠 | N/A | N/A | ✅ |
| `DELETE /cart/items/{id}` | 🟠 | N/A | N/A | ✅ |
| `GET /weekly-cart` | 🟠 | N/A | N/A | ✅ |
| `POST /weekly-cart` | 🟠 | N/A | N/A | ✅ |
| `POST /orders/checkout` | 🟠 | N/A | ⬛ | ✅ |
| `GET /orders` | 🟠 | N/A | ⬛ | ✅ |
| `GET /orders/{id}` | 🟠 | N/A | ⬛ | ✅ |
| `POST /orders/{id}/cancel` | 🟠 | N/A | N/A | ✅ |
| `POST /payments/initiate` | 🔴 | N/A | N/A | 🔴 Mock |
| `GET /tracking/order/{id}` | 🟠 | N/A | N/A | ✅ |
| `GET /subscriptions` | 🟠 | N/A | ⬛ | ✅ |
| `POST /subscriptions` | 🟠 | N/A | N/A | ✅ |
| `GET /prices/{productId}` | ⬛ | N/A | ✅ | ✅ |
| `GET /service-areas` | ⬛ | N/A | N/A | ✅ |
| `GET /admin/users` | N/A | N/A | ✅ | ✅ |
| `GET /farmers/listings` | N/A | 🔴 | ⬛ | ✅ |
| `POST /farmers/listings` | N/A | 🔴 | N/A | ✅ |
| `PUT /farmers/listings/{id}` | N/A | 🔴 | N/A | ✅ |
| `GET /farmers/me` | N/A | 🔴 | N/A | ✅ |
| `POST /kyc/*` | N/A | ⬛ | ⬛ | ⬛ |
| `GET /admin/kyc` | N/A | N/A | ⬛ | ⬛ |
| `POST /demands` | N/A | ⬛ | ⬛ | ⬛ |
| `GET /demands` | N/A | ⬛ | ⬛ | ⬛ |
| `POST /collections` | N/A | ⬛ | ⬛ | ⬛ |
| `GET /settlements` | N/A | ⬛ | ⬛ | ⬛ |
| `POST /settlements/authorize` | N/A | N/A | ⬛ | ⬛ |
| `GET /notifications` | ⬛ | ⬛ | ⬛ | ⬛ |

---

## Cross-Application Business Flows

### Flow 1: Customer Places Order → Farmer Fulfills
```
Customer App:                 Backend:               Farmer App:
1. Browse Catalog  ────────→ GET /products          ✅ Working
2. Add to Cart     ────────→ POST /cart/items       🟠 Working (fallback)
3. Checkout        ────────→ POST /orders/checkout  🟠 Working (fallback)
4. Pay             ────────→ POST /payments/initiate 🔴 MOCK ONLY
5. Order Confirmed ────────→ Order status = PLACED   ✅ Working
                                   ↓ (RabbitMQ event) ⬛ NOT IMPLEMENTED
                             Farmer sees new demand  ⬛ NOT CONNECTED
```

### Flow 2: Farmer Lists Produce → Visible to Customers
```
Farmer App:                   Backend:               Customer App:
1. Add Listing     ────────→ POST /farmers/listings  🔴 Mock in App
2. Admin Approves  ────────→ No approval flow        ⬛ NOT IMPLEMENTED
3. Listing active  ────────→ Available in catalog    ⬛ Not linked
4. Customer sees   ─────────← GET /products          ✅ But no farmer link
```

### Flow 3: KYC Submission → Admin Approval → Farmer Activated
```
Farmer App:                   Backend:               Admin Panel:
1. Submit KYC      ────────→ POST /kyc              ⬛ MISSING
2. Admin Reviews   ─────────← GET /admin/kyc        ⬛ MISSING
3. KYC Approved    ────────→ PUT /admin/kyc/approve  ⬛ MISSING
4. Farmer unlocked  ────────→ FARMER_VERIFIED role   ⬛ MISSING
```

### Flow 4: Order → Tracking → Delivery
```
Customer App:                 Backend:
1. Place Order     ────────→ POST /orders/checkout  🟠 Working
2. View Tracking   ────────→ GET /tracking/order/id 🟠 Working (seeded events)
3. Live Location   ────────→ WebSocket             ⬛ NOT IMPLEMENTED
4. Delivered       ────────→ Order status update    ⬛ Manual only
```

### Flow 5: Settlement → Farmer DBT Payment
```
Backend (Order + Payment):   Admin Panel:           Farmer App:
1. Order Paid      ────────→ Payment captured       🔴 Mock
                   ────────→ Settlement created      ⬛ NOT IMPLEMENTED
2. Admin authorizes─────────← PUT /settlements/auth ⬛ MISSING
3. DBT triggered   ────────→ Bank transfer          ⬛ NOT IMPLEMENTED
4. Farmer sees it  ─────────← GET /settlements      ⬛ MISSING
```

---

## Missing Integration Points (Priority Order)

| # | Missing Integration | Blocking Flow | Effort |
|---|--------------------|--------------| ------|
| 1 | Real OTP (MSG91/Twilio) | Auth | Medium |
| 2 | `GET /products/{id}` endpoint | Customer catalog | Low |
| 3 | KYC controller + entities | Farmer onboarding | High |
| 4 | Demand module full implementation | Order fulfillment | High |
| 5 | RabbitMQ event publishers | All async flows | Medium |
| 6 | Settlement controller | Farmer payment | High |
| 7 | Collection/Quality controller | Supply chain | High |
| 8 | FCM push notifications | User alerts | Medium |
| 9 | Admin orders endpoint | Admin operations | Medium |
| 10 | Farmer dashboard aggregation | Farmer UX | Low |
| 11 | Real payment gateway | Revenue | High |
| 12 | Farmer listings visible in catalog | Core marketplace | Medium |
