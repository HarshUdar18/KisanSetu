-- V12: Stock Movements, Processed Events (Idempotency), Farmer Agronomy Fields, Farmer Store, Govt Schemes

-- 1. Stock Movement Ledger for Supply-Chain Quantity Conservation
CREATE TABLE IF NOT EXISTS stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL,
    movement_type VARCHAR(40) NOT NULL, -- RESERVED, RELEASED, QUALITY_INBOUND, SHIPMENT_OUTBOUND, ADJUSTMENT
    quantity_kg NUMERIC(10, 2) NOT NULL,
    reference_id UUID,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stock_movements_product_id ON stock_movements(product_id);

-- 2. Idempotent Event Deduplication Table for RabbitMQ Consumers
CREATE TABLE IF NOT EXISTS processed_events (
    event_id VARCHAR(100) PRIMARY KEY,
    event_type VARCHAR(120) NOT NULL,
    processed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Order Idempotency Key
ALTER TABLE orders ADD COLUMN IF NOT EXISTS idempotency_key VARCHAR(100) UNIQUE;

-- 4. Extended Farmer Agronomy & Location Fields
ALTER TABLE farmer_profiles ADD COLUMN IF NOT EXISTS farm_name VARCHAR(150);
ALTER TABLE farmer_profiles ADD COLUMN IF NOT EXISTS land_area NUMERIC(10, 2);
ALTER TABLE farmer_profiles ADD COLUMN IF NOT EXISTS land_unit VARCHAR(20) DEFAULT 'Acres';
ALTER TABLE farmer_profiles ADD COLUMN IF NOT EXISTS soil_type VARCHAR(60);
ALTER TABLE farmer_profiles ADD COLUMN IF NOT EXISTS irrigation_type VARCHAR(60);
ALTER TABLE farmer_profiles ADD COLUMN IF NOT EXISTS farming_experience_years INT;
ALTER TABLE farmer_profiles ADD COLUMN IF NOT EXISTS latitude NUMERIC(10, 7);
ALTER TABLE farmer_profiles ADD COLUMN IF NOT EXISTS longitude NUMERIC(10, 7);

-- 5. Farmer Store Products & Orders
CREATE TABLE IF NOT EXISTS farmer_store_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    category VARCHAR(80) NOT NULL,
    unit VARCHAR(30) NOT NULL DEFAULT 'packet',
    mrp NUMERIC(10, 2) NOT NULL,
    subsidized_price NUMERIC(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 100,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS farmer_store_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'CONFIRMED',
    items_json TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 6. Government Schemes
CREATE TABLE IF NOT EXISTS govt_schemes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    ministry VARCHAR(150) NOT NULL,
    category VARCHAR(80) NOT NULL,
    benefit_summary TEXT NOT NULL,
    eligibility TEXT,
    apply_url VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
