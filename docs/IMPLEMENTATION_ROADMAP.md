# IMPLEMENTATION_ROADMAP.md — Kisan Setu Development Roadmap

**Date:** 2026-11-25  
**Team:** 1 Principal Architect + developers

---

## Milestone 1 — Foundation Fixes (Week 1)
**Goal:** Make the existing platform fully testable end-to-end with real data.

### Tasks
| # | Task | Service/App | Priority | Effort |
|---|------|------------|---------|--------|
| 1.1 | Add `ProductController` with `GET /products`, `GET /products/{id}`, filter/search | Backend | P0 | 2h |
| 1.2 | Fix Admin `GET /admin/orders` endpoint | Backend | P0 | 3h |
| 1.3 | Add `POST /auth/refresh` for token renewal | Backend | P0 | 2h |
| 1.4 | Add `POST /auth/reset-password` (OTP-based) | Backend | P0 | 2h |
| 1.5 | Merge duplicate `payment` / `payments` modules | Backend | P0 | 1h |
| 1.6 | Update Customer App `CatalogProvider` to use `GET /products/{id}` | Customer App | P0 | 1h |
| 1.7 | Wire Admin panel to `GET /admin/orders` | Admin Panel | P0 | 2h |
| 1.8 | Add token refresh interceptor to Dio (Customer + Farmer) | Flutter | P1 | 3h |
| 1.9 | Add token refresh interceptor to Axios (Admin) | Admin Panel | P1 | 2h |

**Milestone 1 Deliverable:** Customer can register, browse products (real data), add to cart, checkout, see orders.

---

## Milestone 2 — Farmer Complete Flow (Week 2)
**Goal:** Farmer can register, complete KYC, list produce, see demands.

### Tasks
| # | Task | Service/App | Priority | Effort |
|---|------|------------|---------|--------|
| 2.1 | Implement KYC module: entity, Flyway migration, controller, service | Backend | P1 | 1 day |
| 2.2 | Implement `POST /kyc` and `GET /kyc/status` endpoints | Backend | P1 | 4h |
| 2.3 | Implement Admin KYC review: `GET /admin/kyc`, `PUT /admin/kyc/{id}/approve` | Backend | P1 | 4h |
| 2.4 | Connect Farmer App `KycProvider` to real endpoints | Farmer App | P1 | 3h |
| 2.5 | Connect Admin Panel KYC page to real endpoints | Admin Panel | P1 | 3h |
| 2.6 | Implement Demand module: entity, Flyway V10, controller, service | Backend | P1 | 1 day |
| 2.7 | Connect Farmer App `DemandProvider` to real endpoints | Farmer App | P1 | 3h |
| 2.8 | Implement `GET /farmers/me/dashboard` aggregation | Backend | P2 | 4h |
| 2.9 | Connect Farmer App `DashboardScreen` to real dashboard endpoint | Farmer App | P2 | 2h |

**Milestone 2 Deliverable:** Farmer completes full onboarding, KYC, lists produce, sees demand requests from admin/customers.

---

## Milestone 3 — Payment & Settlement (Week 3)
**Goal:** Real payment flow; farmer settlement calculation.

### Tasks
| # | Task | Service/App | Priority | Effort |
|---|------|------------|---------|--------|
| 3.1 | Integrate Razorpay SDK into payment module | Backend | P1 | 1 day |
| 3.2 | Implement `POST /payments/webhook` with signature verification | Backend | P1 | 4h |
| 3.3 | Update Customer App payment screens to use Razorpay mobile SDK | Customer App | P1 | 1 day |
| 3.4 | Implement Settlement module: entity, Flyway V11, controller, service | Backend | P1 | 1 day |
| 3.5 | Implement `POST /admin/settlements/{id}/authorize` | Backend | P1 | 4h |
| 3.6 | Connect Farmer App `SettlementsProvider` to real endpoints | Farmer App | P1 | 3h |
| 3.7 | Connect Admin Panel settlements page to real endpoints | Admin Panel | P1 | 3h |
| 3.8 | Wire RabbitMQ: `PaymentSucceeded` → settlement-service → creates settlement | Backend | P1 | 4h |

**Milestone 3 Deliverable:** Customer pays via UPI/card; farmer receives settlement notification; admin authorizes DBT.

---

## Milestone 4 — Supply Chain (Week 4)
**Goal:** Collection, quality inspection, inventory management working.

