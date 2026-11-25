# PROJECT_AUDIT.md — Kisan Setu Complete Platform Audit

**Audit Date:** 2026-11-25  
**Auditor:** Principal Software Architect (AI Agent)  
**Platform Version:** v1.0.0 (Pre-Production)

---

## 1. Platform Overview

Kisan Setu is an agricultural marketplace and supply-chain platform connecting farmers, Farmer Producer Organizations (FPOs), customers, and bulk buyers in Maharashtra, India.

### Applications

| App | Technology | Location | Status |
|-----|-----------|----------|--------|
| Customer Mobile App | Flutter / Dart (SDK ^3.10.4) | `apps/customer-app/` | ✅ UI Complete, Partial Backend Integration |
| Farmer Mobile App | Flutter / Dart (SDK ^3.10.4) | `apps/farmer-app/` | ✅ UI Complete, Mock-Only Backend |
| Admin Web Panel | React 19 + MUI v9 + TypeScript | `apps/admin-panel/` | ✅ UI Complete, Minimal Backend Integration |
| Backend | Spring Boot (Monolith) | `backend/spring-boot-application/` | ⚠️ Partially Implemented |

---

## 2. Customer App Audit (`apps/customer-app/`)

### Technology Stack
- Flutter SDK: ^3.10.4
- State Management: Provider (ChangeNotifier)
- Navigation: GoRouter ^17.5.0
- HTTP Client: Dio ^5.11.1 + custom ApiClient
- Storage: flutter_secure_storage ^9.2.2 + shared_preferences
- Base URL: `http://localhost:8080/api/v1`

### Screen Inventory (100 Dart files total)
| Feature Module | Screen Count | Implementation |
|---------------|-------------|----------------|
| Onboarding (Splash, Welcome, Language, Onboarding) | 4 | ✅ Complete |
| Auth (Login, Register, OTP, ForgotPassword) | 4 | ✅ Complete |
| Location (Primer, Permission Denied, Map Picker, Select, Addresses, Add/Edit, Serviceability, Confirm Tagging) | 8 | ✅ Complete |
| Notifications (Primer, Centre, Preferences) | 3 | ✅ Complete |
| Home | 1 | ✅ Complete |
| Catalog (Categories, Search, Product Detail, Reviews, Farmer Profile, FPO Network, Filter) | 7 | ✅ Complete |
| Cart | 1 | ✅ Complete |
| Weekly Cart (Planner, Day Planner, Submitted) | 3 | ✅ Complete |
| Checkout (Checkout, Payment, Payment Processing, Payment Failed, Apply Coupon) | 5 | ✅ Complete |
| Orders (List, Details, Confirmed, Cancel, Tracking, Live Tracking, Tax Invoice) | 7 | ✅ Complete |
| Subscription (List, Create, Details, Edit Schedule, Pause) | 5 | ✅ Complete |
| Profile (Profile, Edit, Security, Delivery Prefs, Kisan Wallet, Delete Account) | 6 | ✅ Complete |
| Support (Help & Support, FAQ, Raise Ticket, Live Chat) | 4 | ✅ Complete |

**Total: 58 screens implemented**

### Provider/State Layer
| Provider | Backend Integration | Status |
|----------|-------------------|--------|
| `AuthProvider` | Calls `/auth/login`, `/auth/register`, `/auth/send-otp`, `/auth/verify-otp`, `/users/me` | ✅ Live with mock fallback |
| `CatalogProvider` | Calls `/categories`, `/products` | ✅ Live with seeded fallback |
| `CartProvider` | Calls `/cart`, `/cart/items` | ⚠️ Live with local fallback |
| `OrdersProvider` | Calls `/orders`, `/orders/checkout`, `/orders/{id}/cancel` | ⚠️ Live with seeded fallback |
| `AddressProvider` | Calls `/users/me/addresses` | ⚠️ Live with mock fallback |
| `SubscriptionProvider` | Calls `/subscriptions` | ⚠️ Partially integrated |
| `WeeklyCartProvider` | Calls `/weekly-cart` | ⚠️ Partially integrated |
| `NotificationsProvider` | Calls `/notifications` | ⚠️ Mock only |
| `AppSettingsProvider` | Local only | ✅ Local |

---

## 3. Farmer App Audit (`apps/farmer-app/`)

