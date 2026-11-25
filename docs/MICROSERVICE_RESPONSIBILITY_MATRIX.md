# MICROSERVICE_RESPONSIBILITY_MATRIX.md

**Date:** 2026-11-25

This matrix defines what each microservice owns, what it consumes, and what events it publishes/subscribes.

---

| Service | Owns (Data) | Exposes (APIs) | Publishes (Events) | Subscribes (Events) |
|---------|------------|---------------|-------------------|---------------------|
| **auth-service** | users (auth), refresh_tokens, otp_sessions | POST /auth/register, login, send-otp, verify-otp, logout, refresh | UserRegistered, OtpVerified | — |
| **user-service** | user_profiles (customer), addresses | GET/PUT /users/me, GET/POST/PUT/DELETE /users/me/addresses, GET /admin/users | — | UserRegistered |
| **farmer-service** | farmer_profiles, farm_plots, fpo_associations | GET/PUT /farmers/me, GET /farmers/{id}, GET /admin/farmers | FarmerProfileUpdated | KycApproved, UserRegistered |
| **kyc-service** | kyc_submissions, kyc_documents | POST /kyc, GET /kyc/status, GET/PUT /admin/kyc | KycSubmitted, KycApproved, KycRejected | UserRegistered |
| **product-service** | product_categories, products, market_prices, price_history, service_areas | GET /categories, GET /products, GET /products/{id}, GET/PUT /prices/{id}, GET /service-areas | ProductPriceChanged | — |
| **produce-service** | farmer_listings, surplus_produce | GET/POST /produce, GET/PUT/DELETE /produce/{id}, GET /produce/farmer/{farmerId} | ProduceListed, ProduceUpdated | KycApproved, InventoryUpdated |
| **demand-service** | demand_requests, demand_acceptances | GET/POST /demands, GET /demands/{id}, PUT /demands/{id}/accept | DemandCreated, DemandAccepted | ProduceListed, InventoryUpdated |
| **cart-service** | carts, cart_items, weekly_carts, weekly_cart_days, weekly_cart_items, subscriptions | GET/POST /cart, POST/PUT/DELETE /cart/items, GET/POST /weekly-cart, GET/POST/PUT/DELETE /subscriptions | CartCheckedOut | ProductPriceChanged |
| **order-service** | orders, order_items | POST /orders/checkout, GET /orders, GET/DELETE /orders/{id}, POST /orders/{id}/cancel, GET /admin/orders | OrderCreated, OrderConfirmed, OrderCancelled | PaymentSucceeded, PaymentFailed, DemandAccepted, OrderDelivered |
| **payment-service** | payments, payment_transactions | POST /payments/initiate, GET /payments/{id}, POST /payments/webhook, POST /admin/payments/{id}/refund | PaymentInitiated, PaymentSucceeded, PaymentFailed | OrderCreated |
| **settlement-service** | settlements, settlement_items | GET /settlements, GET /settlements/{id}, POST /admin/settlements/{id}/authorize | SettlementAuthorized, SettlementPaid | PaymentSucceeded, QualityInspected, OrderDelivered |
| **collection-service** | collection_points, gate_passes, collection_records | GET /collections, POST /collections, GET /collections/{id}, PUT /collections/{id}/close | CollectionCreated, GatePassIssued | OrderConfirmed |
| **quality-service** | quality_inspections, inspection_items | POST /quality, GET /quality/{id}, PUT /quality/{id}/complete, GET /admin/quality | QualityInspected | CollectionCreated |
| **inventory-service** | warehouse_stock, stock_transactions | GET /inventory, PUT /inventory/{productId}, GET /admin/inventory | InventoryUpdated, StockLow | OrderCreated, OrderCancelled, QualityInspected, CollectionCreated |
| **logistics-service** | deliveries, delivery_assignments, tracking_events | GET /tracking/order/{id}, PUT /tracking/{id}/update, WebSocket /ws/tracking/{orderId} | OrderDispatched, OrderDelivered, DeliveryLocationUpdated | OrderConfirmed |
| **notification-service** | notification_logs, device_tokens, notification_prefs | POST /notifications/register-token, GET /notifications, PUT /notifications/{id}/read, GET/PUT /notifications/preferences | — | ALL events |
| **support-service** | support_tickets, ticket_messages | POST /support/tickets, GET /support/tickets, GET /support/tickets/{id}, POST /support/tickets/{id}/reply, WebSocket /ws/support/{ticketId} | TicketCreated, TicketResolved | — |
| **analytics-service** | aggregated_metrics, reports | GET /analytics/dashboard, GET /analytics/revenue, GET /analytics/farmers, GET /analytics/orders | — | OrderDelivered, PaymentSucceeded, UserRegistered, KycApproved |
| **ai-service** | — (stateless) | POST /ai/crop-advisory, GET /ai/weather/{pincode}, POST /ai/price-prediction | — | ProductPriceChanged |

---

## Shared Data Contracts (Canonical IDs)

Each service stores only the UUID of entities owned by other services:

| Reference | Owned By | Stored As (in other services) |
|-----------|---------|-------------------------------|
| `userId` | auth-service | UUID reference in all services |
| `farmerProfileId` | farmer-service | UUID reference in produce, kyc, settlement |
| `productId` | product-service | UUID reference in produce, cart, order, inventory |
| `orderId` | order-service | UUID reference in payment, logistics, tracking |
| `paymentId` | payment-service | UUID reference in settlement |
| `listingId` | produce-service | UUID reference in demand, order |
| `collectionId` | collection-service | UUID reference in quality |
| `warehouseId` | inventory-service | UUID reference in collection, logistics |

---

## Inter-Service Communication Rules

1. **Synchronous (REST):** Use only for user-initiated requests that require an immediate response
2. **Asynchronous (RabbitMQ):** Use for all state change notifications and cross-service side effects
3. **No direct DB access:** Services MUST NOT query another service's database schema
4. **No shared libraries with business logic:** Only share DTOs/event contracts as JAR artifacts
5. **Failure isolation:** Each service has independent circuit breakers (Resilience4j)
6. **Service-to-service auth:** Internal calls use a service account JWT (not user tokens)
