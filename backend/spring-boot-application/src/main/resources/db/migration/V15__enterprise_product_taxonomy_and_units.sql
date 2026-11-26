-- V15: Enterprise Product Taxonomy, Multilingual Translations, Varieties, Variants, and Unit System

-- 1. Product Units (Mass, Count, Volume, Area)
CREATE TABLE IF NOT EXISTS product_units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(60) NOT NULL,
    category VARCHAR(20) NOT NULL CHECK (category IN ('MASS', 'COUNT', 'VOLUME', 'AREA')),
    symbol VARCHAR(20) NOT NULL,
    is_base_unit BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Explicit Unit Conversions (strictly within same unit category)
CREATE TABLE IF NOT EXISTS unit_conversions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_unit_id UUID NOT NULL REFERENCES product_units(id) ON DELETE CASCADE,
    to_unit_id UUID NOT NULL REFERENCES product_units(id) ON DELETE CASCADE,
    conversion_factor NUMERIC(18, 6) NOT NULL CHECK (conversion_factor > 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_unit_conversion UNIQUE (from_unit_id, to_unit_id)
);

-- Seed Units
INSERT INTO product_units (id, code, name, category, symbol, is_base_unit) VALUES
    ('10000000-0000-0000-0000-000000000001', 'mg', 'Milligram', 'MASS', 'mg', FALSE),
    ('10000000-0000-0000-0000-000000000002', 'g', 'Gram', 'MASS', 'g', FALSE),
    ('10000000-0000-0000-0000-000000000003', 'kg', 'Kilogram', 'MASS', 'kg', TRUE),
    ('10000000-0000-0000-0000-000000000004', 'quintal', 'Quintal', 'MASS', 'qtl', FALSE),
    ('10000000-0000-0000-0000-000000000005', 'tonne', 'Metric Tonne', 'MASS', 't', FALSE),
    ('10000000-0000-0000-0000-000000000006', 'piece', 'Piece', 'COUNT', 'pc', TRUE),
    ('10000000-0000-0000-0000-000000000007', 'dozen', 'Dozen', 'COUNT', 'doz', FALSE),
    ('10000000-0000-0000-0000-000000000008', 'bunch', 'Bunch', 'COUNT', 'bunch', FALSE),
    ('10000000-0000-0000-0000-000000000009', 'crate', 'Crate', 'COUNT', 'crate', FALSE),
    ('10000000-0000-0000-0000-000000000010', 'bag', 'Bag', 'COUNT', 'bag', FALSE),
    ('10000000-0000-0000-0000-000000000011', 'ml', 'Millilitre', 'VOLUME', 'ml', FALSE),
    ('10000000-0000-0000-0000-000000000012', 'litre', 'Litre', 'VOLUME', 'L', TRUE),
    ('10000000-0000-0000-0000-000000000013', 'sqm', 'Square Metre', 'AREA', 'm2', TRUE),
    ('10000000-0000-0000-0000-000000000014', 'acre', 'Acre', 'AREA', 'acre', FALSE),
    ('10000000-0000-0000-0000-000000000015', 'hectare', 'Hectare', 'AREA', 'ha', FALSE),
    ('10000000-0000-0000-0000-000000000016', 'guntha', 'Guntha', 'AREA', 'guntha', FALSE)
ON CONFLICT (code) DO NOTHING;