### Technology Stack
- Flutter SDK: ^3.10.4
- State Management: Provider (ChangeNotifier)
- Navigation: GoRouter ^17.5.0 (5-tab ShellRoute, 60+ routes)
- HTTP Client: Dio (custom DioClient with JWT interceptor)
- Storage: flutter_secure_storage + shared_preferences
- Base URL: `http://localhost:8080/api/v1`

### Screen Inventory
| Module | Screens | Integration |
|--------|---------|-------------|
| Onboarding & Splash | 4 | ✅ Complete |
| Auth (Login, Register, OTP, Forgot Password) | 4 | ✅ Live with mock fallback |
| KYC (Identity, Land Record, Bank DBT, Certificate) | 4 | ⚠️ Mock only |
| Location (Primer, Farm Map Picker, Collection Points) | 3 | ⚠️ Mock only |
| Dashboard | 1 | ⚠️ Mock data |
| Profile (360, Farm Plots, FPO) | 3 | ⚠️ Mock only |
| Produce (List, Add, Edit, Detail) | 4 | ⚠️ Mock only |
| Surplus & Inventory | 4 | ⚠️ Mock only |
| Demand (List, Detail, Accept) | 3 | ⚠️ Mock only |
| Collection (Gate Pass, QC, Weighbridge, Cold Chain) | 4 | ⚠️ Mock only |
| Settlements (List, Detail, DBT History) | 3 | ⚠️ Mock only |
| Advisory & Weather | 4 | ⚠️ Mock only |
| Schemes | 3 | ⚠️ Mock only |
| Farmer Store | 4 | ⚠️ Mock only |
| Settings & Support | 5 | ⚠️ Mock only |
| Notifications | 2 | ⚠️ Mock only |

**Total: 57 screens implemented**

---

## 4. Admin Panel Audit (`apps/admin-panel/`)

### Technology Stack
- React 19, TypeScript 6, Vite 8
- MUI v9 (Material UI)
- react-router-dom v7 (30 protected routes)
- @tanstack/react-query v5
- Axios interceptor → `http://localhost:8080/api/v1`
- 7 RBAC roles

### Live Backend Endpoints Used
| Endpoint | Status |
|----------|--------|
| `POST /api/v1/auth/login` | ✅ Live |
| `GET /api/v1/admin/users` | ✅ Live |
| `GET /api/v1/admin/categories` | ✅ Live |
| `POST /api/v1/admin/categories` | ✅ Live |
| `GET /api/v1/products` | ✅ Live |

### Mock-Only Admin Features (need backend)
- KYC management, Order management, Farmer management
- Payment authorization, Settlement management, Supply chain management
- Analytics, Notifications, Support tickets

---

## 5. Backend Audit (`backend/spring-boot-application/`)

### Technology Stack
- Spring Boot (Monolith)
- PostgreSQL 16 (PostGIS)
- Redis 7
- RabbitMQ 3.13
- Flyway migrations (V1–V9)
- JWT authentication (HS256)
- OpenAPI / Swagger UI at `/swagger-ui.html`

