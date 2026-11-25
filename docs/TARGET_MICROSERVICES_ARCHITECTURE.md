# TARGET_MICROSERVICES_ARCHITECTURE.md

**Date:** 2026-11-25

## Design Philosophy

The migration follows the **Strangler Fig pattern** — microservices are extracted from the monolith incrementally. The monolith continues to run during migration. Services are extracted in priority order based on team independence, scaling needs, and deployment frequency.

## Target Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CLIENT APPLICATIONS                                   │
│   Customer App (Flutter)  │  Farmer App (Flutter)  │  Admin Panel (React)   │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    API GATEWAY (Spring Cloud Gateway, Port 8080)             │
│  Route: /api/v1/auth/*       → auth-service:8081                           │
│  Route: /api/v1/users/*      → user-service:8082                           │
│  Route: /api/v1/farmers/*    → farmer-service:8083                         │
│  Route: /api/v1/kyc/*        → kyc-service:8084                            │
│  Route: /api/v1/categories/* → product-service:8085                        │
│  Route: /api/v1/products/*   → product-service:8085                        │
│  Route: /api/v1/produce/*    → produce-service:8086                        │
│  Route: /api/v1/demands/*    → demand-service:8087                         │
│  Route: /api/v1/cart/*       → cart-service:8088                           │
│  Route: /api/v1/weekly-cart/*→ cart-service:8088                           │
│  Route: /api/v1/orders/*     → order-service:8089                          │
│  Route: /api/v1/payments/*   → payment-service:8090                        │
│  Route: /api/v1/settlements/*→ settlement-service:8091                     │
│  Route: /api/v1/collections/*→ collection-service:8092                     │
│  Route: /api/v1/quality/*    → quality-service:8093                        │
│  Route: /api/v1/inventory/*  → inventory-service:8094                      │
│  Route: /api/v1/tracking/*   → logistics-service:8095                      │
│  Route: /api/v1/notifications/*→ notification-service:8096                 │
│  Route: /api/v1/support/*    → support-service:8097                        │
│  Route: /api/v1/analytics/*  → analytics-service:8098                      │
│  Route: /api/v1/admin/*      → admin aggregates from all services          │
└─────────────────────────────────────────────────────────────────────────────┘
      │                 │                 │                   │
      ▼                 ▼                 ▼                   ▼
┌──────────┐    ┌──────────────┐  ┌───────────────┐  ┌────────────────┐
│PostgreSQL│    │   RabbitMQ   │  │     Redis      │  │ External APIs  │
│(Per-svc  │    │  Event Bus   │  │  (Cache +      │  │ FCM, SMS,      │
│ schemas) │    │              │  │   Sessions)    │  │ Razorpay, IMD  │
└──────────┘    └──────────────┘  └───────────────┘  └────────────────┘
```

---

## Service Catalog

| # | Service | Port | DB Schema | Responsibility |
|---|---------|------|-----------|---------------|
| 1 | api-gateway | 8080 | — | Routing, JWT validation, CORS, rate limiting |
| 2 | auth-service | 8081 | auth_db | Register, login, OTP, JWT issue, refresh |
| 3 | user-service | 8082 | user_db | User profiles, addresses, preferences |
| 4 | farmer-service | 8083 | farmer_db | Farmer profiles, farm plots, FPO association |
| 5 | kyc-service | 8084 | kyc_db | KYC document submission, review, approval |
| 6 | product-service | 8085 | product_db | Product catalogue, categories, pricing |
| 7 | produce-service | 8086 | produce_db | Farmer listings, availability, surplus |
| 8 | demand-service | 8087 | demand_db | Buyer demand requests, demand-supply matching |
| 9 | cart-service | 8088 | cart_db | Customer cart, weekly cart, subscriptions |
| 10 | order-service | 8089 | order_db | Order creation, lifecycle, cancellation |
| 11 | payment-service | 8090 | payment_db | Payment initiation, gateway, webhooks |
| 12 | settlement-service | 8091 | settlement_db | Farmer settlement, DBT authorization |
| 13 | collection-service | 8092 | collection_db | Collection points, gate passes |
| 14 | quality-service | 8093 | quality_db | Quality inspection, grading records |
| 15 | inventory-service | 8094 | inventory_db | Warehouse stock, inventory management |
| 16 | logistics-service | 8095 | logistics_db | Delivery, tracking, live GPS |
| 17 | notification-service | 8096 | notification_db | FCM push, SMS, email, in-app |
| 18 | support-service | 8097 | support_db | Tickets, live chat, FAQ |
| 19 | analytics-service | 8098 | analytics_db | Aggregations, reports, dashboard KPIs |
| 20 | ai-service | 8099 | — | Crop advisory, price prediction, weather |

---

## Event-Driven Communication (RabbitMQ)

### Key Exchange: `kisansetu.events` (Topic Exchange)

| Event | Publisher | Consumers | Routing Key |
|-------|-----------|-----------|------------|
| `UserRegistered` | auth-service | user-service, notification-service | `user.registered` |
| `KycSubmitted` | kyc-service | notification-service | `kyc.submitted` |
| `KycApproved` | kyc-service | farmer-service, notification-service | `kyc.approved` |
| `KycRejected` | kyc-service | notification-service | `kyc.rejected` |
| `ProduceListed` | produce-service | demand-service, notification-service | `produce.listed` |
| `DemandCreated` | demand-service | notification-service, produce-service | `demand.created` |
| `DemandAccepted` | demand-service | order-service, notification-service | `demand.accepted` |
| `OrderCreated` | order-service | inventory-service, notification-service | `order.created` |
| `PaymentInitiated` | payment-service | order-service | `payment.initiated` |
| `PaymentSucceeded` | payment-service | order-service, settlement-service, notification-service | `payment.succeeded` |
| `PaymentFailed` | payment-service | order-service, inventory-service, notification-service | `payment.failed` |
| `OrderConfirmed` | order-service | logistics-service, collection-service, notification-service | `order.confirmed` |
| `OrderDispatched` | logistics-service | notification-service | `order.dispatched` |
| `OrderDelivered` | logistics-service | order-service, settlement-service, notification-service | `order.delivered` |
| `SettlementAuthorized` | settlement-service | notification-service | `settlement.authorized` |
| `CollectionCreated` | collection-service | inventory-service | `collection.created` |
| `QualityInspected` | quality-service | inventory-service, settlement-service | `quality.inspected` |
| `InventoryUpdated` | inventory-service | produce-service, demand-service | `inventory.updated` |

---

## Database-Per-Service Strategy

Each service owns its own PostgreSQL schema on the shared database server. Services NEVER query another service's schema directly — they communicate via APIs or events.

```sql
-- Single PostgreSQL server, multiple schemas
CREATE SCHEMA auth_db;
CREATE SCHEMA user_db;
CREATE SCHEMA farmer_db;
CREATE SCHEMA kyc_db;
CREATE SCHEMA product_db;
CREATE SCHEMA produce_db;
CREATE SCHEMA demand_db;
CREATE SCHEMA cart_db;
CREATE SCHEMA order_db;
CREATE SCHEMA payment_db;
CREATE SCHEMA settlement_db;
CREATE SCHEMA collection_db;
CREATE SCHEMA quality_db;
CREATE SCHEMA inventory_db;
CREATE SCHEMA logistics_db;
CREATE SCHEMA notification_db;
CREATE SCHEMA support_db;
CREATE SCHEMA analytics_db;
```

---

## Migration Phases

### Phase 1 — Infrastructure (Week 1)
- API Gateway (Spring Cloud Gateway) deployed as a proxy to monolith
- All 3 frontends updated to point to gateway (port 8080 preserved)
- RabbitMQ queues activated

### Phase 2 — Auth & User Extraction (Week 2)
- Extract auth-service (highest coupling, most critical)
- Extract user-service
- Monolith delegates auth to auth-service

### Phase 3 — Catalogue & Cart (Week 3)
- Extract product-service (add missing ProductController)
- Extract cart-service
- Customer checkout flow end-to-end tested

### Phase 4 — Order & Payment (Week 4)
- Extract order-service
- Extract payment-service (integrate real gateway)
- Saga pattern for order-payment flow

### Phase 5 — Farmer Services (Week 5–6)
- Extract farmer-service
- Extract kyc-service (new module)
- Extract produce-service
- Extract demand-service (new module)

### Phase 6 — Supply Chain (Week 7)
- Extract collection-service
- Extract quality-service
- Extract settlement-service
- Extract inventory-service
- Extract logistics-service

### Phase 7 — Supporting Services (Week 8)
- Extract notification-service (wire FCM + SMS)
- Extract support-service
- Extract analytics-service
- Decommission monolith

---

## Technology Choices

| Concern | Choice | Rationale |
|---------|--------|-----------|
| API Gateway | Spring Cloud Gateway | Same Spring ecosystem, reactive |
| Service Communication | REST (sync) + RabbitMQ (async) | Simple, well-understood |
| Auth Token | JWT HS256 | Stateless, validated at gateway |
| Database | PostgreSQL 16 (per-schema) | Existing infrastructure |
| Cache | Redis 7 | Existing infrastructure |
| Message Broker | RabbitMQ 3.13 | Existing infrastructure |
| Service Discovery | Static config (host:port in gateway) | MVP simplicity |
| Config Management | Environment variables | Docker/Kubernetes compatible |
| Container | Docker + Docker Compose | Local dev parity |
| Payment | Razorpay | Indian market leader, UPI support |
| Push Notifications | Firebase FCM | Cross-platform (Android + iOS) |
| SMS OTP | MSG91 | Indian carrier coverage |
