# SERVICE_ENDPOINT_MATRIX.md

**Date:** 2026-11-25

This matrix maps every API endpoint to its owning service, HTTP method, auth requirement, and implementation status.

---

## Status Legend
- ✅ Implemented in monolith
- 🆕 New — to be implemented
- 🔴 Mock only
- ⬛ Planned

| Method | Path | Service | Auth | Status |
|--------|------|---------|------|--------|
| POST | /auth/register | auth-service | Public | ✅ |
| POST | /auth/login | auth-service | Public | ✅ |
| POST | /auth/send-otp | auth-service | Public | 🔴 Mock |
| POST | /auth/verify-otp | auth-service | Public | 🔴 Mock |
| POST | /auth/logout | auth-service | Bearer | ✅ |
| POST | /auth/refresh | auth-service | Public (token) | ⬛ |
| POST | /auth/reset-password | auth-service | Public (OTP) | ⬛ |
| GET | /users/me | user-service | Bearer | ✅ |
| PUT | /users/me | user-service | Bearer | ✅ |
| DELETE | /users/me | user-service | Bearer | ⬛ |
| GET | /users/me/addresses | user-service | Bearer (CUSTOMER) | ✅ |
| POST | /users/me/addresses | user-service | Bearer (CUSTOMER) | ✅ |
| PUT | /users/me/addresses/{id} | user-service | Bearer (CUSTOMER) | ✅ |
| DELETE | /users/me/addresses/{id} | user-service | Bearer (CUSTOMER) | ✅ |
| GET | /farmers/me | farmer-service | Bearer (FARMER) | ✅ |
| PUT | /farmers/me | farmer-service | Bearer (FARMER) | ✅ |
| GET | /farmers/{id} | farmer-service | Bearer | 🆕 |
| GET | /farmers/me/dashboard | farmer-service | Bearer (FARMER) | ⬛ |
| POST | /kyc | kyc-service | Bearer (FARMER) | ⬛ |
| GET | /kyc/status | kyc-service | Bearer (FARMER) | ⬛ |
| GET | /categories | product-service | Public | ✅ |
| GET | /products | product-service | Public | ✅ |
| GET | /products/{id} | product-service | Public | ⬛ |
| POST | /products | product-service | Bearer (ADMIN) | ⬛ |
| PUT | /products/{id} | product-service | Bearer (ADMIN) | ⬛ |
| GET | /prices/{productId} | product-service | Bearer | ✅ |
| PUT | /prices/{productId} | product-service | Bearer (ADMIN) | ✅ |
| GET | /service-areas | product-service | Public | ✅ |
| GET | /produce | produce-service | Bearer | ✅ (listing) |
| POST | /produce | produce-service | Bearer (FARMER) | ✅ |
| GET | /produce/{id} | produce-service | Bearer | 🆕 |
| PUT | /produce/{id} | produce-service | Bearer (FARMER) | ✅ |
| DELETE | /produce/{id} | produce-service | Bearer (FARMER) | ⬛ |
| PUT | /produce/{id}/availability | produce-service | Bearer (FARMER) | ✅ |
| GET | /demands | demand-service | Bearer | ⬛ |
| POST | /demands | demand-service | Bearer | ⬛ |
| GET | /demands/{id} | demand-service | Bearer | ⬛ |
| PUT | /demands/{id}/accept | demand-service | Bearer (FARMER) | ⬛ |
| GET | /cart | cart-service | Bearer (CUSTOMER) | ✅ |
| DELETE | /cart | cart-service | Bearer (CUSTOMER) | ✅ |
| POST | /cart/items | cart-service | Bearer (CUSTOMER) | ✅ |
| PUT | /cart/items/{id} | cart-service | Bearer (CUSTOMER) | ✅ |
| DELETE | /cart/items/{id} | cart-service | Bearer (CUSTOMER) | ✅ |
| GET | /weekly-cart | cart-service | Bearer (CUSTOMER) | ✅ |
| POST | /weekly-cart | cart-service | Bearer (CUSTOMER) | ✅ |
| PUT | /weekly-cart/{id}/days/{day} | cart-service | Bearer (CUSTOMER) | ✅ |
| GET | /subscriptions | cart-service | Bearer (CUSTOMER) | ✅ |
| POST | /subscriptions | cart-service | Bearer (CUSTOMER) | ✅ |
| GET | /subscriptions/{id} | cart-service | Bearer (CUSTOMER) | ✅ |
| PUT | /subscriptions/{id}/pause | cart-service | Bearer (CUSTOMER) | ✅ |
| PUT | /subscriptions/{id}/resume | cart-service | Bearer (CUSTOMER) | ✅ |
| PUT | /subscriptions/{id}/schedule | cart-service | Bearer (CUSTOMER) | ✅ |
| DELETE | /subscriptions/{id} | cart-service | Bearer (CUSTOMER) | ✅ |
| POST | /orders/checkout | order-service | Bearer (CUSTOMER) | ✅ |
| GET | /orders | order-service | Bearer (CUSTOMER) | ✅ |
| GET | /orders/{id} | order-service | Bearer | ✅ |
| POST | /orders/{id}/cancel | order-service | Bearer (CUSTOMER) | ✅ |
| GET | /orders/{id}/invoice | order-service | Bearer (CUSTOMER) | ⬛ |
| POST | /payments/initiate | payment-service | Bearer (CUSTOMER) | 🔴 Mock |
| GET | /payments/{id} | payment-service | Bearer | 🔴 Mock |
| POST | /payments/webhook | payment-service | Public (sig) | ⬛ |
| POST | /admin/payments/{id}/refund | payment-service | Bearer (ADMIN) | ⬛ |
| GET | /settlements | settlement-service | Bearer (FARMER) | ⬛ |
| GET | /settlements/{id} | settlement-service | Bearer | ⬛ |
| POST | /admin/settlements/{id}/authorize | settlement-service | Bearer (ADMIN) | ⬛ |
| POST | /collections | collection-service | Bearer | ⬛ |
| GET | /collections/{id} | collection-service | Bearer | ⬛ |
| POST | /quality | quality-service | Bearer | ⬛ |
| GET | /quality/{id} | quality-service | Bearer | ⬛ |
| GET | /inventory | inventory-service | Bearer (ADMIN) | ⬛ |
| PUT | /inventory/{productId} | inventory-service | Bearer (ADMIN) | ⬛ |
| GET | /tracking/order/{orderId} | logistics-service | Bearer | ✅ |
| PUT | /tracking/{id}/update | logistics-service | Bearer (DRIVER) | ⬛ |
| POST | /notifications/register-token | notification-service | Bearer | ⬛ |
| GET | /notifications | notification-service | Bearer | ⬛ |
| PUT | /notifications/{id}/read | notification-service | Bearer | ⬛ |
| GET | /notifications/preferences | notification-service | Bearer | ⬛ |
| PUT | /notifications/preferences | notification-service | Bearer | ⬛ |
| POST | /support/tickets | support-service | Bearer | ⬛ |
| GET | /support/tickets | support-service | Bearer | ⬛ |
| GET | /support/tickets/{id} | support-service | Bearer | ⬛ |
| POST | /support/tickets/{id}/reply | support-service | Bearer | ⬛ |
| GET | /analytics/dashboard | analytics-service | Bearer (ADMIN) | ⬛ |
| GET | /analytics/revenue | analytics-service | Bearer (ADMIN) | ⬛ |
| GET | /admin/users | user-service | Bearer (ADMIN) | ✅ |
| GET | /admin/farmers | farmer-service | Bearer (ADMIN) | ⬛ |
| GET | /admin/kyc | kyc-service | Bearer (ADMIN) | ⬛ |
| PUT | /admin/kyc/{id}/approve | kyc-service | Bearer (ADMIN) | ⬛ |
| PUT | /admin/kyc/{id}/reject | kyc-service | Bearer (ADMIN) | ⬛ |
| GET | /admin/orders | order-service | Bearer (ADMIN) | ⬛ |
| GET | /admin/categories | product-service | Bearer (ADMIN) | ✅ |
| POST | /admin/categories | product-service | Bearer (ADMIN) | ✅ |

**Summary:**
- ✅ Implemented: 35 endpoints
- 🔴 Mock only: 3 endpoints  
- ⬛ Not implemented: 42 endpoints
- 🆕 New variants needed: 2 endpoints
