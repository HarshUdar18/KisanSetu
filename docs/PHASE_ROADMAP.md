# Platform Phase Roadmap

## Phase 0: Architecture & Foundation (Current Phase) - COMPLETED
- [x] Monorepo workspace configuration (`apps/`, `backend/`, `ai-service/`, `infrastructure/`, `docs/`, `scripts/`).
- [x] Docker Compose local infrastructure (PostgreSQL 16 with PostGIS, Redis 7, RabbitMQ 3.13).
- [x] Spring Boot 3.3.5 modular monolith with 26 demarcated domain modules.
- [x] Flyway migrations `V1` to `V6` with seed data for roles, service areas, and test users.
- [x] Unified `User` entity supporting multi-role assignment (Customer + Farmer on single identity).
- [x] Stateless JWT authentication and Spring Security RBAC.
- [x] Core service abstractions with local mocks (`AuthenticationProvider`, `PaymentProvider`, `LocationService`, `NotificationService`, `StorageService`).
- [x] Two completely independent Flutter mobile applications (`apps/customer-app`, `apps/farmer-app`).
- [x] Admin Web Application (`apps/admin-panel`) in React 19 + TypeScript + Vite + MUI + TanStack Query.
- [x] AI Service foundation (`ai-service`) with FastAPI and `/health`.
- [x] Comprehensive documentation and single-laptop execution runbook.

---

## Phase 1: Customer Produce Commerce & Catalog
- Master agricultural catalog and category hierarchies (Fruits, Vegetables, Leafy Greens, Dairy, Staples).
- Pricing engine with transparent farmgate markup and retail price computation.
- Customer Mobile App: Product listing, search, filtering, and product detail screens.
- Customer Cart management and weekly delivery basket scheduler.
- Address management restricted to Shivajinagar and Akurdi service areas.
- Order placement state machine and Mock Payment Provider integration.

---

## Phase 2: Farmer Demand & Supply Aggregation
- Farmer Mobile App: Produce declaration, harvesting schedules, and spot listing.
- Demand forecasting feed displaying customer purchase trends.
- Collection center assignment and drop-off slot scheduling.
- Digital weight receipt generation upon drop-off.
- Real-time farmgate price transparency dashboard.

---

## Phase 3: Middle-Mile & Logistics Pipeline
- Collection center operations: Digital weight verification and initial quality grading.
- Cold-chain warehouse management: Sorting, grading, batch packing, and cross-docking.
- Regional hub transfer and routing to suburban micro-delivery stations.
- Delivery Partner App / workflows with route optimization and OTP delivery proof.
- End-to-end customer tracking and live delivery status updates.

---

## Phase 4: Financial Settlements & Admin Portal
- Automated farmer escrow settlements and UPI payouts.
- Bulk buyer B2B marketplace for institutional buyers and restaurants.
- Admin Panel: Real-time supply chain telemetry, quality metrics, dispute arbitration, and service area expansion.
- Detailed financial ledger auditing and commission reporting.

---

## Phase 5: AI & Intelligence Engine
- Computer-vision crop grading and defect detection via mobile camera.
- Regional weather alerts and predictive planting advisory.
- Multi-lingual Krishi scheme RAG (Retrieval-Augmented Generation) assistant in Marathi and Hindi.
