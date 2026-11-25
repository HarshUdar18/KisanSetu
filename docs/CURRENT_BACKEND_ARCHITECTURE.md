# CURRENT_BACKEND_ARCHITECTURE.md

**Date:** 2026-11-25

## Overview

The Kisan Setu backend is currently a **monolithic Spring Boot application** deployed as a single JAR. It handles all business domains in one process sharing a single PostgreSQL database.

```
┌─────────────────────────────────────────────────────────────────┐
│                   KISAN SETU MONOLITH                           │
│               Spring Boot Application (Port 8080)               │
├─────────────────────────────────────────────────────────────────┤
│  Presentation Layer (REST Controllers)                          │
│  ┌──────────┐ ┌─────────┐ ┌──────────┐ ┌─────────┐ ┌───────┐  │
│  │AuthCtrl  │ │UserCtrl │ │CatalogCtrl│ │CartCtrl │ │OrderCtrl│ │
│  │AdminCtrl │ │PriceCtrl│ │ServiceArea│ │WeeklyCart│ │PayCtrl│ │
│  │FarmerCtrl│ │SubCtrl  │ │TrackCtrl  │ │          │ │       │  │
│  └──────────┘ └─────────┘ └──────────┘ └─────────┘ └───────┘  │
├─────────────────────────────────────────────────────────────────┤
│  Business Logic Layer (Services)                                │
│  Auth │ User │ Catalog │ Cart │ Order │ Payment │ Settlement    │
│  Tracking │ Pricing │ Farmer │ KYC(stub) │ Collection(stub)     │
│  Quality(stub) │ Inventory(stub) │ Notification(local) │ AI    │
├─────────────────────────────────────────────────────────────────┤
│  Data Access Layer (JPA Repositories)                           │
│  Flyway-managed schema │ PostgreSQL 16 PostGIS                  │
├─────────────────────────────────────────────────────────────────┤
│  Infrastructure                                                  │
│  Security: Spring Security + JWT (HS256, 24h expiry)           │
│  Docs: SpringDoc OpenAPI 3 at /swagger-ui.html                 │
│  Logging: RequestLoggingFilter + SLF4J                         │
│  Storage: LocalStorageService (filesystem)                      │
│  Messaging: RabbitMQ (configured, unused)                       │
│  Cache: Redis (configured, unused)                              │
└─────────────────────────────────────────────────────────────────┘
              │                        │
     ┌────────┴────────┐    ┌──────────┴──────────┐
     │   PostgreSQL 16  │    │      Redis 7         │
     │  kisansetu_db    │    │   (not used yet)     │
     │  (single DB)     │    └─────────────────────┘
     └─────────────────┘
              
     ┌─────────────────────────────────┐
     │        RabbitMQ 3.13             │
     │  Queues: defined, 0 messages     │
     └─────────────────────────────────┘
```

---

## Module Structure

```
com.kisansetu/
├── KisansetuBackendApplication.java       # @SpringBootApplication entry
├── common/
│   ├── config/
│   │   ├── CorsConfig.java               # CORS (wildcard * in dev)
│   │   ├── OpenApiConfig.java            # Swagger UI setup
│   │   ├── RabbitMqConfig.java           # Queue definitions (unused)
│   │   ├── RedisConfig.java              # Redis (unused)
│   │   └── SecurityConfig.java           # JWT filter, permit-all for public routes
│   ├── exception/                         # GlobalExceptionHandler, ApiException, etc.
│   ├── location/                          # LocationService, MockLocationService
│   ├── logging/                           # RequestLoggingFilter
│   ├── response/                          # ApiResponse<T>, PageResponse<T>
│   ├── security/                          # JwtService, JwtAuthenticationFilter, UserPrincipal
│   └── storage/                           # StorageService, LocalStorageService
└── modules/
    ├── admin/                             # AdminController, AdminService
    ├── ai/                                # AiService (stub)
    ├── audit/                             # AuditService, AuditLog entity
    ├── auth/                              # AuthController, MockAuthenticationProvider
    ├── bulkbuyer/                         # BulkBuyerService (stub)
    ├── cart/                              # CartController, WeeklyCartController, services, entities
    ├── catalog/                           # CatalogController, CatalogService, ProductCategory
    ├── collection/                        # CollectionService (stub)
    ├── customer/                          # CustomerController, AddressController, services, entities
    ├── delivery/                          # DeliveryService (stub)
    ├── farmer/                            # FarmerController, FarmerService, FarmerListingService
    ├── farmerstore/                       # FarmerStoreService (stub)
    ├── hub/                               # HubService (stub)
    ├── inventory/                         # InventoryService (stub)
    ├── marketplace/                       # MarketplaceService (stub)
    ├── notification/                      # NotificationService, LocalNotificationProvider
    ├── order/                             # OrderController, OrderService, entities
    ├── payment/                           # PaymentController, MockPaymentProvider, entities
    ├── payments/                          # PaymentService (duplicate module — to be merged)
    ├── pricing/                           # PricingController, PricingService, entities
    ├── product/                           # ProductService, Product entity (NO CONTROLLER)
    ├── quality/                           # QualityService (stub)
    ├── scheme/                            # SchemeService (stub)
    ├── servicearea/                       # ServiceAreaController, ServiceAreaService
    ├── settlement/                        # SettlementService (stub)
    ├── subscription/                      # SubscriptionController, SubscriptionService, entities
    ├── tracking/                          # TrackingController, TrackingService, TrackingEvent
    ├── user/                              # UserController, User, Role entities
    └── warehouse/                         # WarehouseService (stub)
```

---

## Database Tables (All in `public` schema, single DB `kisansetu_db`)

### V1–V6 Core Tables
- `users` — unified user table (customer, farmer, admin)
- `roles` — ROLE_ADMIN, ROLE_FARMER, ROLE_CUSTOMER
- `user_roles` — many-to-many join
- `farmer_profiles` — farmer-specific profile data
- `customer_profiles` — customer-specific profile data
- `service_areas` — pincode-based service coverage
- `audit_logs` — event audit trail

### V7 Customer Commerce Tables
- `addresses` — customer delivery addresses
- `product_categories` — 10 categories seeded in V8
- `products` — 20+ products seeded in V8
- `product_images` — product image gallery
- `market_prices` — current price per product (1:1 with product)
- `price_history` — price change log
- `carts` — one cart per user
- `cart_items` — items in cart (with quantity)
- `weekly_carts` — weekly subscription cart
- `weekly_cart_days` — per-day plan in weekly cart
- `weekly_cart_items` — items within each day plan
- `orders` — customer orders
- `order_items` — line items in order
- `payments` — payment record per order
- `payment_transactions` — transaction log
- `tracking_events` — order tracking timeline

### V9 Farmer Phase 2 Tables
- `farmer_listings` — farmer produce listings (FK to users + products)
- `refresh_tokens` — JWT refresh token storage

---

## Known Issues in Current Architecture

1. **Duplicate payment modules** — `modules/payment/` and `modules/payments/` both have PaymentService
2. **No ProductController** — ProductService is not exposed via REST
3. **Mock authentication provider** — `MockAuthenticationProvider` is active (not production auth)
4. **Single database** — All modules share one schema (no isolation)
5. **No circuit breakers** — Any DB failure brings down all features
6. **No horizontal scaling** — Single process, shared in-memory state
7. **Redis and RabbitMQ configured but unused** — Infrastructure waste
8. **Wildcard CORS** — Security risk for production
9. **JWT secret in config** — Should be in Vault/Secret Manager
10. **`ddl-auto: validate`** — Relies entirely on Flyway, good practice
