# AUTHORIZATION_MATRIX.md

**Date:** 2026-11-25

## Roles

| Role | Description | Assigned To |
|------|-------------|-------------|
| `ROLE_ADMIN` | Full platform management | Admin Panel users |
| `ROLE_FINANCE_ADMIN` | Settlement authorization | Finance team |
| `ROLE_SUPPORT_AGENT` | Support ticket management | Support team |
| `ROLE_ANALYTICS_VIEWER` | Read-only analytics | Analyst team |
| `ROLE_FARMER` | Produce listing, demand, collection | Registered farmers |
| `ROLE_CUSTOMER` | Browse, cart, order, track | Customers |
| `ROLE_DRIVER` | Update delivery location | Delivery partners |

---

## Endpoint Authorization Matrix

| Endpoint Category | ROLE_ADMIN | ROLE_FINANCE_ADMIN | ROLE_SUPPORT_AGENT | ROLE_ANALYTICS_VIEWER | ROLE_FARMER | ROLE_CUSTOMER | ROLE_DRIVER | Public |
|------------------|-----------|-------------------|-------------------|----------------------|------------|--------------|------------|--------|
| POST /auth/* | — | — | — | — | — | — | — | ✅ |
| GET /users/me | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| GET /admin/users | ✅ | — | ✅ | ✅ | — | — | — | — |
| GET /categories | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | ✅ |
| GET /products | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | ✅ |
| POST /products | ✅ | — | — | — | — | — | — | — |
| GET/PUT /prices/* | ✅ | ✅ | — | ✅ | ✅ | — | — | — |
| POST /produce | ✅ | — | — | — | ✅ | — | — | — |
| PUT /produce/{id} | ✅ | — | — | — | ✅ (own) | — | — | — |
| POST /kyc | — | — | — | — | ✅ | — | — | — |
| GET /admin/kyc | ✅ | — | — | — | — | — | — | — |
| PUT /admin/kyc/*/approve | ✅ | — | — | — | — | — | — | — |
| GET/POST /cart/* | — | — | — | — | — | ✅ | — | — |
| GET/POST /orders/* | ✅ | ✅ | ✅ | ✅ | — | ✅ (own) | — | — |
| GET /admin/orders | ✅ | ✅ | ✅ | ✅ | — | — | — | — |
| POST /payments/* | — | — | — | — | — | ✅ | — | — |
| POST /admin/settlements/*/authorize | — | ✅ | — | — | — | — | — | — |
| GET /settlements | ✅ | ✅ | — | — | ✅ (own) | — | — | — |
| POST /collections | ✅ | — | — | — | ✅ | — | — | — |
| POST /quality | ✅ | — | — | — | ✅ | — | — | — |
| GET/PUT /inventory/* | ✅ | — | — | ✅ | — | — | — | — |
| GET /tracking/* | ✅ | — | ✅ | — | ✅ | ✅ | ✅ | — |
| PUT /tracking/*/update | — | — | — | — | — | — | ✅ | — |
| POST /notifications/* | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| GET /support/tickets | ✅ | — | ✅ | — | ✅ (own) | ✅ (own) | — | — |
| POST /support/tickets | — | — | — | — | ✅ | ✅ | — | — |
| GET /analytics/* | ✅ | ✅ | — | ✅ | — | — | — | — |

---

## JWT Claims Structure

```json
{
  "sub": "user-uuid",
  "phone": "9876543211",
  "roles": ["ROLE_CUSTOMER"],
  "fullName": "Ananya Sharma",
  "iat": 1700000000,
  "exp": 1700086400
}
```

## Security Rules

1. **Ownership checks:** Farmers can only modify their own listings; Customers can only view their own orders
2. **KYC gating:** Farmers cannot create produce listings until `kycStatus = VERIFIED`
3. **Admin role hierarchy:** `ROLE_ADMIN` has all permissions except `ROLE_DRIVER`-specific endpoints
4. **Token expiry:** JWT access token = 24h; Refresh token = 30 days
5. **API Gateway validation:** JWT is validated at the gateway; services receive a pre-validated `X-User-Id` and `X-User-Roles` header
6. **Public endpoints:** `/auth/*`, `GET /categories`, `GET /products`, `GET /products/{id}`, `GET /service-areas`
