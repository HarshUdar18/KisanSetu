# DATABASE_MIGRATION_PLAN.md

**Date:** 2026-11-25

## Strategy: Schema-Per-Service on Single PostgreSQL Server

We use a single PostgreSQL 16 server instance with separate schemas for each service. This avoids cross-service DB queries while keeping infrastructure simple for the MVP phase. Schema separation can be promoted to full DB-per-service (separate instances) in a future scaling phase.

---

## Phase 1: Monolith Schema Partitioning (Current → Target)

The existing `public` schema in `kisansetu_db` will be migrated to named schemas:

```sql
-- Create service schemas
CREATE SCHEMA IF NOT EXISTS auth_db;
CREATE SCHEMA IF NOT EXISTS user_db;
CREATE SCHEMA IF NOT EXISTS farmer_db;
CREATE SCHEMA IF NOT EXISTS kyc_db;
CREATE SCHEMA IF NOT EXISTS product_db;
CREATE SCHEMA IF NOT EXISTS produce_db;
CREATE SCHEMA IF NOT EXISTS demand_db;
CREATE SCHEMA IF NOT EXISTS cart_db;
CREATE SCHEMA IF NOT EXISTS order_db;
CREATE SCHEMA IF NOT EXISTS payment_db;
CREATE SCHEMA IF NOT EXISTS settlement_db;
CREATE SCHEMA IF NOT EXISTS collection_db;
CREATE SCHEMA IF NOT EXISTS quality_db;
CREATE SCHEMA IF NOT EXISTS inventory_db;
CREATE SCHEMA IF NOT EXISTS logistics_db;
CREATE SCHEMA IF NOT EXISTS notification_db;
CREATE SCHEMA IF NOT EXISTS support_db;
CREATE SCHEMA IF NOT EXISTS analytics_db;
```

---

## Table Migration Map

| Existing Table (public.*) | Target Schema | Service Owner | Migration Priority |
|--------------------------|--------------|--------------|-------------------|
| `users` | `auth_db.users` | auth-service | P0 |
| `roles` | `auth_db.roles` | auth-service | P0 |
| `user_roles` | `auth_db.user_roles` | auth-service | P0 |
| `refresh_tokens` | `auth_db.refresh_tokens` | auth-service | P0 |
| `audit_logs` | `auth_db.audit_logs` | auth-service | P0 |
| `farmer_profiles` | `farmer_db.farmer_profiles` | farmer-service | P1 |
| `customer_profiles` | `user_db.customer_profiles` | user-service | P1 |
| `addresses` | `user_db.addresses` | user-service | P1 |
| `service_areas` | `product_db.service_areas` | product-service | P1 |
| `product_categories` | `product_db.product_categories` | product-service | P1 |
| `products` | `product_db.products` | product-service | P1 |
| `product_images` | `product_db.product_images` | product-service | P1 |
| `market_prices` | `product_db.market_prices` | product-service | P1 |
| `price_history` | `product_db.price_history` | product-service | P1 |
| `farmer_listings` | `produce_db.farmer_listings` | produce-service | P1 |
| `carts` | `cart_db.carts` | cart-service | P1 |
| `cart_items` | `cart_db.cart_items` | cart-service | P1 |
| `weekly_carts` | `cart_db.weekly_carts` | cart-service | P1 |
| `weekly_cart_days` | `cart_db.weekly_cart_days` | cart-service | P1 |
| `weekly_cart_items` | `cart_db.weekly_cart_items` | cart-service | P1 |
| `orders` | `order_db.orders` | order-service | P1 |
| `order_items` | `order_db.order_items` | order-service | P1 |
| `payments` | `payment_db.payments` | payment-service | P1 |
| `payment_transactions` | `payment_db.payment_transactions` | payment-service | P1 |
| `tracking_events` | `logistics_db.tracking_events` | logistics-service | P2 |

### New Tables to Create (Missing Modules)

| Table | Schema | Service | Description |
|-------|--------|---------|-------------|
| `kyc_submissions` | `kyc_db` | kyc-service | KYC submission records |
| `kyc_documents` | `kyc_db` | kyc-service | Uploaded document metadata |
| `fpo_organizations` | `farmer_db` | farmer-service | FPO master list |
| `farmer_fpo_members` | `farmer_db` | farmer-service | Farmer-FPO association |
| `farm_plots` | `farmer_db` | farmer-service | Farm land records |
| `surplus_produce` | `produce_db` | produce-service | Surplus listings |
| `demand_requests` | `demand_db` | demand-service | Buyer demand requests |
| `demand_acceptances` | `demand_db` | demand-service | Farmer demand acceptances |
| `subscriptions` | `cart_db` | cart-service | Customer subscriptions |
| `subscription_items` | `cart_db` | cart-service | Subscription line items |
| `settlements` | `settlement_db` | settlement-service | Farmer payment settlements |
| `settlement_items` | `settlement_db` | settlement-service | Per-order settlement breakdown |
| `collection_points` | `collection_db` | collection-service | Physical collection centers |
| `collection_records` | `collection_db` | collection-service | Produce collection events |
| `gate_passes` | `collection_db` | collection-service | Vehicle gate passes |
| `quality_inspections` | `quality_db` | quality-service | QC inspection records |
| `warehouse_stock` | `inventory_db` | inventory-service | Current stock per product |
| `stock_transactions` | `inventory_db` | inventory-service | Stock in/out log |
| `deliveries` | `logistics_db` | logistics-service | Delivery assignments |
| `device_tokens` | `notification_db` | notification-service | FCM device tokens |
| `notifications` | `notification_db` | notification-service | Notification log |
| `notification_prefs` | `notification_db` | notification-service | User notification settings |
| `support_tickets` | `support_db` | support-service | Customer/farmer support tickets |
| `ticket_messages` | `support_db` | support-service | Ticket message thread |
| `govt_schemes` | `analytics_db` | analytics-service | Government scheme listings |

