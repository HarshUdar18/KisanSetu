# Database Architecture & Migrations

## Overview

The platform uses a single PostgreSQL database instance (`kisansetu_db`) across all micro-modules and user types, running with PostGIS capabilities enabled (`postgis/postgis:16-3.4-alpine`).

A single relational schema guarantees ACID compliance across the entire farmer-to-customer agricultural supply chain.

---

## Connection Configuration

- **Database Name**: `kisansetu_db`
- **Default Port**: `5432`
- **Default User**: `kisansetu_user`
- **Default Password**: `kisansetu_pass`
- **JDBC URL**: `jdbc:postgresql://localhost:5432/kisansetu_db`

Environment-driven settings are declared in `.env` and injected into Spring Boot via `application.yml`.

---

## Flyway Migrations

Database schema versioning is managed strictly via Flyway. All migrations are stored under:
`backend/spring-boot-application/src/main/resources/db/migration/`

| Version | Migration File | Description |
|---|---|---|
| **V1** | `V1__create_user_tables.sql` | Core `users` table with UUID PK, phone, email, password_hash, status, timestamps |
| **V2** | `V2__create_role_tables.sql` | `roles` and `user_roles` junction table supporting multi-role assignment |
| **V3** | `V3__create_profiles.sql` | `customer_profiles` and `farmer_profiles` linked 1:1 with `users` |
| **V4** | `V4__create_service_areas.sql` | `service_areas` table with boundary geo-data, postal codes, and active status |
| **V5** | `V5__create_audit_tables.sql` | `audit_logs` table capturing action, entity, user, IP, and metadata |
| **V6** | `V6__seed_initial_data.sql` | Seed roles, service areas (Shivajinagar, Akurdi), and development accounts |
| **V7** | `V7__create_customer_phase1_tables.sql` | Complete Customer Phase 1 schema: addresses, catalog, pricing, carts, weekly carts, subscriptions, orders, payments, tracking |
| **V8** | `V8__seed_customer_phase1_catalog.sql` | Seed categories (Vegetables, Fruits, Pulses, Grains, Dairy), 13 farm products, dynamic price history, test address |
| **V9** | `V9__create_phase2_farmer_listings_and_refresh_tokens.sql` | Core Phase 2 tables: `farmer_listings` (farmer-specific produce stock and pricing) and `refresh_tokens` |


---

## Core Entities & Tables

### 1. `users`
Represents the unified user identity across all applications (Customer App, Farmer App, Admin Panel).

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    phone_number VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_status ON users(status);
```

### 2. `roles` & `user_roles`
Enables a single person to be both a `CUSTOMER` and a `FARMER` with zero profile duplication.

```sql
CREATE TABLE roles (
    id VARCHAR(50) PRIMARY KEY,
    description VARCHAR(255)
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id VARCHAR(50) NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);
```

### 3. `customer_profiles` & `farmer_profiles`
Specialized profile details linked to the single user record:
- **Customer**: Default delivery address, postal code, preferred delivery slot.
- **Farmer**: Farm name, village, taluka, district, state, pin code, land size in acres, primary crop categories, UPI ID.

### 4. `service_areas`
Geographically restricted deployment configuration. Validated at registration and checkout:
- **Shivajinagar**: Pune, Maharashtra (PIN: `411005`)
- **Akurdi**: Pimpri-Chinchwad, Pune (PIN: `411035`)

### 5. `audit_logs`
Records security and system events (registrations, logins, status changes, admin interventions):
- `id` (UUID), `user_id` (UUID nullable), `action`, `entity_type`, `entity_id`, `timestamp`, `ip_address`, `metadata` (JSONB).

### 6. `farmer_listings` (Phase 2)
Farmer-specific stock, available quantity, pricing per unit, harvest date, and availability status.
> **Key Architecture Decision**: Catalog `products` remain strictly decoupled from `farmer_listings`. One master catalog item (e.g. "Desi Tomato") can have multiple listings from distinct farmers with different availability, grades, and harvest dates.

```sql
CREATE TABLE farmer_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity_available NUMERIC(10, 2) NOT NULL,
    unit VARCHAR(20) NOT NULL DEFAULT 'kg',
    price_per_unit NUMERIC(10, 2) NOT NULL,
    harvest_date DATE,
    description TEXT,
    quality_grade VARCHAR(20) DEFAULT 'GRADE_A',
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_farmer_listings_farmer_id ON farmer_listings(farmer_id);
CREATE INDEX idx_farmer_listings_product_id ON farmer_listings(product_id);
CREATE INDEX idx_farmer_listings_is_available ON farmer_listings(is_available);
```

### 7. `refresh_tokens` (Phase 2)
Manages persistent user sessions, token rotation, and invalidation:
```sql
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
```

---

## Indexing Strategy
- Primary Keys: B-Tree on UUIDs
- Search & Auth: B-Tree on `phone_number`, `email`
- Status & Filters: Indexes on `status`, `role_id`, `pin_code`
- Spatial & Geocoding: Prepared for PostGIS GIST indexes on boundary geometries in Phase 1