-- Seed Valid Same-Category Unit Conversions
INSERT INTO unit_conversions (from_unit_id, to_unit_id, conversion_factor) VALUES
    ('10000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 1000.000000), -- g -> mg
    ('10000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', 1000.000000), -- kg -> g
    ('10000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000003', 100.000000),  -- quintal -> kg
    ('10000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000003', 1000.000000), -- tonne -> kg
    ('10000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000006', 12.000000),   -- dozen -> piece
    ('10000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000011', 1000.000000), -- litre -> ml
    ('10000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000013', 4046.856422), -- acre -> sqm
    ('10000000-0000-0000-0000-000000000015', '10000000-0000-0000-0000-000000000013', 10000.000000),-- hectare -> sqm
    ('10000000-0000-0000-0000-000000000016', '10000000-0000-0000-0000-000000000013', 101.171410)   -- guntha -> sqm
ON CONFLICT (from_unit_id, to_unit_id) DO NOTHING;

-- 3. Hierarchical Categories
ALTER TABLE product_categories
    ADD COLUMN IF NOT EXISTS parent_category_id UUID REFERENCES product_categories(id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_product_categories_parent ON product_categories(parent_category_id);

INSERT INTO product_categories (id, name, code, description, icon_url, display_order, is_active) VALUES
    ('e0000000-0000-0000-0000-000000000005', 'Spices and Condiments', 'SPICES', 'Whole and fresh spices, condiments, and aromatics', 'spices.png', 5, TRUE),
    ('e0000000-0000-0000-0000-000000000006', 'Oilseeds', 'OILSEEDS', 'Oil-bearing agricultural seeds', 'oilseeds.png', 6, TRUE),
    ('e0000000-0000-0000-0000-000000000007', 'Commercial and Cash Crops', 'CASH_CROPS', 'Industrial and commercial cash crops', 'cash_crops.png', 7, TRUE),
    ('e0000000-0000-0000-0000-000000000008', 'Herbs and Leafy Produce', 'HERBS', 'Fresh culinary herbs and leafy greens', 'herbs.png', 8, TRUE),
    ('e0000000-0000-0000-0000-000000000009', 'Other Agricultural Products', 'OTHER', 'Other verified agricultural produce', 'other.png', 9, TRUE)
ON CONFLICT (code) DO NOTHING;

-- 4. Extend Master Products table
ALTER TABLE products
    ADD COLUMN IF NOT EXISTS product_code VARCHAR(30),
    ADD COLUMN IF NOT EXISTS canonical_name VARCHAR(150),
    ADD COLUMN IF NOT EXISTS scientific_name VARCHAR(150),
    ADD COLUMN IF NOT EXISTS botanical_family VARCHAR(100),
    ADD COLUMN IF NOT EXISTS default_unit_id UUID REFERENCES product_units(id),
    ADD COLUMN IF NOT EXISTS product_type VARCHAR(40) NOT NULL DEFAULT 'PRODUCE',
    ADD COLUMN IF NOT EXISTS is_perishable BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS storage_requirements TEXT,
    ADD COLUMN IF NOT EXISTS shelf_life_info VARCHAR(150),
    ADD COLUMN IF NOT EXISTS is_seeded BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS created_by UUID,
    ADD COLUMN IF NOT EXISTS updated_by UUID;

-- Backfill product_code & canonical_name for the 13 V8 products cleanly
UPDATE products SET product_code = 'VEG-TOM-001', canonical_name = 'Tomato', is_seeded = TRUE, default_unit_id = '10000000-0000-0000-0000-000000000003' WHERE id = 'f0000000-0000-0000-0000-000000000001' AND product_code IS NULL;
UPDATE products SET product_code = 'VEG-ONI-001', canonical_name = 'Onion', is_seeded = TRUE, default_unit_id = '10000000-0000-0000-0000-000000000003' WHERE id = 'f0000000-0000-0000-0000-000000000002' AND product_code IS NULL;
UPDATE products SET product_code = 'VEG-POT-001', canonical_name = 'Potato', is_seeded = TRUE, default_unit_id = '10000000-0000-0000-0000-000000000003' WHERE id = 'f0000000-0000-0000-0000-000000000003' AND product_code IS NULL;
UPDATE products SET product_code = 'VEG-CAB-001', canonical_name = 'Cabbage', is_seeded = TRUE, default_unit_id = '10000000-0000-0000-0000-000000000006' WHERE id = 'f0000000-0000-0000-0000-000000000004' AND product_code IS NULL;
UPDATE products SET product_code = 'VEG-CAU-001', canonical_name = 'Cauliflower', is_seeded = TRUE, default_unit_id = '10000000-0000-0000-0000-000000000006' WHERE id = 'f0000000-0000-0000-0000-000000000005' AND product_code IS NULL;
UPDATE products SET product_code = 'VEG-SPI-001', canonical_name = 'Spinach', is_seeded = TRUE, default_unit_id = '10000000-0000-0000-0000-000000000008' WHERE id = 'f0000000-0000-0000-0000-000000000006' AND product_code IS NULL;
UPDATE products SET product_code = 'VEG-CAP-001', canonical_name = 'Capsicum', is_seeded = TRUE, default_unit_id = '10000000-0000-0000-0000-000000000003' WHERE id = 'f0000000-0000-0000-0000-000000000007' AND product_code IS NULL;
UPDATE products SET product_code = 'VEG-OKR-001', canonical_name = 'Okra', is_seeded = TRUE, default_unit_id = '10000000-0000-0000-0000-000000000003' WHERE id = 'f0000000-0000-0000-0000-000000000008' AND product_code IS NULL;
UPDATE products SET product_code = 'FRT-APP-001', canonical_name = 'Apple', is_seeded = TRUE, default_unit_id = '10000000-0000-0000-0000-000000000003' WHERE id = 'f0000000-0000-0000-0000-000000000009' AND product_code IS NULL;
UPDATE products SET product_code = 'FRT-BAN-001', canonical_name = 'Banana', is_seeded = TRUE, default_unit_id = '10000000-0000-0000-0000-000000000007' WHERE id = 'f0000000-0000-0000-0000-000000000010' AND product_code IS NULL;
UPDATE products SET product_code = 'GRA-WHT-001', canonical_name = 'Wheat', is_seeded = TRUE, is_perishable = FALSE, default_unit_id = '10000000-0000-0000-0000-000000000003' WHERE id = 'f0000000-0000-0000-0000-000000000011' AND product_code IS NULL;
UPDATE products SET product_code = 'GRA-JOW-001', canonical_name = 'Jowar', is_seeded = TRUE, is_perishable = FALSE, default_unit_id = '10000000-0000-0000-0000-000000000003' WHERE id = 'f0000000-0000-0000-0000-000000000012' AND product_code IS NULL;
UPDATE products SET product_code = 'PUL-TUR-001', canonical_name = 'Tur', is_seeded = TRUE, is_perishable = FALSE, default_unit_id = '10000000-0000-0000-0000-000000000003' WHERE id = 'f0000000-0000-0000-0000-000000000013' AND product_code IS NULL;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_products_category_code') THEN
        ALTER TABLE products ADD CONSTRAINT uq_products_category_code UNIQUE (category_id, product_code);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_products_code ON products(product_code);
CREATE INDEX IF NOT EXISTS idx_products_canonical_name ON products(canonical_name);

-- 5. Multilingual Product Translations
CREATE TABLE IF NOT EXISTS product_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    language_code VARCHAR(10) NOT NULL CHECK (language_code IN ('en', 'mr', 'hi')),
    localized_name VARCHAR(150) NOT NULL,
    localized_description TEXT,
    search_aliases TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_product_translation_lang UNIQUE (product_id, language_code)
);
CREATE INDEX IF NOT EXISTS idx_product_translations_product ON product_translations(product_id);

-- 6. Product Varieties (Cultivars)
CREATE TABLE IF NOT EXISTS product_varieties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    variety_code VARCHAR(40) NOT NULL,
    variety_name VARCHAR(120) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_product_variety_code UNIQUE (product_id, variety_code)
);
CREATE INDEX IF NOT EXISTS idx_product_varieties_product ON product_varieties(product_id);

