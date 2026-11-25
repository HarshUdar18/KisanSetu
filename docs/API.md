# REST API Reference Specification

## Base URLs
- **Local Spring Boot API**: `http://localhost:8080/api/v1`
- **Swagger UI Interactive Documentation**: `http://localhost:8080/swagger-ui/index.html`
- **OpenAPI v3 JSON Spec**: `http://localhost:8080/v3/api-docs`

---

## Global Headers & Standards

All requests return a `X-Request-ID` correlation identifier in response headers.

### Error Response Contract
All error responses adhere to standard JSON error format:
```json
{
  "code": "VALIDATION_ERROR",
  "message": "Invalid request parameters",
  "requestId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "timestamp": "2026-09-28T20:45:00Z",
  "fieldErrors": {
    "phoneNumber": "Phone number must be exactly 10 digits"
  }
}
```

---

## Authentication & Authorization Endpoints

### 1. Register User
`POST /api/v1/auth/register`

Creates a new user and triggers mock OTP delivery.
- **Request Body**:
```json
{
  "phoneNumber": "9876543299",
  "fullName": "Suresh Patil",
  "email": "suresh@example.com",
  "password": "Password123!",
  "role": "FARMER"
}
```
- **Response**: `201 Created`
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": "c1f7b0a8-3f5e-4b2a-9e1d-8f2a7b3c4d5e",
    "phoneNumber": "9876543299",
    "email": "suresh@example.com",
    "fullName": "Suresh Patil",
    "status": "ACTIVE",
    "roles": ["ROLE_FARMER"]
  },
  "message": "User registered successfully"
}
```

### 2. Login with Password
`POST /api/v1/auth/login`
- **Request Body**:
```json
{
  "phoneNumber": "9876543211",
  "password": "password123"
}
```
- **Response**: `200 OK`
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": "e0b5774e-5e7e-49b8-9fa5-e8d11c0f0a02",
    "phoneNumber": "9876543211",
    "email": "customer@kisansetu.local",
    "fullName": "Ananya Sharma",
    "status": "ACTIVE",
    "roles": ["ROLE_CUSTOMER"]
  },
  "message": "Login successful"
}
```

### 3. Request OTP
`POST /api/v1/auth/request-otp`
- **Request Body**:
```json
{
  "phoneNumber": "9876543211"
}
```
- **Response**: `200 OK`
```json
{
  "status": "SUCCESS",
  "message": "OTP sent successfully to 9876543211"
}
```

### 4. Verify OTP
`POST /api/v1/auth/verify-otp`
- **Request Body**:
```json
{
  "phoneNumber": "9876543211",
  "otp": "123456"
}
```
- **Response**: `200 OK` (returns JWT and User DTO)

### 5. Logout
`POST /api/v1/auth/logout`
- **Headers**: `Authorization: Bearer <TOKEN>`
- **Response**: `200 OK`

---

## User & Profile Endpoints

### 1. Get Current User Profile
`GET /api/v1/users/me`
- **Headers**: `Authorization: Bearer <TOKEN>`
- **Response**: `200 OK`
```json
{
  "id": "e0b5774e-5e7e-49b8-9fa5-e8d11c0f0a02",
  "phoneNumber": "9876543211",
  "email": "customer@kisansetu.local",
  "fullName": "Ananya Sharma",
  "status": "ACTIVE",
  "roles": ["ROLE_CUSTOMER"]
}
```

---

## Service Areas Endpoints

### 1. List Active Service Areas
`GET /api/v1/service-areas`
- **Response**: `200 OK`
```json
[
  {
    "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "name": "Shivajinagar",
    "city": "Pune",
    "state": "Maharashtra",
    "pinCode": "411005",
    "latitude": 18.5314,
    "longitude": 73.8446,
    "radiusKm": 5.0,
    "status": "ACTIVE"
  },
  {
    "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12",
    "name": "Akurdi",
    "city": "Pune",
    "state": "Maharashtra",
    "pinCode": "411035",
    "latitude": 18.6495,
    "longitude": 73.7707,
    "radiusKm": 6.0,
    "status": "ACTIVE"
  }
]
```

### 2. Check Serviceability by Postal Code
`GET /api/v1/service-areas/check?pinCode=411005`
- **Response**: `200 OK`
```json
{
  "serviceable": true,
  "serviceArea": {
    "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "name": "Shivajinagar",
    "pinCode": "411005"
  }
}
```

---

## Health & Diagnostics Endpoints

### 1. General Application Health
`GET /api/v1/health`
- **Response**: `200 OK`
```json
{
  "status": "UP",
  "service": "kisansetu-backend",
  "timestamp": "2026-09-28T20:45:00Z",
  "phase": "PHASE_0"
}
```

### 2. Infrastructure Health (Database, Redis, RabbitMQ)
`GET /api/v1/health/infrastructure`
- **Response**: `200 OK`
```json
{
  "database": "UP",
  "redis": "UP",
  "rabbitMq": "UP"
}
```

---

## Customer Application Endpoints (Phase 1)

### 1. Categories & Catalog
- `GET /api/v1/categories`: Retrieve all active product categories.
- `GET /api/v1/products`: Retrieve products with live market pricing, filterable by `categoryId` and `search`.
- `GET /api/v1/products/{id}`: Detailed product information with current market rate and historical price trend.

