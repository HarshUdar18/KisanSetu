# Kisan Setu — Customer API Integration

> Based on inspection of `backend/spring-boot-application` controllers and `docs/API.md`.
> All endpoints are prefixed with `/api/v1`. Missing backend endpoints use clearly isolated mock services in `lib/core/services/mock_services.dart`.

| Feature | Endpoint | Method | Auth | Status | Missing / Mock Notes |
|---|---|---|---|---|---|
| **Auth — Register** | `/auth/register` | POST | Public | Integrated | Triggers mock OTP (`123456` in dev) |
| **Auth — Login** | `/auth/login` | POST | Public | Integrated | Returns JWT + User DTO |
| **Auth — Request OTP** | `/auth/request-otp` | POST | Public | Integrated | Console / `123456` dev fallback |
| **Auth — Verify OTP** | `/auth/verify-otp` | POST | Public | Integrated | Returns JWT + User DTO |
| **Auth — Logout** | `/auth/logout` | POST | Bearer | Integrated | Clears secure storage |
| **Auth — Forgot/Reset Password** | `/auth/forgot-password` | POST | Public | Mock Fallback | Backend endpoint not yet implemented |
| **User — Profile** | `/users/me` | GET, PUT | Bearer | Integrated | `fullName`, `email`, `pincode`, `defaultDeliveryAddress` |
| **User — Security / Delete** | `/users/me/sessions`, `/users/me` | GET, DELETE | Bearer | Mock Fallback | Active sessions & account deletion mocked |
| **Service Areas** | `/service-areas`, `/service-areas/check?pinCode=` | GET | Public | Integrated | Pune pilot corridors (`411005`, `411035`, `411038`) |
| **Categories & Products** | `/categories`, `/products`, `/products/{id}` | GET | Public | Integrated | Filterable by `categoryId`, `search` |
| **Market Pricing** | `/prices`, `/prices/{productId}` | GET | Public | Integrated | Current & benchmark rates |
| **Shopping Cart** | `/cart`, `/cart/items`, `/cart/items/{id}` | GET, POST, PUT, DELETE | Bearer | Integrated | Auto-recalculates totals |
| **Addresses** | `/addresses`, `/addresses/{id}/default`, `/addresses/{id}` | GET, POST, DELETE | Bearer | Integrated | CRUD + default selection |
| **Weekly Cart** | `/weekly-carts`, `/weekly-carts/{id}`, `/weekly-carts/{id}/days`, `/submit`, `/modify` | GET, POST, PUT | Bearer | Integrated | Backend enforces single-edit rule (`409 Conflict` on 2nd edit) |
| **Subscriptions** | `/subscriptions`, `/subscriptions/{id}` | GET, POST | Bearer | Integrated + Mock | Pause/Resume/Edit/Cancel actions use mock fallback if endpoint absent |
| **Coupons** | `/coupons/validate` | POST | Bearer | Mock Fallback | `KISANFIRST`, `FRESH20`, `HARVEST50` validated via isolated mock |
| **Checkout & Orders** | `/orders/checkout`, `/orders`, `/orders/{id}` | GET, POST | Bearer | Integrated | Price locking on checkout |
| **Cancel Order & Invoice** | `/orders/{id}/cancel`, `/orders/{id}/invoice` | POST, GET | Bearer | Mock Fallback | Cancellation & harvest certificate use mock fallback |
| **Payments** | `/payments`, `/payments/{id}/verify` | POST | Bearer | Integrated | Supports `simulateSuccess` & `simulateFailure` |
| **9-Stage Tracking** | `/orders/{id}/tracking`, `/orders/{id}/tracking/dev-advance` | GET, POST | Bearer | Integrated | Real backend tracking events |
| **Notifications** | `/notifications`, `/notifications/preferences` | GET, PUT | Bearer | Mock Fallback | Local/mock notification centre & preferences |
| **Support & Wallet** | `/support/tickets`, `/wallet/ledger` | GET, POST | Bearer | Mock Fallback | Isolated mock service for UI completeness |
