# MISSING_FEATURES_REPORT.md — All Gaps Identified

**Date:** 2026-11-25

This document lists every feature that is NOT yet production-ready, organized by priority.

---

## P0 — Blocking (Must Fix Before Any Testing)

### 1. Product REST Controller Missing
- **Backend:** `ProductService` exists but has no `@RestController`
- **Impact:** Customer App calls `GET /api/v1/products` but only `/admin/categories` proxies this
- **Fix:** Create `ProductController` with `GET /products`, `GET /products/{id}`, `GET /products?category={id}`

### 2. API Gateway Not Implemented
- **Impact:** All 3 frontend apps point directly to port 8080; no routing, no central JWT validation, no rate limiting
- **Fix:** Create Spring Cloud Gateway service routing all `/api/v1/*` to the monolith (phase 1) or microservices (phase 2)

### 3. Farmer API Missing REST Layer
- **Backend:** `FarmerController.java` exists but needs to be verified — many farmer endpoints called by Farmer App return mock data
- **Impact:** Farmer App is 100% mocked; farmers cannot submit real data
- **Fix:** Verify and complete `FarmerController` endpoints

---

## P1 — High Priority (Core Business Flows)

### 4. KYC Module — No Controller, No Entity
- Farmer App has 4 KYC screens; Admin panel has KYC review UI
- Backend has no KYC entity, controller, or service (just a stub)
- **Missing:** `KycDocument` entity, `KycController`, document upload endpoint, Admin review endpoint

### 5. Settlement Module — Stub Only
- Farmer settlements (DBT/bank transfer) are core to farmer engagement
- No entity, no controller, no payment-to-settlement flow
- **Missing:** `Settlement` entity, `SettlementController`, `POST /settlements/authorize`

### 6. Demand Module — Completely Missing
- Farmer App has demand request screens
- No `Demand` entity, controller, service, or database table
- **Missing:** Full demand module: create demand, list demands, accept demand

### 7. Collection Module — Stub Only
- Supply chain: gate pass, quality inspection, weighbridge, cold chain
- Backend has `CollectionService` stub, `QualityService` stub
- No entities, no controllers, no database tables
- **Missing:** `CollectionPoint` entity, `QualityInspection` entity, controllers

### 8. RabbitMQ — Zero Event Publishers
- `RabbitMqConfig.java` defines queues but no message is ever published
- Order placed → Farmer notified (never happens)
- Payment confirmed → Inventory updated (never happens)
- **Missing:** Event publishers in Order, Payment, KYC, Demand modules

### 9. Real Push Notifications
- `NotificationService` sends to local log only
- No FCM integration, no SMS OTP (always mock 123456)
- **Missing:** FCM device token registration endpoint, Firebase integration, SMS gateway (MSG91 / Twilio)

### 10. Payment Gateway Integration
- `MockPaymentProvider` always returns SUCCESS
- No Razorpay/UPI/NEFT integration
- **Missing:** Real payment gateway (Razorpay recommended), webhook handler

### 11. Farmer Dashboard Real Data
- Dashboard shows mock KPIs (earnings, active listings, demand count)
- No aggregation queries or analytics endpoints
- **Missing:** `GET /api/v1/farmers/me/dashboard` aggregation endpoint

---

## P2 — Medium Priority (Usability & Completeness)

### 12. Product Detail Endpoint
- `GET /api/v1/products/{id}` — not implemented
- Customer App falls back to in-memory list

### 13. Product Search & Filter on Backend
- Customer searches are client-side only
- **Missing:** `GET /api/v1/products?search=tomato&category=VEG&sort=price_low`

### 14. Admin Orders Endpoint
- Admin panel Order Management page is fully mocked
- **Missing:** `GET /api/v1/admin/orders` with filters and pagination

### 15. Admin KYC Endpoints
- Admin KYC review is mocked
- **Missing:** `GET /api/v1/admin/kyc`, `PUT /api/v1/admin/kyc/{id}/approve`, `PUT /api/v1/admin/kyc/{id}/reject`

### 16. Admin Farmer Management
- Admin farmer list uses `/admin/users` with FARMER role filter
- **Missing:** `GET /api/v1/admin/farmers` with FarmerProfile details

### 17. Kisan Wallet (Customer Prepaid Balance)
- Customer App has Kisan Wallet screen
- No wallet entity or balance management
- **Missing:** Wallet balance entity, credit/debit endpoints

### 18. Live GPS Tracking
- Customer App `LiveTrackingDetailScreen` shows map
- Delivery person GPS location not tracked
- **Missing:** WebSocket or SSE endpoint for real-time location updates

### 19. Tax Invoice Generation
- Customer App `TaxInvoiceScreen` exists
- No PDF generation endpoint
- **Missing:** `GET /api/v1/orders/{id}/invoice` → PDF response

### 20. Customer Support Tickets
- Customer App has raise ticket + live chat screens
- No ticket entity or support controller
- **Missing:** `SupportTicket` entity, `SupportController`, WebSocket for live chat

### 21. Govt Schemes Module
- Farmer App has scheme browsing screens
- `SchemeService` is a stub
- **Missing:** `Scheme` entity, `SchemeController`, scheme data seeding

### 22. Farmer Store Module
- Farmer App has store (buy inputs/seeds) screens
- `FarmerStoreService` is a stub
- **Missing:** Store product catalogue, cart, checkout for farmers

### 23. FPO (Farmer Producer Organization) Module
- Both Farmer and Admin Apps reference FPOs
- No FPO entity, controller, or database table
- **Missing:** `FPO` entity, `FpoController`, farmer-FPO association

### 24. Redis Caching
- Redis is configured but zero actual caching implemented
- Product catalogue, pricing lookups benefit from caching
- **Missing:** `@Cacheable` annotations on CatalogService, ProductService, PricingService

### 25. Forgot Password Flow
- All 3 apps have forgot password screens
- No `POST /auth/reset-password` endpoint
- **Missing:** OTP-based password reset endpoint

### 26. Refresh Token Usage
- `RefreshToken` entity and table exist (V9 migration)
- No `/auth/refresh` endpoint implemented
- Tokens expire after 24h with no auto-renewal
- **Missing:** `POST /api/v1/auth/refresh` endpoint

---

## P3 — Low Priority (Enhancements)

### 27. Analytics Dashboard (Admin)
- Admin analytics page is mocked
- **Missing:** Aggregation queries for orders, revenue, farmer activity

### 28. Bulk Buyer Module
- `BulkBuyerService` is a stub
- **Missing:** B2B demand listing, bulk order flow

### 29. Advisory / Weather API
- Farmer App has weather and crop advisory screens
- **Missing:** Weather API integration (OpenWeatherMap or IMD)

### 30. File Upload for Product Images
- `LocalStorageService` exists but no file upload endpoint exposed
- **Missing:** `POST /api/v1/files/upload` multipart endpoint

### 31. Mandi Price Feed Integration
- Farmer App shows mock mandi rates
- **Missing:** Integration with AGMARKNET or similar market price API
