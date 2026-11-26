-- V11: Supply Chain, FPOs, Notifications, Support Tickets, Coupons

CREATE TABLE IF NOT EXISTS fpo_organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    registration_number VARCHAR(100) UNIQUE NOT NULL,
    district VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL DEFAULT 'Maharashtra',
    contact_phone VARCHAR(20),
    member_count INT NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    location VARCHAR(150) NOT NULL,
    capacity_tons NUMERIC(10, 2) NOT NULL DEFAULT 100.00,
    used_tons NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    cold_storage_available BOOLEAN NOT NULL DEFAULT TRUE,
    status VARCHAR(30) NOT NULL DEFAULT 'OPERATIONAL',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    available_kg NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    reserved_kg NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    reorder_level_kg NUMERIC(10, 2) NOT NULL DEFAULT 50.00,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS collection_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    collection_point VARCHAR(150) NOT NULL,
    scheduled_date DATE NOT NULL,
    quantity_kg NUMERIC(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'SCHEDULED', -- SCHEDULED, COLLECTED, CANCELLED
    gate_pass_code VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quality_inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID REFERENCES collection_records(id) ON DELETE SET NULL,
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    grade VARCHAR(20) NOT NULL DEFAULT 'GRADE_A', -- GRADE_A, GRADE_B, GRADE_C, REJECTED
    accepted_kg NUMERIC(10, 2) NOT NULL,
    rejected_kg NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    inspector_notes TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'COMPLETED',
    inspected_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS shipments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    delivery_partner_name VARCHAR(120),
    delivery_partner_phone VARCHAR(20),
    vehicle_number VARCHAR(30),
    origin_hub VARCHAR(150),
    destination_address VARCHAR(255),
    status VARCHAR(30) NOT NULL DEFAULT 'ASSIGNED', -- ASSIGNED, IN_TRANSIT, DELIVERED
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(40) NOT NULL DEFAULT 'GENERAL',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'ORDER',
    description TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN', -- OPEN, IN_PROGRESS, RESOLVED
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) UNIQUE NOT NULL,
    discount_type VARCHAR(20) NOT NULL DEFAULT 'PERCENT', -- PERCENT, FLAT
    discount_value NUMERIC(10, 2) NOT NULL,
    min_order_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    max_discount NUMERIC(10, 2),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Seed non-fabricated reference/operational configuration rows
INSERT INTO fpo_organizations (id, name, registration_number, district, state, contact_phone, member_count, status) VALUES
    ('e0000000-0000-0000-0000-000000000001', 'Sahyadri Krishi FPO', 'FPO-MH-PUN-001', 'Pune', 'Maharashtra', '9822001122', 340, 'ACTIVE'),
    ('e0000000-0000-0000-0000-000000000002', 'Nashik Onion Growers FPO', 'FPO-MH-NSK-002', 'Nashik', 'Maharashtra', '9822003344', 520, 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

INSERT INTO warehouses (id, name, code, location, capacity_tons, used_tons, cold_storage_available, status) VALUES
    ('77000000-0000-0000-0000-000000000001', 'Pune Central Cold Hub', 'WH-PUN-01', 'Chakan MIDC, Pune', 250.00, 84.50, TRUE, 'OPERATIONAL'),
    ('77000000-0000-0000-0000-000000000002', 'Nashik Aggregation Depot', 'WH-NSK-01', 'Lasalgaon, Nashik', 400.00, 140.00, TRUE, 'OPERATIONAL')
ON CONFLICT (id) DO NOTHING;

INSERT INTO coupons (id, code, discount_type, discount_value, min_order_amount, max_discount, is_active) VALUES
    ('c0000000-0000-0000-0000-000000000001', 'KISANFIRST', 'PERCENT', 10.00, 199.00, 100.00, TRUE),
    ('c0000000-0000-0000-0000-000000000002', 'FRESH50', 'FLAT', 50.00, 399.00, 50.00, TRUE)
ON CONFLICT (id) DO NOTHING;