### 2. Live Shopping Basket (Normal Cart)
- `GET /api/v1/cart`: Current authenticated user's basket recalculated against latest market prices.
- `POST /api/v1/cart/items`: Add produce item (`productId`, `quantity`).
- `PUT /api/v1/cart/items/{id}`: Update quantity with automatic re-pricing.
- `DELETE /api/v1/cart/items/{id}`: Remove item from cart.
- `DELETE /api/v1/cart`: Clear entire cart.

### 3. Weekly Cart Planning & Single-Modification Rule
- `GET /api/v1/weekly-carts`: List user's weekly planned carts.
- `POST /api/v1/weekly-carts`: Create new weekly basket plan (`title`).
- `GET /api/v1/weekly-carts/{id}`: Get day-by-day item distribution (Monday - Sunday).
- `PUT /api/v1/weekly-carts/{id}/days`: Assign/update products for a specific day of week.
- `POST /api/v1/weekly-carts/{id}/submit`: Lock initial draft, sets status `SUBMITTED`, `modificationCount = 0`.
- `POST /api/v1/weekly-carts/{id}/modify`: Allows customer to modify weekly cart **exactly ONCE**. Sets status `LOCKED`, `modificationCount = 1`. Any subsequent call returns `HTTP 409 Conflict` (`WEEKLY_CART_MODIFICATION_LIMIT_REACHED`).

### 4. Farm Subscriptions
- `GET /api/v1/subscriptions`: View active and scheduled recurring farm delivery plans.
- `POST /api/v1/subscriptions`: Create subscription from weekly cart plan (`weeklyCartId`, `addressId`, `frequency`, `startDate`, `deliveryPreferences`).

### 5. Checkout & Price Locking
- `POST /api/v1/orders/checkout`: Validates address, delivery date, slot, notes, locks current market prices, creates order in `PENDING_PAYMENT` state.
- `GET /api/v1/orders`: List customer's orders (with items and immutable locked unit prices).
- `GET /api/v1/orders/{id}`: Detailed view of a single order.

### 6. Local Mock Payment Gateway
- `POST /api/v1/payments`: Initiate payment (`orderId`, `amount`, `paymentMethod`).
- `POST /api/v1/payments/{paymentId}/verify`: Mock verification simulator.
  - Body: `{"paymentReference": "...", "action": "simulateSuccess"}` -> Transitions order to `PAID` / `CONFIRMED`, triggers tracking event generation.
  - Body: `{"paymentReference": "...", "action": "simulateFailure"}` -> Marks payment failed, preserves order for retry.

### 7. 9-Stage Supply Chain Tracking
- `GET /api/v1/orders/{orderId}/tracking`: Returns timeline with all 9 supply chain milestones (`ORDER_CONFIRMED` -> `DELIVERED`).
- `POST /api/v1/orders/{orderId}/tracking/dev-advance`: **(Development Only)** Advances the mock supply chain milestone to the next sequential stage for rapid local testing.

### 8. Customer Address Management
- `GET /api/v1/addresses`: List saved delivery addresses.
- `POST /api/v1/addresses`: Create address (`label`, `line1`, `line2`, `city`, `state`, `pincode`, `lat`, `lng`, `isDefault`).
- `POST /api/v1/addresses/{id}/default`: Set default address.
- `DELETE /api/v1/addresses/{id}`: Remove address.

---

## Phase 2 Modules & Endpoints

### 1. User Management
- `GET /api/v1/users/me`: Current authenticated user's profile with roles, email, phone, name, and address.
- `PUT /api/v1/users/me`: Update profile details (`fullName`, `defaultDeliveryAddress`, `pincode`, `email`).

### 2. Farmer Produce Listings
- `POST /api/v1/farmer/listings`: Create produce listing (`productId`, `quantityAvailable`, `unit`, `pricePerUnit`, `harvestDate`, `description`, `qualityGrade`). Restricted to `ROLE_FARMER` or `ROLE_ADMIN`.
- `GET /api/v1/farmer/listings`: Retrieve all produce listings created by the authenticated farmer.
- `GET /api/v1/farmer/listings/{id}`: Retrieve a specific produce listing.
- `PUT /api/v1/farmer/listings/{id}`: Update listing quantity, price, unit, or quality grade. Enforces strict farmer ownership (returns `403 Forbidden` if another farmer attempts update).
- `PATCH /api/v1/farmer/listings/{id}/availability`: Fast toggle for availability status (`isAvailable`, optional new `quantityAvailable`).

### 3. Market Pricing
- `GET /api/v1/prices/{productId}`: Public endpoint to retrieve current applicable market rate and previous price benchmark.
- `GET /api/v1/prices`: Public endpoint listing all current applicable product market prices.
- `PUT /api/v1/prices/{productId}`: Admin-only endpoint (`ROLE_ADMIN`) to update authoritative market rate and append to historical audit records.

### 4. Admin Management (ROLE_ADMIN Only)
- `GET /api/v1/admin/users`: List all platform users with account status and assigned roles.
- `POST /api/v1/admin/categories`: Create new product category in master catalog (`name`, `code`, `description`, `iconUrl`, `displayOrder`).
- `GET /api/v1/admin/categories`: List all categories for administrative oversight.