-- 7. Sellable Product Variants & Grades (with unique SKU)
CREATE TABLE IF NOT EXISTS product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    variety_id UUID REFERENCES product_varieties(id) ON DELETE SET NULL,
    sku VARCHAR(60) NOT NULL UNIQUE,
    variant_name VARCHAR(150) NOT NULL,
    grade VARCHAR(30),
    size_label VARCHAR(50),
    packaging_label VARCHAR(80),
    weight_value NUMERIC(14, 3),
    unit_id UUID REFERENCES product_units(id),
    attributes_json TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_product_variants_product ON product_variants(product_id);
CREATE INDEX IF NOT EXISTS idx_product_variants_sku ON product_variants(sku);

-- 8. Extend Farmer Listings to reference Variety, Variant, and Unit
ALTER TABLE farmer_listings
    ADD COLUMN IF NOT EXISTS variety_id UUID REFERENCES product_varieties(id),
    ADD COLUMN IF NOT EXISTS variant_id UUID REFERENCES product_variants(id),
    ADD COLUMN IF NOT EXISTS quantity_unit_id UUID REFERENCES product_units(id),
    ADD COLUMN IF NOT EXISTS minimum_order_quantity NUMERIC(14, 3) DEFAULT 1.000,
    ADD COLUMN IF NOT EXISTS expected_availability_date DATE,
    ADD COLUMN IF NOT EXISTS expiry_date DATE,
    ADD COLUMN IF NOT EXISTS farm_location VARCHAR(255),
    ADD COLUMN IF NOT EXISTS collection_point_ref VARCHAR(100),
    ADD COLUMN IF NOT EXISTS image_references TEXT;
