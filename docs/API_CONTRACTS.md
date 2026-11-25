# API_CONTRACTS.md — Kisan Setu API Contracts

**Date:** 2026-11-25  
**Base URL:** `http://localhost:8080/api/v1`  
**Auth:** `Authorization: Bearer <JWT>` for all protected routes

---

## Standard Response Envelope

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { },
  "timestamp": "2026-11-25T10:00:00Z"
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Descriptive error message",
  "code": "ERROR_CODE",
  "details": { },
  "timestamp": "2026-11-25T10:00:00Z"
}
```

---

## 1. Auth Service (`/api/v1/auth`)

### POST /auth/register
```json
// Request
{ "fullName": "Ananya Sharma", "phone": "9876543211", "email": "ananya@example.com", "password": "Secure@123", "role": "CUSTOMER" }
// Response 201
{ "token": "eyJ...", "user": { "id": "uuid", "fullName": "Ananya Sharma", "phone": "9876543211", "roles": ["ROLE_CUSTOMER"] } }
```

### POST /auth/login
```json
// Request
{ "identifier": "9876543211", "password": "Secure@123" }
// Response 200
{ "token": "eyJ...", "user": { "id": "uuid", "fullName": "Ananya Sharma", "roles": ["ROLE_CUSTOMER"] } }
```

### POST /auth/send-otp
```json
// Request
{ "phone": "9876543211" }
// Response 200
{ "challengeId": "uuid", "phone": "9876543211", "expiresInSeconds": 300 }
```

### POST /auth/verify-otp
```json
// Request
{ "phone": "9876543211", "otp": "123456" }
// Response 200
{ "token": "eyJ...", "user": { "id": "uuid", "fullName": "Ananya Sharma", "roles": ["ROLE_CUSTOMER"] } }
```

### POST /auth/refresh
```json
// Request
{ "refreshToken": "eyJ..." }
// Response 200
{ "token": "eyJ...", "refreshToken": "eyJ..." }
```

### POST /auth/logout
```json
// Request: Authorization header only
// Response 200
{ "success": true, "message": "Logged out successfully" }
```

---

## 2. User Service (`/api/v1/users`)

### GET /users/me *(Protected)*
```json
// Response 200
{ "id": "uuid", "fullName": "Ananya Sharma", "phone": "9876543211", "email": "ananya@example.com", "roles": ["ROLE_CUSTOMER"] }
```

### PUT /users/me *(Protected)*
```json
// Request
{ "fullName": "Ananya Sharma", "email": "new@example.com", "pincode": "411001" }
// Response 200: Updated user object
```

### GET /users/me/addresses *(Protected)*
```json
// Response 200
{ "data": [{ "id": "uuid", "label": "Home", "addressLine1": "123 Peth", "city": "Pune", "state": "Maharashtra", "pincode": "411001", "isDefault": true }] }
```

### POST /users/me/addresses *(Protected)*
```json
// Request
{ "label": "Home", "addressLine1": "123 Peth", "city": "Pune", "pincode": "411001", "latitude": 18.52, "longitude": 73.85 }
// Response 201: Created address object
```

---

## 3. Farmer Service (`/api/v1/farmers`)

### GET /farmers/me *(FARMER role)*
```json
// Response 200
{ "id": "uuid", "userId": "uuid", "fullName": "Tukaram Patil", "phone": "9876543212", "village": "Khed", "district": "Pune", "state": "Maharashtra", "pincode": "412205", "kycStatus": "VERIFIED", "fpoId": null }
```

### PUT /farmers/me *(FARMER role)*
```json
// Request
{ "village": "Khed", "district": "Pune", "pincode": "412205", "bankAccountNumber": "XXXXXX", "ifscCode": "SBIN0001234" }
```

### GET /farmers/{farmerId} *(Protected — Public Profile)*
```json
// Response 200
{ "id": "uuid", "fullName": "Tukaram Patil", "village": "Khed", "district": "Pune", "producedCategories": ["Vegetables", "Grains"], "rating": 4.7, "totalListings": 12 }
```

---

## 4. KYC Service (`/api/v1/kyc`)

### POST /kyc *(FARMER role)*
```json
// Request (multipart/form-data)
{ "documentType": "AADHAAR", "documentNumber": "XXXX-XXXX-1234", "file": <binary>, "selfieFile": <binary> }
// Response 201
{ "submissionId": "uuid", "status": "UNDER_REVIEW", "message": "Documents submitted for review" }
```

### GET /kyc/status *(FARMER role)*
```json
// Response 200
{ "status": "VERIFIED", "submittedAt": "2026-11-01T10:00:00Z", "reviewedAt": "2026-11-02T12:00:00Z", "remarks": null }
```

### GET /admin/kyc *(ADMIN role)*
```json
// Query params: ?status=UNDER_REVIEW&page=0&size=20
// Response 200: Paginated list of KYC submissions
```

### PUT /admin/kyc/{id}/approve *(ADMIN role)*
```json
// Request
{ "remarks": "Documents verified successfully" }
// Response 200: Updated KYC submission
```

---

## 5. Product Service (`/api/v1`)

### GET /categories
```json
// Response 200
{ "data": [{ "id": "uuid", "name": "Fresh Veggies", "code": "VEG", "description": "...", "displayOrder": 1, "productCount": 12 }] }
```

### GET /products
```json
// Query params: ?category={categoryId}&search={query}&sort=price_low&organic=true&page=0&size=20
// Response 200: Paginated product list
```

### GET /products/{id}
```json
// Response 200
{ "id": "uuid", "name": "Desi Tomatoes", "marathiName": "देशी टोमॅटो", "categoryId": "uuid", "unit": "kg", "currentPrice": 32.50, "previousPrice": 28.00, "isOrganic": true, "isAvailable": true, "stockQuantity": 450.0, "imageUrl": "...", "description": "..." }
```

### GET /prices/{productId} *(Protected)*
```json
// Response 200
{ "productId": "uuid", "currentPrice": 32.50, "previousPrice": 28.00, "effectiveFrom": "2026-11-25T06:00:00Z" }
```

### PUT /prices/{productId} *(ADMIN role)*
```json
// Request
{ "newPrice": 35.00 }
// Response 200: Updated price object
```

---

## 6. Produce Service (`/api/v1/produce`)

### GET /produce *(Protected)*
```json
// Query params: ?productId={id}&farmerId={id}&status=ACTIVE
// Response 200: Paginated farmer listings
```

### POST /produce *(FARMER role)*
```json
// Request
{ "productId": "uuid", "quantityAvailable": 500.0, "unit": "kg", "pricePerUnit": 28.00, "harvestDate": "2026-11-26", "description": "Fresh A-grade tomatoes", "qualityGrade": "GRADE_A" }
// Response 201: Created listing
```

### PUT /produce/{id} *(FARMER role, owns listing)*
```json
// Request: Same fields as POST, partial update
// Response 200: Updated listing
```

---

## 7. Demand Service (`/api/v1/demands`)

### GET /demands *(Protected)*
```json
// FARMER: sees demands matching their produce; ADMIN: sees all
// Response 200: Paginated demand list
```

### POST /demands *(Protected — creates demand request)*
```json
// Request
{ "productId": "uuid", "quantityKg": 100.0, "targetPricePerKg": 30.00, "requiredByDate": "2026-12-01", "notes": "Need A-grade only" }
// Response 201: Created demand
```

### PUT /demands/{id}/accept *(FARMER role)*
```json
// Request
{ "offeredPricePerKg": 29.00, "availableQuantityKg": 80.0, "deliveryDate": "2026-11-28" }
// Response 200: Updated demand with acceptance
```

---

## 8. Cart Service (`/api/v1/cart`)

### GET /cart *(CUSTOMER role)*
```json
// Response 200
{ "id": "uuid", "userId": "uuid", "items": [{ "id": "uuid", "productId": "uuid", "productName": "Desi Tomatoes", "quantity": 2.0, "unit": "kg", "pricePerUnit": 32.50, "subtotal": 65.00 }], "subtotal": 65.00, "platformFee": 2.50, "deliveryCharge": 20.00, "estimatedTotal": 87.50 }
```

### POST /cart/items *(CUSTOMER role)*
```json
// Request
{ "productId": "uuid", "quantity": 2.0 }
// Response 200: Updated cart
```

---

## 9. Order Service (`/api/v1/orders`)

### POST /orders/checkout *(CUSTOMER role)*
```json
// Request
{ "addressId": "uuid", "deliveryDate": "2026-11-26", "deliverySlot": "MORNING_6_9", "deliveryNotes": "Call before delivery" }
// Response 201
{ "id": "uuid", "orderNumber": "KS-2045", "status": "PENDING_PAYMENT", "totalAmount": 87.50, "paymentUrl": "/api/v1/payments/initiate?orderId=uuid" }
```

### GET /orders *(CUSTOMER role)*
```json
// Response 200: Paginated order list (most recent first)
```

### GET /admin/orders *(ADMIN role)*
```json
// Query params: ?status=PENDING&farmerId={id}&customerId={id}&dateFrom=2026-11-01
// Response 200: Paginated admin order list with full details
```

---

## 10. Payment Service (`/api/v1/payments`)

### POST /payments/initiate *(CUSTOMER role)*
```json
// Request
{ "orderId": "uuid", "method": "UPI", "upiId": "ananya@upi" }
// Response 200
{ "paymentId": "uuid", "razorpayOrderId": "order_xxx", "amount": 87.50, "currency": "INR", "keyId": "rzp_key_xxx" }
```

### POST /payments/webhook *(Public — Razorpay signature verified)*
```json
// Razorpay webhook payload (signature in header X-Razorpay-Signature)
// Response 200: "OK"
```

---

## 11. Settlement Service (`/api/v1/settlements`)

### GET /settlements *(FARMER role)*
```json
// Response 200: List of settlements due to this farmer
```

### GET /settlements/{id} *(FARMER or ADMIN role)*
```json
// Response 200: Settlement details with order breakdown
```

### POST /admin/settlements/{id}/authorize *(ADMIN role — Finance)*
```json
// Request
{ "authorizedBy": "admin-uuid", "remarks": "Verified bank account" }
// Response 200: Settlement status = AUTHORIZED → triggers DBT
```

---

## 12. Tracking / Logistics (`/api/v1/tracking`)

### GET /tracking/order/{orderId} *(CUSTOMER role)*
```json
// Response 200
{ "orderId": "uuid", "currentStatus": "OUT_FOR_DELIVERY", "events": [{ "status": "PLACED", "title": "Order Placed", "occurredAt": "...", "isCompleted": true }] }
```

### WebSocket /ws/tracking/{orderId} *(CUSTOMER role)*
```
// Messages: { "lat": 18.52, "lng": 73.85, "updatedAt": "..." }
```