### Tasks
| # | Task | Service/App | Priority | Effort |
|---|------|------------|---------|--------|
| 4.1 | Implement Collection module: entity, Flyway V12, controller, service | Backend | P1 | 1 day |
| 4.2 | Implement Quality Inspection module: entity, Flyway V13, controller, service | Backend | P1 | 1 day |
| 4.3 | Implement Inventory module: entity, Flyway V14, controller, service | Backend | P1 | 1 day |
| 4.4 | Connect Farmer App `CollectionProvider` to real endpoints | Farmer App | P1 | 3h |
| 4.5 | Connect Admin Panel supply chain pages to real endpoints | Admin Panel | P1 | 1 day |
| 4.6 | Wire RabbitMQ: `CollectionCreated` → quality; `QualityInspected` → inventory | Backend | P1 | 4h |
| 4.7 | Wire RabbitMQ: `QualityInspected` → settlement (grade-based price) | Backend | P1 | 3h |

---

## Milestone 5 — Notifications & Support (Week 5)
**Goal:** Real push notifications; support ticket system working.

### Tasks
| # | Task | Service/App | Priority | Effort |
|---|------|------------|---------|--------|
| 5.1 | Integrate Firebase FCM: add `POST /notifications/register-token` | Backend | P1 | 1 day |
| 5.2 | Implement notification log and preferences: entity, controller | Backend | P1 | 4h |
| 5.3 | Add FCM device token registration in Customer App | Customer App | P1 | 2h |
| 5.4 | Add FCM device token registration in Farmer App | Farmer App | P1 | 2h |
| 5.5 | Wire RabbitMQ: ALL events → notification-service → FCM push | Backend | P1 | 1 day |
| 5.6 | Integrate MSG91 for real SMS OTP | Backend | P1 | 4h |
| 5.7 | Implement Support Ticket module: entity, Flyway V15, controller | Backend | P2 | 1 day |
| 5.8 | Connect Customer App support screens to real ticket endpoints | Customer App | P2 | 3h |
| 5.9 | Connect Admin Panel support page to real endpoints | Admin Panel | P2 | 3h |

---

## Milestone 6 — Analytics & Polishing (Week 6)
**Goal:** Admin analytics dashboard with real data; full platform stabilization.

### Tasks
| # | Task | Service/App | Priority | Effort |
|---|------|------------|---------|--------|
| 6.1 | Implement `GET /analytics/dashboard` aggregation query | Backend | P2 | 1 day |
| 6.2 | Implement `GET /analytics/revenue` time-series data | Backend | P2 | 4h |
| 6.3 | Connect Admin analytics dashboard to real endpoints | Admin Panel | P2 | 4h |
| 6.4 | Add Redis caching to CatalogService, ProductService, PricingService | Backend | P2 | 4h |
| 6.5 | Add `GET /orders/{id}/invoice` PDF generation | Backend | P2 | 1 day |
| 6.6 | Add FPO module (entity, controller, farmer-FPO association) | Backend | P3 | 1 day |
| 6.7 | Implement Govt Schemes module | Backend | P3 | 4h |
| 6.8 | Add `POST /auth/reset-password` verified in all 3 apps | All | P2 | 4h |
| 6.9 | Full end-to-end regression testing | All | P0 | 2 days |

---

## Milestone 7 — Microservices Migration (Week 7–8)
**Goal:** Gradually extract services from monolith (Strangler Fig pattern).

### Tasks
| # | Task | Effort |
|---|------|--------|
| 7.1 | Create API Gateway (Spring Cloud Gateway) as proxy to monolith | 1 day |
| 7.2 | Update all 3 frontends to point to gateway | 2h |
| 7.3 | Extract auth-service | 2 days |
| 7.4 | Extract product-service | 1 day |
| 7.5 | Extract order-service | 2 days |
| 7.6 | Update docker-compose.yml with all service containers | 1 day |
| 7.7 | Configure gateway routing to extracted services | 4h |
| 7.8 | Load test with k6 | 1 day |

---

## Total Estimates

| Phase | Timeline | Complexity |
|-------|---------|-----------|
| Milestone 1 | 1 week | Low |
| Milestone 2 | 1 week | Medium |
| Milestone 3 | 1 week | High |
| Milestone 4 | 1 week | High |
| Milestone 5 | 1 week | Medium |
| Milestone 6 | 1 week | Medium |
| Milestone 7 | 2 weeks | Very High |
| **Total** | **~8 weeks** | |