---

## Migration SQL Script Template (V10 — Schema Migration)

```sql
-- =============================================
-- V10__migrate_to_service_schemas.sql
-- Run ONCE to partition existing tables
-- =============================================

BEGIN;

-- Auth Service Tables
CREATE SCHEMA IF NOT EXISTS auth_db;
ALTER TABLE public.users SET SCHEMA auth_db;
ALTER TABLE public.roles SET SCHEMA auth_db;
ALTER TABLE public.user_roles SET SCHEMA auth_db;
ALTER TABLE public.refresh_tokens SET SCHEMA auth_db;
ALTER TABLE public.audit_logs SET SCHEMA auth_db;

-- User Service Tables
CREATE SCHEMA IF NOT EXISTS user_db;
ALTER TABLE public.customer_profiles SET SCHEMA user_db;
ALTER TABLE public.addresses SET SCHEMA user_db;

-- Farmer Service Tables
CREATE SCHEMA IF NOT EXISTS farmer_db;
ALTER TABLE public.farmer_profiles SET SCHEMA farmer_db;

-- Product Service Tables
CREATE SCHEMA IF NOT EXISTS product_db;
ALTER TABLE public.service_areas SET SCHEMA product_db;
ALTER TABLE public.product_categories SET SCHEMA product_db;
ALTER TABLE public.products SET SCHEMA product_db;
ALTER TABLE public.product_images SET SCHEMA product_db;
ALTER TABLE public.market_prices SET SCHEMA product_db;
ALTER TABLE public.price_history SET SCHEMA product_db;

-- Produce Service Tables
CREATE SCHEMA IF NOT EXISTS produce_db;
ALTER TABLE public.farmer_listings SET SCHEMA produce_db;

-- Cart Service Tables
CREATE SCHEMA IF NOT EXISTS cart_db;
ALTER TABLE public.carts SET SCHEMA cart_db;
ALTER TABLE public.cart_items SET SCHEMA cart_db;
ALTER TABLE public.weekly_carts SET SCHEMA cart_db;
ALTER TABLE public.weekly_cart_days SET SCHEMA cart_db;
ALTER TABLE public.weekly_cart_items SET SCHEMA cart_db;

-- Order Service Tables
CREATE SCHEMA IF NOT EXISTS order_db;
ALTER TABLE public.orders SET SCHEMA order_db;
ALTER TABLE public.order_items SET SCHEMA order_db;

-- Payment Service Tables
CREATE SCHEMA IF NOT EXISTS payment_db;
ALTER TABLE public.payments SET SCHEMA payment_db;
ALTER TABLE public.payment_transactions SET SCHEMA payment_db;

-- Logistics Service Tables
CREATE SCHEMA IF NOT EXISTS logistics_db;
ALTER TABLE public.tracking_events SET SCHEMA logistics_db;

COMMIT;
```

> [!WARNING]
> Execute the schema migration only after all services have been updated to use `spring.jpa.properties.hibernate.default_schema` pointing to their new schema. Running this migration while the monolith is still using `public.*` will cause application failures.

---

## Flyway Strategy Per Service

Each microservice maintains its own Flyway migration history in its schema:

```yaml
# Example: auth-service application.yml
spring:
  flyway:
    enabled: true
    schemas: auth_db
    table: flyway_schema_history
    locations: classpath:db/migration
    baseline-on-migrate: true
```

Each service has its own `V1__init.sql` file that creates its tables in its schema.

---

## Rollback Plan

1. **Before migration:** Take a full PostgreSQL dump: `pg_dump kisansetu_db > backup_pre_migration.sql`
2. **Schema migration can be reversed:** `ALTER TABLE auth_db.users SET SCHEMA public;` etc.
3. **Monolith remains running** throughout Phase 1 (gateway proxies to it)
4. **Traffic cutover** happens per-service, not all at once
5. **Feature flags** in API Gateway route traffic to monolith vs microservice