### Module Inventory
| Module | Controllers | Services | Entities | Repositories | Status |
|--------|------------|---------|---------|-------------|--------|
| `auth` | ✅ AuthController | ✅ AuthProvider (Mock impl) | RefreshToken | RefreshTokenRepository | ✅ Implemented |
| `user` | ✅ UserController | — | User, Role | UserRepository, RoleRepository | ✅ Implemented |
| `admin` | ✅ AdminController | ✅ AdminService | — | — | ⚠️ Minimal |
| `catalog` | ✅ CatalogController | ✅ CatalogService | ProductCategory | ProductCategoryRepository | ✅ Implemented |
| `product` | — | ✅ ProductService | Product | ProductRepository | ⚠️ No controller |
| `customer` | ✅ CustomerController, AddressController | ✅ CustomerService, AddressService | CustomerProfile, Address | Both repos | ✅ Implemented |
| `cart` | ✅ CartController, WeeklyCartController | ✅ CartService, WeeklyCartService | Cart, CartItem, WeeklyCart, WeeklyCartDay, WeeklyCartItem | 4 repos | ✅ Implemented |
| `order` | ✅ OrderController | ✅ OrderService | Order, OrderItem | 2 repos | ✅ Implemented |
| `payment` | ✅ PaymentController | ✅ PaymentService (Mock) | Payment, PaymentTransaction | 2 repos | ⚠️ Mock only |
| `subscription` | ✅ SubscriptionController | ✅ SubscriptionService | Subscription, SubscriptionItem | 1 repo | ✅ Implemented |
| `tracking` | ✅ TrackingController | ✅ TrackingService | TrackingEvent | TrackingEventRepository | ✅ Implemented |
| `pricing` | ✅ PricingController | ✅ PricingService | MarketPrice, PriceHistory | 2 repos | ✅ Implemented |
| `servicearea` | ✅ ServiceAreaController | ✅ ServiceAreaService | ServiceArea | ServiceAreaRepository | ✅ Implemented |
| `farmer` | ✅ FarmerController | ✅ FarmerService, FarmerListingService | FarmerProfile, FarmerListing | 2 repos | ⚠️ Partial |
| `audit` | — | ✅ AuditService | AuditLog | AuditLogRepository | ✅ Implemented |
| `notification` | — | ✅ NotificationService (Local) | — | — | ⚠️ Local only |
| `ai` | — | ✅ AiService | — | — | ⚠️ Stub only |
| `collection` | — | ✅ CollectionService | — | — | ⚠️ Stub only |
| `delivery` | — | ✅ DeliveryService | — | — | ⚠️ Stub only |
| `inventory` | — | ✅ InventoryService | — | — | ⚠️ Stub only |
| `marketplace` | — | ✅ MarketplaceService | — | — | ⚠️ Stub only |
| `quality` | — | ✅ QualityService | — | — | ⚠️ Stub only |
| `scheme` | — | ✅ SchemeService | — | — | ⚠️ Stub only |
| `settlement` | — | ✅ SettlementService | — | — | ⚠️ Stub only |
| `warehouse` | — | ✅ WarehouseService | — | — | ⚠️ Stub only |
| `farmerstore` | — | ✅ FarmerStoreService | — | — | ⚠️ Stub only |
| `hub` | — | ✅ HubService | — | — | ⚠️ Stub only |
| `bulkbuyer` | — | ✅ BulkBuyerService | — | — | ⚠️ Stub only |

### Database Schema (Flyway Migrations V1–V9)
| Migration | Tables Created |
|-----------|---------------|
| V1 | users |
| V2 | roles, user_roles |
| V3 | farmer_profiles, customer_profiles |
| V4 | service_areas |
| V5 | audit_logs |
| V6 | Seed data (admin user, roles, service areas) |
| V7 | addresses, product_categories, products, product_images, market_prices, price_history, carts, cart_items, weekly_carts, weekly_cart_days, weekly_cart_items, orders, order_items, payments, payment_transactions, tracking_events |
| V8 | Seed catalog data (10 categories, 20+ products with prices) |
| V9 | farmer_listings, refresh_tokens |

### Infrastructure
- Docker Compose at root: PostgreSQL, Redis, RabbitMQ (infrastructure only, no app containers)
- Backend Dockerfile: `backend/spring-boot-application/Dockerfile`
- RabbitMQ configured but NOT used (queues defined in `RabbitMqConfig.java` but no publishers/consumers)
- Redis configured but NOT used (RedisConfig.java exists, no actual caching implemented)

---

## 6. Missing Infrastructure Gaps

| Gap | Priority | Impact |
|----|---------|--------|
| No API Gateway (Spring Cloud Gateway) | P0 | All 3 apps hardcoded to port 8080 |
| Product Service has no REST controller | P0 | Products only accessible via Admin |
| KYC module has no controller or entities | P1 | Farmers cannot submit KYC |
| Settlement module is a stub | P1 | Farmers cannot receive payments |
| Farmer module missing many endpoints | P1 | Farmer App fully mocked |
| Notification push (FCM/SMS) not wired | P1 | No real-time user alerts |
| Payment is mock-only | P1 | No real payment flow |
| RabbitMQ has zero event publishers | P1 | No async event processing |
| Redis has zero actual caching | P2 | Performance penalty |
| No CORS config for Admin panel origin | P2 | Admin panel can't reach backend in prod |
| Demand module completely missing | P1 | Demand orders cannot be placed |
| Bulk buyer module is a stub | P2 | B2B feature not usable |
