# High-Level Architecture Specification

## 1. System Overview

KisanSetu is a direct Farmer-to-Customer Agricultural Supply Chain platform designed to streamline fresh farm produce distribution from field to doorstep.

```
+-----------------------------------------------------------------------------------------------+
|                                      CLIENT LAYER                                             |
|                                                                                               |
|   +--------------------------+  +--------------------------+  +---------------------------+   |
|   |   CUSTOMER FLUTTER APP   |  |    FARMER FLUTTER APP    |  |     ADMIN WEB PANEL       |   |
|   |    (Clean Architecture)  |  |   (Clean Architecture)   |  |   (React 19 + TypeScript) |   |
|   +------------+-------------+  +------------+-------------+  +-------------+-------------+   |
+----------------|-----------------------------|------------------------------|-----------------+
                 |                             |                              |
                 +-----------------------------+------------------------------+
                                               |
                                     HTTPS REST / WebSocket
                                               |
+----------------------------------------------v------------------------------------------------+
|                                    BACKEND CORE                                               |
|                                                                                               |
|                          SPRING BOOT MODULAR MONOLITH                                         |
|                                                                                               |
|   +---------------------------------------------------------------------------------------+   |
|   | Security & Auth Layer (JWT, RBAC, Mock OTP, Audit Interceptor)                        |   |
|   +---------------------------------------------------------------------------------------+   |
|   | 26 Boundary Modules:                                                                  |   |
|   | auth, user, customer, farmer, product, catalog, pricing, cart, subscription,          |   |
|   | order, payment, collection, quality, warehouse, inventory, hub, delivery,             |   |
|   | tracking, marketplace, bulkbuyer, settlement, notification, scheme, farmerstore,      |   |
|   | admin, audit                                                                          |   |
|   +---------------------------------------------------------------------------------------+   |
|   | Infrastructure Abstractions:                                                          |   |
|   | - AuthenticationProvider (MockAuthenticationProvider)                                 |   |
|   | - PaymentProvider        (MockPaymentProvider)                                        |   |
|   | - LocationService        (MockLocationService)                                        |   |
|   | - NotificationService    (LocalNotificationProvider)                                  |   |
|   | - StorageService         (LocalStorageService)                                        |   |
|   +---------------------------------------------------------------------------------------+   |
+-----------------------+----------------------+-----------------------+------------------------+
                        |                      |                       |
                        v                      v                       v
               +-----------------+    +-----------------+    +-------------------+
               |  PostgreSQL 16  |    |     Redis 7     |    |   RabbitMQ 3.13   |
               | (PostGIS-Ready) |    |  (Cache & Rate) |    |  (Event Exchange) |
               +-----------------+    +-----------------+    +-------------------+
```

---

## 2. Core Architectural Decisions

### Separation of Mobile Applications
- **Customer Mobile App** (`apps/customer-app`): Tailored for grocery consumers with product discovery, weekly recurring basket scheduling, cart management, and real-time delivery tracking.
- **Farmer Mobile App** (`apps/farmer-app`): Tailored for agricultural producers with farm inventory declaration, demand forecasting, collection center scheduling, and direct settlement ledgers.
- **Strict Rule**: They are two completely independent Flutter applications with independent packages, navigation routers, state management, and design themes. They share no UI code.

### Modular Monolith Backend
- Implemented in Spring Boot 3.3.5 / Java 17.
- Packaged by domain boundary (`com.kisansetu.platform.modules.*`).
- Avoids the operational overhead, network latency, distributed transactions, and RAM consumption of microservices on a single developer laptop.

### Single Unified Identity Model
- All identities map to a single `users` entity.
- Supported roles: `CUSTOMER`, `FARMER`, `ADMIN`, `BULK_BUYER`, `DELIVERY_PARTNER`, `COLLECTION_OPERATOR`, `WAREHOUSE_OPERATOR`, `HUB_OPERATOR`, `DELIVERY_STATION_OPERATOR`, `FINANCE`, `QUALITY`, `SUPPORT`.
- A user can simultaneously possess both `CUSTOMER` and `FARMER` roles.

### Future Python AI Service
- Packaged in `ai-service` using FastAPI.
- Reserved for computer-vision grade inspection, predictive demand aggregation, regional weather synthesis, and localized Krishi scheme RAG queries in future phases.
