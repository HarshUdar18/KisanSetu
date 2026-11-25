# 🌾 KisanSetu (KrishiConnect) — Comprehensive Project & Tech Stack Inventory

> **Master Reference Document**: Complete catalog of all technologies, frameworks, libraries, modules, database migrations, APIs, configuration parameters, and infrastructure components used across the entire KisanSetu platform.

---

## 📑 Table of Contents
1. [Executive Summary & System Purpose](#1-executive-summary--system-purpose)
2. [Architectural Topology & Design Decisions](#2-architectural-topology--design-decisions)
3. [Exhaustive Technology Stack by Subsystem](#3-exhaustive-technology-stack-by-subsystem)
   - [3.1 Backend Modular Monolith (Spring Boot 3)](#31-backend-modular-monolith-spring-boot-3)
   - [3.2 Customer Mobile Application (Flutter)](#32-customer-mobile-application-flutter)
   - [3.3 Farmer Mobile Application (Flutter)](#33-farmer-mobile-application-flutter)
   - [3.4 Admin Web Portal (React 19 + Vite)](#34-admin-web-portal-react-19--vite)
   - [3.5 AI & Intelligence Service (Python FastAPI)](#35-ai--intelligence-service-python-fastapi)
   - [3.6 Infrastructure, Database & Cache Layer](#36-infrastructure-database--cache-layer)
4. [Complete Monorepo Directory Tree](#4-complete-monorepo-directory-tree)
5. [Backend Domain Modules (29 Domain & Core Packages)](#5-backend-domain-modules-29-domain--core-packages)
6. [Core Abstractions & Service Interfaces](#6-core-abstractions--service-interfaces)
7. [Database Schema & Flyway Migrations (V1 — V9)](#7-database-schema--flyway-migrations-v1--v9)
8. [Complete REST API Contract & Endpoint Matrix](#8-complete-rest-api-contract--endpoint-matrix)
9. [9-Stage Supply Chain Pipeline](#9-9-stage-supply-chain-pipeline)
10. [Port Matrix & Networking Configuration](#10-port-matrix--networking-configuration)
11. [Environment Variables & Configuration Reference](#11-environment-variables--configuration-reference)
12. [Pre-Seeded Test Credentials & Pilot Service Corridors](#12-pre-seeded-test-credentials--pilot-service-corridors)
13. [Windows Single-Laptop Helper Scripts](#13-windows-single-laptop-helper-scripts)

---

## 1. Executive Summary & System Purpose

**KisanSetu** (also branded as **KrishiConnect**) is a direct farm-to-consumer agricultural commerce and verifiable supply chain platform. 

### Core Value Proposition:
- **Disintermediation**: Eliminates multiple tiers of predatory middlemen and commission agents in agricultural mandis.
- **Fair Pricing**: Provides transparent farmgate pricing computed dynamically from baseline market rates with clear markups.
- **Traceability**: Delivers an immutable 9-stage supply chain verification trail from seed/harvest to doorstep.
- **Predictable Demand**: Features a Monday-to-Sunday weekly produce basket planner and recurring farm subscriptions so farmers harvest against real demand.
- **Pilot Geographic Focus**: Initiated in the Pune agricultural corridor with dedicated service zones in **Shivajinagar (411005)** and **Akurdi (411035)**.

---

## 2. Architectural Topology & Design Decisions

```
                           CUSTOMER MOBILE APP (Flutter)
                                        │
                                        ▼ (HTTPS / REST / JWT)
                         SPRING BOOT MODULAR MONOLITH
                     (/api/v1/ REST & Spring Security RBAC)
                                        │
                  ┌─────────────────────┼─────────────────────┐
                  ▼                     ▼                     ▼
          PostgreSQL 16               Redis 7            RabbitMQ 3.13
         (PostGIS-Enabled)       (Cache & Rate Limiting)  (Async Events)
                  ▲
                  │
                         SPRING BOOT MODULAR MONOLITH
                  ▲                     ▲
                  │                     │
         FARMER MOBILE APP        ADMIN WEB PANEL          FASTAPI AI SERVICE
             (Flutter)         (React 19 + TypeScript)     (Python ML / RAG)
```

### Critical Architectural Decisions:
1. **Two Distinct Native Flutter Apps**:
   - `apps/customer-app`: Pure consumer e-commerce UX (baskets, meal planners, tracking).
   - `apps/farmer-app`: Enterprise agri-producer UX (crop declarations, harvest schedules, spot listings, payouts).
   - *Rationale*: No unified app with role switches. Eliminates UI bloat, reduces binary size, and keeps agricultural producer workflows decoupled from urban consumers.
2. **Unified Single-Identity Model**:
   - Both mobile applications and the Admin Web panel talk to the **same Spring Boot backend** and share the **same PostgreSQL database**.
   - A single person can hold both `ROLE_CUSTOMER` and `ROLE_FARMER` on their unified `users` record with zero data duplication.
3. **Spring Boot Modular Monolith**:
   - High cohesion and strict domain isolation through 26 demarcated domain modules.
   - Eliminates distributed microservice overhead during local development while maintaining clean module boundaries ready for microservice extraction if required.
4. **PostGIS-Enabled Spatial Validation**:
   - Deliveries and farmer aggregations are verified against geo-spatial polygons and postal code boundaries.

---

## 3. Exhaustive Technology Stack by Subsystem

### 3.1 Backend Modular Monolith (Spring Boot 3)
- **Base Language**: Java 17 (OpenJDK / Eclipse Temurin)
- **Primary Framework**: Spring Boot `3.3.5`
- **Build Tool**: Apache Maven 3.9+ (includes `mvnw` and `mvnw.cmd` wrappers)
- **Dependencies & Libraries (`pom.xml`)**:
  | Dependency / Starter | Version | Purpose |
  |---|---|---|
  | `spring-boot-starter-web` | 3.3.5 | Embedded Tomcat, REST controllers, Jackson JSON serialization |
  | `spring-boot-starter-validation` | 3.3.5 | Jakarta Bean Validation (`@NotNull`, `@Size`, `@Pattern`, `@Valid`) |
  | `spring-boot-starter-security` | 3.3.5 | Spring Security 6, stateless security filter chain, RBAC |
  | `spring-boot-starter-data-jpa` | 3.3.5 | Jakarta Persistence API (JPA), Hibernate 6 ORM, repository abstraction |
  | `postgresql` (org.postgresql) | Runtime | Native PostgreSQL JDBC driver |
  | `flyway-core` | Latest Spring | Automated database migration engine |
  | `flyway-database-postgresql` | Latest Spring | PostgreSQL Flyway database extension |
  | `spring-boot-starter-data-redis`| 3.3.5 | Redis integration via Lettuce driver for caching and rate limiting |
  | `spring-boot-starter-amqp` | 3.3.5 | Spring AMQP & RabbitMQ messaging broker integration |
  | `spring-boot-starter-actuator` | 3.3.5 | Health checks, metrics, `/actuator/health`, `/actuator/info` |
  | `springdoc-openapi-starter-webmvc-ui`| `2.6.0` | Automated Swagger UI 3 & OpenAPI 3 specification generation |
  | `jjwt-api` (io.jsonwebtoken) | `0.12.6` | JSON Web Token (JWT) API for authentication |
  | `jjwt-impl` (io.jsonwebtoken) | `0.12.6` | JJWT implementation engine |
  | `jjwt-jackson` (io.jsonwebtoken)| `0.12.6` | JJWT Jackson JSON parser integration |
  | `spring-boot-starter-test` | 3.3.5 | Test framework (JUnit 5 Jupiter, Mockito, AssertJ, Spring Test) |
  | `spring-security-test` | 3.3.5 | Security test mock helpers (`@WithMockUser`) |
  | `h2` (com.h2database) | Test scope | In-memory relational database for testing |

---

### 3.2 Customer Mobile Application (Flutter)
- **Base Language**: Dart `^3.10.4`
- **Application Framework**: Flutter 3.x
- **Location**: `apps/customer-app`
- **Dependencies (`pubspec.yaml`)**:
  | Package | Version | Purpose |
  |---|---|---|
  | `flutter` | SDK | Core Flutter UI framework |
  | `cupertino_icons` | `^1.0.8` | iOS Cupertino icon glyphs |
  | `flutter_riverpod` | `^3.3.2` | Reactive state management, dependency injection, and providers |
  | `go_router` | `^17.5.0` | Declarative routing, deep links, path & query parameter handling |
  | `dio` | `^5.11.1` | Robust HTTP networking client with custom auth & logging interceptors |
  | `intl` | `^0.20.3` | Indian currency formatting (`₹`), number and date localization |
  | `flutter_lints` (dev) | `^6.0.0` | Dart & Flutter official recommended lint rules |
- **UI Design System**:
  - Material 3 Design
  - Primary Theme Color: Forest Green (`#1B5E20`, `#2E7D32`)
  - Accent Color: Amber (`#FFA000`)
  - Features: Dynamic product cards, bottom navigation bar, floating cart drawer, multi-step stepper, animated status trackers.

---

### 3.3 Farmer Mobile Application (Flutter)
- **Base Language**: Dart `^3.10.4`
- **Application Framework**: Flutter 3.x
- **Location**: `apps/farmer-app`
- **Dependencies (`pubspec.yaml`)**:
  | Package | Version | Purpose |
  |---|---|---|
  | `flutter` | SDK | Core Flutter UI framework |
  | `cupertino_icons` | `^1.0.8` | iOS style icon pack |
  | `flutter_riverpod` | `^3.3.2` | Riverpod reactive state management |
  | `go_router` | `^17.5.0` | Declarative screen navigation |
  | `dio` | `^5.11.1` | HTTP API communication with Spring Boot |
  | `flutter_lints` (dev) | `^6.0.0` | Code quality and linting |
- **Features Implemented & Skeletons**:
  - Authentication (OTP / Password)
  - Dashboard with sales and delivery stats
  - Produce inventory & spot listings
  - Drop-off scheduling at local collection centers
  - Direct UPI payment ledger and payout requests
  - Krishi government schemes and AI advisory feed

---

### 3.4 Admin Web Portal (React 19 + Vite)
- **Base Framework**: React 19 (`react: ^19.2.8`, `react-dom: ^19.2.8`)
- **Language**: TypeScript (`typescript: ~6.0.2`, `@types/react`, `@types/react-dom`, `@types/node`)
- **Bundler & Dev Server**: Vite 8 (`vite: ^8.3.0`, `@vitejs/plugin-react: ^6.1.1`)
- **Location**: `apps/admin-panel`
- **Dependencies (`package.json`)**:
  | Package | Version | Purpose |
  |---|---|---|
  | `@mui/material` | `^9.4.0` | Google Material UI component library |
  | `@mui/icons-material` | `^9.4.0` | Material UI SVG icons |
  | `@emotion/react` | `^11.14.0` | CSS-in-JS style rendering engine |
  | `@emotion/styled` | `^11.14.1` | Styled component wrappers for Emotion |
  | `@tanstack/react-query` | `^5.104.0` | Asynchronous server state fetching, caching, and mutation management |
  | `react-router-dom` | `^7.18.4` | Client-side routing and protected routes |
  | `react-hook-form` | `^7.89.0` | Performant form state and submission handling |
  | `zod` | `^4.6.5` | TypeScript-first schema declaration and input validation |
  | `axios` | `^1.20.0` | Promise-based HTTP client with automatic Bearer token interceptor |
  | `oxlint` (dev) | `^1.81.0` | Ultra-fast Rust-based JavaScript/TypeScript linter |

---

### 3.5 AI & Intelligence Service (Python FastAPI)
- **Base Language**: Python `3.10+`
- **Framework**: FastAPI (`fastapi==0.115.0`)
- **ASGI Server**: Uvicorn (`uvicorn[standard]==0.31.0`)
- **Location**: `ai-service`
- **Dependencies (`requirements.txt`)**:
  | Package | Version | Purpose |
  |---|---|---|
  | `fastapi` | 0.115.0 | Modern, asynchronous web framework for AI APIs |
  | `uvicorn[standard]` | 0.31.0 | High-performance ASGI server with Cython event loop |
  | `pydantic` | 2.9.2 | Fast data validation using Python type annotations |
  | `pydantic-settings` | 2.5.2 | Environment variable settings management |
  | `httpx` | 0.27.2 | Asynchronous HTTP client for cross-service calls |
  | `pytest` | 8.3.3 | Automated testing suite |
- **Planned Models & RAG**:
  - Computer-vision crop grading and blight/defect classification
  - Regional weather alerts & harvest timing advisory
  - Multi-lingual Krishi scheme RAG (Retrieval-Augmented Generation) in Marathi and Hindi

---

### 3.6 Infrastructure, Database & Cache Layer
- **Containerization**: Docker & Docker Compose (`docker-compose.yml`)
- **Containerized Services**:
  1. **PostgreSQL with PostGIS**:
     - Image: `postgis/postgis:16-3.4-alpine`
     - Database: `kisansetu_db`
     - Internal Port: `5432` | External Port: `5432`
     - Capabilities: Full ACID relational store with geographic GIS spatial indexing
  2. **Redis In-Memory Data Store**:
     - Image: `redis:7-alpine`
     - Internal Port: `6379` | External Port: `6379`
     - Capabilities: Cache abstraction, session storage, sliding-window rate limiting
  3. **RabbitMQ Event Broker**:
     - Image: `rabbitmq:3.13-management-alpine`
     - AMQP Port: `5672` | Web Management Console: `15672`
     - Credentials: `kisansetu` / `kisansetu_secret`
     - Capabilities: Asynchronous decoupling of order creation, stock decrements, SMS dispatch
  4. **Nginx Reverse Proxy Configuration**:
     - Path: `infrastructure/nginx/nginx.conf`
     - Routes `/api/` to Spring Boot (`:8080`), `/ai/` to FastAPI (`:8000`), `/admin/` to React UI (`:5173`), and Swagger UI

---

## 4. Complete Monorepo Directory Tree

```
KisanSetu/
├── .env                                # Local environment variable configuration
├── .env.example                        # Template environment variables
├── .gitignore                          # Git exclusions across Java, Node, Python, Flutter
├── docker-compose.yml                  # Root Docker Compose (Postgres, Redis, RabbitMQ)
├── README.md                           # Main project documentation
├── PROJECT_INVENTORY.md                # (This Document) Complete technical inventory
│
├── ai-service/                         # Python FastAPI Microservice
│   ├── app/
│   │   ├── core/
│   │   │   └── config.py               # Pydantic environment settings
│   │   └── main.py                     # FastAPI application entry point (/health, /docs)
│   └── requirements.txt                # Python dependencies
│
├── apps/                               # Client Applications
│   ├── admin-panel/                    # React 19 + TypeScript Admin Web Portal
│   │   ├── index.html
│   │   ├── package.json                # React, MUI, Vite, TanStack Query, Axios
│   │   ├── tsconfig.json
│   │   ├── vite.config.ts
│   │   └── src/
│   │       ├── api/                    # Axios instance with JWT interceptor
│   │       ├── assets/                 # Brand assets
│   │       ├── config/                 # API baseURL configuration
│   │       ├── context/                # AuthContext (token, user profile)
│   │       ├── pages/                  # LoginPage, DashboardPage
│   │       ├── routes/                 # App routes and PrivateRoute guard
│   │       ├── theme/                  # Forest green Material UI theme
│   │       ├── App.tsx
│   │       └── main.tsx
│   │
│   ├── customer-app/                   # Customer Flutter Mobile Application
│   │   ├── pubspec.yaml                # Flutter, Riverpod, GoRouter, Dio, Intl
│   │   ├── test/widget_test.dart
│   │   └── lib/
│   │       ├── main.dart               # ProviderScope application launcher
│   │       ├── core/
│   │       │   ├── config/             # app_config.dart (localhost:8080 vs 10.0.2.2:8080)
│   │       │   ├── routing/            # app_router.dart (18 full customer routes)
│   │       │   ├── theme/              # app_theme.dart (Material 3 Agricultural Green)
│   │       │   └── widgets/            # app_scaffold.dart, error_view.dart, loading_view.dart
│   │       └── features/
│   │           ├── auth/               # splash, welcome, login, register screens + auth_provider
│   │           ├── location/           # addresses_screen, add_edit_address_screen + address_provider
│   │           ├── catalog/            # categories_screen, product_detail_screen + catalog_provider
│   │           ├── cart/               # cart_screen + cart_provider
│   │           ├── weekly_cart/        # weekly_planner_screen + weekly_cart_provider
│   │           ├── subscription/       # subscriptions_list, create_subscription + subscription_provider
│   │           ├── checkout/           # checkout_screen, payment_screen
│   │           ├── orders/             # orders_screen, order_details, tracking_screen, order_confirmed
│   │           ├── home/               # home_screen (search, banners, top produce, quick reorder)
│   │           └── profile/            # profile_screen (account, addresses, logout)
│   │
│   └── farmer-app/                     # Farmer Flutter Mobile Application
│       ├── pubspec.yaml                # Flutter, Riverpod, GoRouter, Dio
│       └── lib/
│           ├── main.dart
│           ├── core/                   # config, routing, theme, widgets
│           └── features/
│               ├── ai/                 # AI advisory & crop health skeletons
│               ├── auth/               # Farmer onboarding & phone OTP login
│               ├── collections/        # Local collection center drop slots
│               ├── dashboard/          # Daily harvest stats & incoming demand
│               ├── marketplace/        # Market wholesale rates & spot trends
│               ├── payments/           # Direct UPI ledger & settlement balance
│               ├── produce/            # Produce declaration & lot management
│               ├── profile/            # Farmer KYC & land acreage details
│               ├── requests/           # Buyer demand requests
│               ├── schemes/            # PM-Kisan & Krishi subsidy assistant
│               └── store/              # Farmer direct-selling store settings
│
├── backend/
│   └── spring-boot-application/        # Spring Boot 3.3.5 Modular Monolith
│       ├── pom.xml                     # Maven project specification
│       ├── mvnw / mvnw.cmd             # Maven wrapper scripts
│       └── src/
│           ├── main/
│           │   ├── java/com/kisansetu/
│           │   │   ├── KisansetuBackendApplication.java # Spring Boot Main Class
│           │   │   ├── common/         # Cross-Cutting Infrastructure Abstractions
│           │   │   │   ├── config/     # SecurityConfig, OpenApiConfig, RedisConfig, etc.
│           │   │   │   ├── exception/  # GlobalExceptionHandler, Custom Exceptions
│           │   │   │   ├── location/   # LocationService, MockLocationService
│           │   │   │   ├── logging/    # Request correlation ID filters
│           │   │   │   ├── response/   # Standard ApiResponse<T> wrapper
│           │   │   │   ├── security/   # JwtTokenProvider, JwtAuthenticationFilter
│           │   │   │   └── storage/    # StorageService, LocalStorageService
│           │   │   └── modules/        # 29 Domain Packages (listed in Section 5)
│           │   └── resources/
│           │       ├── application.yml # Spring configuration (Datasource, Redis, RabbitMQ, JWT)
│           │       └── db/migration/   # Flyway SQL Migrations V1 -> V9
│           └── test/                   # Integration and unit tests
│
├── docs/                               # Architecture, Guides & API Specifications
│   ├── API.md                          # REST v1 contract specification
│   ├── ARCHITECTURE.md                 # System topology and domain boundaries
│   ├── BUSINESS_RULES.md               # Agricultural pricing & supply chain rules
│   ├── CUSTOMER_APP.md                 # Detailed Customer Flutter App documentation
│   ├── DATABASE.md                     # Database schema, entities, and migrations
│   ├── LOCAL_SETUP.md                  # Single-laptop launch runbook
│   ├── PHASE_ROADMAP.md                # Platform roadmap from Phase 0 to Phase 5
│   ├── SECURITY.md                     # Spring Security, RBAC & audit trail specs
│   ├── api_reference.md                # Quick API reference
│   ├── setup_guide.md                  # Local environment developer guide
│   └── KrishiConnect_Phase2.postman_collection.json # Exported Postman testing collection
│
├── infrastructure/                     # Deployment configurations
│   ├── docker/
│   │   └── docker-compose.yml          # Container compose spec
│   └── nginx/
│       └── nginx.conf                  # Gateway & reverse proxy config
│
└── scripts/                            # Windows Single-Laptop Batch Helper Scripts
    ├── start-admin.bat                 # Launches React Admin Web UI (Port 5173)
    ├── start-ai.bat                    # Launches FastAPI AI service (Port 8000)
    ├── start-backend.bat               # Compiles and boots Spring Boot (Port 8080)
    ├── start-customer-app.bat          # Launches Customer Flutter App
    ├── start-farmer-app.bat            # Launches Farmer Flutter App
    └── start-infra.bat                 # Runs Docker Compose (Postgres, Redis, RabbitMQ)
```

---

## 5. Backend Domain Modules (29 Domain & Core Packages)

Located in `backend/spring-boot-application/src/main/java/com/kisansetu/modules/`:

| Module Name | Purpose & Responsibilities |
|---|---|
| `admin` | Admin dashboard metrics, system overrides, user audits, and dispute management |
| `ai` | Connector bridge between Spring Boot and the Python FastAPI intelligence service |
| `audit` | Append-only security audit log trail capturing sensitive mutations and logins |
| `auth` | User registration, password authentication, OTP generation, token refresh, and JWT issuance |
| `bulkbuyer` | B2B institutional buyer listings, bulk orders, restaurant supply contracts |
| `cart` | Customer active shopping basket, quantity updates, inventory hold, total recalculation |
| `catalog` | Master produce catalog, agricultural categories, seasonal produce specifications |
| `collection` | Farmer drop-off collection center assignments, time slot reservations, weigh-in |
| `customer` | Customer profile management, saved addresses, delivery preferences |
| `delivery` | Last-mile delivery dispatch, agent assignment, geofencing, OTP delivery confirmation |
| `farmer` | Farmer registration, KYC verification, farm acreage, UPI details, crop registry |
| `farmerstore` | Farmer virtual stall configuration, bio, farm story, and direct showcase |
| `hub` | Regional logistics hub cross-docking, batching, and routing |
| `inventory` | Real-time produce lot tracking, batch shelf-life countdown, cold-chain capacity |
| `marketplace` | Public produce listing search, filter by farm, organic certification filter |
| `notification`| Multi-channel notifications: SMS alerts, WhatsApp updates, mobile push messages |
| `order` | Order state machine, order lines, billing calculations, lifecycle status transitions |
| `payment` | Payment transaction records, gateway callback processing, refund handling |
| `payments` | Phase 2 farmer payment ledger, UPI settlement disbursements, escrow management |
| `pricing` | Dynamic farmgate-to-retail pricing engine, commission calculation, price history |
| `product` | Master product entity definitions, nutritional tags, shelf life, storage instructions |
| `quality` | Multi-point quality grading: Grade A (premium retail), Grade B (bulk/processing) |
| `scheme` | Government agricultural schemes registry (PM-Kisan, subsidies, loan schemes) |
| `servicearea`| Geographic service boundary validation (Shivajinagar 411005, Akurdi 411035) |
| `settlement` | Automated escrow settlement calculations and farmer net payout disbursement |
| `subscription` | Weekly recurring produce basket subscriptions, frequency, pause/resume engine |
| `tracking` | Verifiable 9-stage supply chain tracking events with timestamps, agents, locations |
| `user` | Core user identity entity, phone, email, credentials, and multi-role assignment |
| `warehouse` | Central cold storage operations, intake sorting, quality inspection, crate packing |

---

## 6. Core Abstractions & Service Interfaces

To allow single-laptop development without external paid subscriptions (AWS, Twilio, Razorpay), the platform includes modular interfaces backed by local development mocks:

1. **`AuthenticationProvider`**:
   - `MockAuthenticationProvider`: Intercepts phone numbers and auto-generates test OTPs logged to console without requiring SMS gateway credits.
2. **`PaymentProvider`**:
   - `MockPaymentProvider`: Simulates instantaneous UPI (`mock_upi@kisansetu`), Credit/Debit Card, and Cash on Delivery (COD) payment authorization and webhooks.
3. **`LocationService`**:
   - `MockLocationService`: Validates latitude/longitude against pilot polygon boundaries for Shivajinagar and Akurdi without incurring Google Maps API fees.
4. **`NotificationService`**:
   - `MockNotificationService`: Logs transactional notifications (order placed, out for delivery, OTPs) to application logs and in-memory audit store.
5. **`StorageService`**:
   - `LocalStorageService`: Stores uploaded produce photos, farm certificates, and invoices locally under `storage/` directory instead of requiring an AWS S3 bucket.
6. **`GlobalExceptionHandler`**:
   - Intercepts all validation, authentication, and domain errors and returns uniform RFC-compliant JSON responses with unique `requestId` correlation IDs.

---

## 7. Database Schema & Flyway Migrations (V1 — V9)

All migrations run automatically when the Spring Boot application boots up:

| Version | Migration File | Tables Created / Actions |
|---|---|---|
| **V1** | `V1__create_user_tables.sql` | `users` (id UUID PK, phone_number, email, full_name, password_hash, status, created_at, updated_at) |
| **V2** | `V2__create_role_tables.sql` | `roles` (id, description) & `user_roles` (user_id, role_id) junction table |
| **V3** | `V3__create_profiles.sql` | `customer_profiles` (address, pincode, slot) & `farmer_profiles` (farm_name, village, taluka, district, state, pin_code, land_size_acres, primary_crops, upi_id) |
| **V4** | `V4__create_service_areas.sql`| `service_areas` (id, name, city, state, postal_code, boundary_geojson, is_active) |
| **V5** | `V5__create_audit_tables.sql` | `audit_logs` (id, user_id, action, entity_type, entity_id, timestamp, ip_address, metadata JSONB) |
| **V6** | `V6__seed_initial_data.sql` | Seeds initial roles (`ROLE_CUSTOMER`, `ROLE_FARMER`, `ROLE_ADMIN`), service areas (Shivajinagar, Akurdi), and 3 default test accounts |
| **V7** | `V7__create_customer_phase1_tables.sql` | Customer Phase 1 Schema:<br>• `categories`<br>• `products`<br>• `product_prices`<br>• `price_history`<br>• `customer_addresses`<br>• `carts`<br>• `cart_items`<br>• `weekly_carts`<br>• `weekly_cart_items`<br>• `customer_subscriptions`<br>• `subscription_items`<br>• `orders`<br>• `order_items`<br>• `order_tracking_events`<br>• `payments` |
| **V8** | `V8__seed_customer_phase1_catalog.sql` | Seeds 5 categories (Vegetables, Fruits, Pulses, Grains, Dairy), 13 real farm products with Hindi/Marathi local names, dynamic price points, and test addresses |
| **V9** | `V9__create_phase2_farmer_listings_and_refresh_tokens.sql` | Farmer Phase 2 Schema:<br>• `farmer_listings` (farmer-specific produce stock, harvest date, asking price per kg, availability status)<br>• `refresh_tokens` (secure long-lived session management) |

---

## 8. Complete REST API Contract & Endpoint Matrix

All endpoints are prefixed with `/api/v1` and return standard JSON responses.

### 8.1 Authentication & Profile Endpoints
| HTTP Method | Route | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/v1/auth/register` | Register new user as Customer or Farmer | None |
| `POST` | `/api/v1/auth/login` | Login with Phone Number & Password | None |
| `POST` | `/api/v1/auth/request-otp` | Request mock OTP to registered phone | None |
| `POST` | `/api/v1/auth/verify-otp` | Verify OTP and receive JWT Bearer Token | None |
| `POST` | `/api/v1/auth/refresh` | Refresh expired access token via refresh token | None |
| `GET` | `/api/v1/auth/me` | Fetch authenticated user's unified profile & roles | `Bearer JWT` |
| `POST` | `/api/v1/farmer/profile` | Update farmer land, crops, and UPI payout ID | `ROLE_FARMER` |
| `POST` | `/api/v1/customer/profile`| Update customer delivery defaults | `ROLE_CUSTOMER` |

### 8.2 Service Areas & Geo-Eligibility
| HTTP Method | Route | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/service-areas` | List all operational delivery zones | Public |
| `GET` | `/api/v1/service-areas/validate?pinCode={pin}` | Check if PIN is eligible for delivery (411005, 411035) | Public |

### 8.3 Customer Addresses
| HTTP Method | Route | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/customer/addresses` | List all saved delivery addresses | `ROLE_CUSTOMER` |
| `POST` | `/api/v1/customer/addresses` | Add new address (validates postal code) | `ROLE_CUSTOMER` |
| `PUT` | `/api/v1/customer/addresses/{id}` | Update existing address | `ROLE_CUSTOMER` |
| `DELETE`| `/api/v1/customer/addresses/{id}` | Remove address | `ROLE_CUSTOMER` |

### 8.4 Catalog & Market Pricing
| HTTP Method | Route | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/catalog/categories` | List all 5 agricultural produce categories | Public |
| `GET` | `/api/v1/catalog/products` | List all active farm products (search, category, sort) | Public |
| `GET` | `/api/v1/catalog/products/{id}` | Retrieve single product details, nutrition, farm origin | Public |
| `GET` | `/api/v1/pricing/product/{id}` | Get real-time farmgate price, markup, and retail price | Public |

### 8.5 Cart & Weekly Produce Basket Planner
| HTTP Method | Route | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/cart` | Get current customer live market cart | `ROLE_CUSTOMER` |
| `POST` | `/api/v1/cart/items` | Add produce item to active cart | `ROLE_CUSTOMER` |
| `PUT` | `/api/v1/cart/items/{id}` | Update quantity (kg / count) in cart | `ROLE_CUSTOMER` |
| `DELETE`| `/api/v1/cart/items/{id}` | Remove item from cart | `ROLE_CUSTOMER` |
| `GET` | `/api/v1/weekly-cart` | Fetch Monday—Sunday planned vegetable meal basket | `ROLE_CUSTOMER` |
| `POST` | `/api/v1/weekly-cart/items` | Plan produce delivery for specific day of the week | `ROLE_CUSTOMER` |
| `DELETE`| `/api/v1/weekly-cart/items/{id}`| Remove planned day item | `ROLE_CUSTOMER` |

### 8.6 Recurring Subscriptions
| HTTP Method | Route | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/subscriptions` | List active weekly/bi-weekly farm subscriptions | `ROLE_CUSTOMER` |
| `POST` | `/api/v1/subscriptions` | Create recurring farm delivery subscription | `ROLE_CUSTOMER` |
| `PUT` | `/api/v1/subscriptions/{id}/pause` | Temporarily pause subscription | `ROLE_CUSTOMER` |
| `PUT` | `/api/v1/subscriptions/{id}/resume`| Resume paused subscription | `ROLE_CUSTOMER` |

### 8.7 Checkout, Orders, Mock Payments & Tracking
| HTTP Method | Route | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/v1/orders/checkout` | Compute final bill breakdown (produce total, delivery, tax) | `ROLE_CUSTOMER` |
| `POST` | `/api/v1/orders` | Place firm customer order | `ROLE_CUSTOMER` |
| `GET` | `/api/v1/orders` | List customer order history | `ROLE_CUSTOMER` |
| `GET` | `/api/v1/orders/{id}` | Get order details and invoice | `ROLE_CUSTOMER` |
| `POST` | `/api/v1/payments/mock-process` | Process mock payment (UPI, Card, COD) | `ROLE_CUSTOMER` |
| `GET` | `/api/v1/orders/{id}/tracking` | Get 9-stage supply chain verification tracking events | `ROLE_CUSTOMER` |

### 8.8 Farmer Produce Listings (Phase 2)
| HTTP Method | Route | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/farmer/listings` | List authenticated farmer's produce lots & stock | `ROLE_FARMER` |
| `POST` | `/api/v1/farmer/listings` | Declare new harvest lot with asking price & date | `ROLE_FARMER` |
| `PUT` | `/api/v1/farmer/listings/{id}` | Update quantity, grade, or availability status | `ROLE_FARMER` |
| `DELETE`| `/api/v1/farmer/listings/{id}` | Delist produce lot | `ROLE_FARMER` |

### 8.9 Diagnostics & Swagger Documentation
| HTTP Method | Route | Description | Auth Required |
|---|---|---|---|
| `GET` | `/actuator/health` | Spring Boot health status check | Public |
| `GET` | `/api/v1/health` | Application status & database connectivity check | Public |
| `GET` | `/swagger-ui/index.html` | Interactive Swagger UI API playground | Public |
| `GET` | `/v3/api-docs` | OpenAPI v3 JSON schema specification | Public |

---

## 9. 9-Stage Supply Chain Pipeline

Every order placed on KisanSetu progresses through a verifiable 9-stage supply chain lifecycle recorded in the `order_tracking_events` table:

```
[1. ORDER_PLACED] ➔ [2. FARMER_ASSIGNED] ➔ [3. HARVESTED] 
       ➔ [4. COLLECTION_CENTER_RECEIVED] ➔ [5. QUALITY_PASSED] 
       ➔ [6. CENTRAL_WAREHOUSE_PACKED] ➔ [7. OUT_FOR_DELIVERY] 
       ➔ [8. DELIVERED] ➔ [9. SETTLED]
```

1. **`ORDER_PLACED`**: Customer completes checkout and payment authorization.
2. **`FARMER_ASSIGNED`**: Local farmer listing matched to fulfill the ordered produce lot.
3. **`HARVESTED`**: Farmer confirms early-morning fresh harvest with lot identification.
4. **`COLLECTION_CENTER_RECEIVED`**: Produce arrives at local village collection center; digital weight verified.
5. **`QUALITY_PASSED`**: Quality inspection completed (Grade A certified; moisture & defect check).
6. **`CENTRAL_WAREHOUSE_PACKED`**: Produce transferred to suburban hub, sorted, eco-crate packed, and labelled.
7. **`OUT_FOR_DELIVERY`**: Delivery agent assigned with dispatch route in Shivajinagar or Akurdi.
8. **`DELIVERED`**: Doorstep handover confirmed with customer OTP.
9. **`SETTLED`**: Escrow funds automatically unlocked and credited to the farmer's registered UPI ID.

---

## 10. Port Matrix & Networking Configuration

| Component | Default Port | Internal / External | Description |
|---|---|---|---|
| **Spring Boot API** | `8080` | External | Main modular monolith backend (`/api/v1`) |
| **PostgreSQL 16** | `5432` | Container (`5432:5432`) | ACID relational database with PostGIS |
| **Redis 7** | `6379` | Container (`6379:6379`) | In-memory cache & rate limiter |
| **RabbitMQ AMQP** | `5672` | Container (`5672:5672`) | Message broker queue |
| **RabbitMQ Console** | `15672` | Container (`15672:15672`)| Web management interface (`guest` / `guest`) |
| **FastAPI AI Service**| `8000` | External (`:8000`) | Machine learning & RAG microservice |
| **React Admin Web** | `5173` | External (`:5173`) | Vite development web portal |
| **Nginx Reverse Proxy**| `80` | External (`:80`) | Production gateway reverse proxy |
| **Customer App** | Flutter Dynamic | Physical / Emulator | Android connects via `http://10.0.2.2:8080` |
| **Farmer App** | Flutter Dynamic | Physical / Emulator | Connects to `http://localhost:8080` / `10.0.2.2` |

---

## 11. Environment Variables & Configuration Reference

Managed in `.env` (derived from `.env.example`):

```ini
# Server Configuration
PORT=8080
SPRING_PROFILES_ACTIVE=local

# PostgreSQL Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=kisansetu_db
POSTGRES_USER=kisansetu_user
POSTGRES_PASSWORD=kisansetu_secret

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# RabbitMQ Configuration
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_MGMT_PORT=15672
RABBITMQ_USER=kisansetu
RABBITMQ_PASSWORD=kisansetu_secret

# Spring Security & JWT Configuration
JWT_SECRET=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
JWT_EXPIRATION_MS=86400000 # 24 Hours in milliseconds

# Client Base URLs
FLUTTER_API_BASE_URL=http://localhost:8080/api/v1
FLUTTER_ANDROID_API_BASE_URL=http://10.0.2.2:8080/api/v1
```

---

## 12. Pre-Seeded Test Credentials & Pilot Service Corridors

Database migrations `V6` and `V8` pre-populate development accounts and operational boundaries:

### 12.1 Pre-Seeded Development Accounts
All accounts use the default password: **`password123`** (BCrypt hashed in database).

| Role | Phone Number | Email | Associated Profile |
|---|---|---|---|
| **Admin** | `9876543210` | `admin@kisansetu.local` | Platform administrator with full privileges |
| **Customer** | `9876543211` | `customer@kisansetu.local` | Shivajinagar resident, saved delivery address |
| **Farmer** | `9876543212` | `farmer@kisansetu.local` | Pune rural producer, 5 acres, UPI ID configured |
| **Dual Role** | `9876543213` | `dual@kisansetu.local` | Holds both `ROLE_CUSTOMER` and `ROLE_FARMER` |

### 12.2 Pilot Service Zones
- **Shivajinagar Corridor**: Pune, Maharashtra — PIN Code: **`411005`**
- **Akurdi Corridor**: Pimpri-Chinchwad, Pune — PIN Code: **`411035`**

### 12.3 Seed Catalog Produce (13 Master Products)
1. Desi Tomato (टोमॅटो) — *Vegetables*
2. Fresh Spinach / Palak (पालक) — *Vegetables / Leafy*
3. Red Onion (कांदा) — *Vegetables*
4. Golden Potatoes (बटाटा) — *Vegetables*
5. Fresh Coriander / Kothimbir (कोथिंबीर) — *Vegetables / Herbs*
6. Green Chillies (हिरवी मिरची) — *Vegetables*
7. Alphonso Mangoes (हापूस आंबा) — *Fruits*
8. Robusta Bananas (केळी) — *Fruits*
9. Pomegranates / Anar (डाळिंब) — *Fruits*
10. Desi Cow A2 Milk (गायीचे दूध) — *Dairy*
11. Fresh Malai Paneer (पनीर) — *Dairy*
12. Organic Tur Dal (तूर डाळ) — *Pulses*
13. Indrayani Organic Rice (इंद्रायणी तांदूळ) — *Grains*

---

## 13. Windows Single-Laptop Helper Scripts

Located in the `scripts/` folder for rapid execution during development:

| Script File | Target Subsystem | Action Performed |
|---|---|---|
| `scripts\start-infra.bat` | Docker Compose | Starts Postgres, Redis, and RabbitMQ in detached mode (`docker compose up -d`) |
| `scripts\start-backend.bat` | Spring Boot | Runs Flyway migrations and boots backend on port `8080` via `mvnw.cmd spring-boot:run` |
| `scripts\start-customer-app.bat` | Customer Flutter | Boots Customer Mobile App on connected emulator or device (`flutter run`) |
| `scripts\start-farmer-app.bat` | Farmer Flutter | Boots Farmer Mobile App on connected emulator or device (`flutter run`) |
| `scripts\start-admin.bat` | React Admin Web | Starts Vite development server for Admin Web Portal on port `5173` |
| `scripts\start-ai.bat` | Python FastAPI | Runs FastAPI AI service via `uvicorn app.main:app --reload --port 8000` |

---
*Document generated and maintained for the KisanSetu Agricultural Supply Chain Platform.*
