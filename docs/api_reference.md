# KisanSetu API Reference (v1)

Base URL: `http://localhost:8080/api/v1`

Interactive Swagger Documentation: `http://localhost:8080/swagger-ui.html`

All requests and responses use standard JSON format with UTF-8 encoding.

---

## 1. System Health

### `GET /api/v1/health`
Public health status check.
* **Authentication**: None
* **Sample Response (200 OK)**:
```json
{
  "success": true,
  "message": "KisanSetu backend is healthy and running",
  "data": {
    "status": "UP",
    "service": "kisansetu-backend",
    "phase": "PHASE_0",
    "version": "v1.0.0",
    "serverTime": "2026-09-28T15:00:00Z"
  },
  "timestamp": "2026-09-28T15:00:00Z"
}
```

---

## 2. Authentication

### `POST /api/v1/auth/login`
Authenticates a user via 10-digit Indian phone or email and password.
* **Authentication**: None
* **Request Body**:
```json
{
  "identifier": "9876543211",
  "password": "password123"
}
```
* **Sample Response (200 OK)**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "type": "Bearer",
    "userId": "a0000000-0000-0000-0000-000000000002",
    "identifier": "9876543211",
    "role": "ROLE_CUSTOMER",
    "expiresInMs": 86400000
  },
  "timestamp": "2026-09-28T15:00:00Z"
}
```

### `POST /api/v1/auth/register/customer`
Registers a new customer and initializes their baseline delivery profile.
* **Authentication**: None
* **Request Body**:
```json
{
  "phone": "9876543220",
  "fullName": "Sunita Sharma",
  "password": "securePassword123",
  "email": "sunita@example.com",
  "defaultDeliveryAddress": "Plot 12, Koramangala 4th Block, Bengaluru",
  "pincode": "560034"
}
```
* **Sample Response (201 Created)**: Returns signed JWT and user session payload.

---

## 3. Customer Module (Phase 1 Foundation)

### `GET /api/v1/customer/profile`
Retrieves customer profile and default delivery addresses.
* **Authentication**: Bearer JWT (`ROLE_CUSTOMER` or `ROLE_ADMIN`)
* **Headers**: `Authorization: Bearer <token>`
* **Sample Response (200 OK)**:
```json
{
  "success": true,
  "message": "Customer profile retrieved successfully",
  "data": {
    "id": "b0000000-0000-0000-0000-000000000001",
    "userId": "a0000000-0000-0000-0000-000000000002",
    "fullName": "Ramesh Kumar (Customer)",
    "phone": "9876543211",
    "email": "customer@kisansetu.com",
    "defaultDeliveryAddress": "Flat 402, Green Meadows Apt, Indiranagar, Bengaluru",
    "pincode": "560038",
    "latitude": 12.9784,
    "longitude": 77.6408,
    "createdAt": "2026-09-28T14:50:00Z"
  }
}
```

### `PUT /api/v1/customer/profile`
Updates delivery address and contact info.
* **Authentication**: Bearer JWT (`ROLE_CUSTOMER` or `ROLE_ADMIN`)
* **Headers**: `Authorization: Bearer <token>`
* **Request Body**:
```json
{
  "fullName": "Ramesh Kumar",
  "defaultDeliveryAddress": "Villa 15, Palm Meadows, Whitefield, Bengaluru",
  "pincode": "560066"
}
```

### `GET /api/v1/customer/serviceability?pincode=560038`
Checks delivery availability for a postal PIN code.
* **Authentication**: Bearer JWT or Public
* **Sample Response (200 OK)**:
```json
{
  "success": true,
  "message": "Serviceability details",
  "data": {
    "pincode": "560038",
    "isServiceable": true,
    "estimatedDeliveryHours": 24,
    "directFromFarmAvailable": true,
    "hubAssigned": "Central-Agri-Hub-01"
  }
}
```
