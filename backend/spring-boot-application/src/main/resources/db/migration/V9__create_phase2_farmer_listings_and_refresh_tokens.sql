-- V9: Create Farmer Listings and Refresh Tokens Tables for Phase 2

-- 1. Create Farmer Listings Table
CREATE TABLE IF NOT EXISTS farmer_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity_available NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    unit VARCHAR(20) NOT NULL DEFAULT 'kg',
    price_per_unit NUMERIC(10, 2) NOT NULL,
    harvest_date DATE,
    description TEXT,
    quality_grade VARCHAR(20) NOT NULL DEFAULT 'GRADE_A',
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_farmer_listings_farmer_id ON farmer_listings(farmer_id);
CREATE INDEX IF NOT EXISTS idx_farmer_listings_product_id ON farmer_listings(product_id);
CREATE INDEX IF NOT EXISTS idx_farmer_listings_status ON farmer_listings(status);
CREATE INDEX IF NOT EXISTS idx_farmer_listings_available ON farmer_listings(is_available);

-- 2. Create Refresh Tokens Table
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);

-- 3. Seed Sample Farmer Listings (Tukaram Patil - Farmer ID: a0000000-0000-0000-0000-000000000003)
INSERT INTO farmer_listings (id, farmer_id, product_id, quantity_available, unit, price_per_unit, harvest_date, description, quality_grade, is_available, status) VALUES
    ('l0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000001', 450.00, 'kg', 27.50, CURRENT_DATE + INTERVAL '1 day', 'Freshly plucked organic Desi Tomatoes from Khed polyhouse', 'GRADE_A', TRUE, 'ACTIVE'),
    ('l0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000002', 800.00, 'kg', 31.00, CURRENT_DATE - INTERVAL '2 days', 'Well-dried, medium graded Nashik Red Onions ready for transit', 'GRADE_A', TRUE, 'ACTIVE'),
    ('l0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000003', 1000.00, 'kg', 22.00, CURRENT_DATE, 'Freshly dug clean mountain potatoes', 'GRADE_A', TRUE, 'ACTIVE'),
    ('l0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000011', 1500.00, 'kg', 44.00, CURRENT_DATE - INTERVAL '5 days', 'Cleaned and bagged Lokwan Sharbati Wheat, moisture content < 12%', 'GRADE_A', TRUE, 'ACTIVE')
ON CONFLICT (id) DO NOTHING;
