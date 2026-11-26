-- V10: Create KYC Submissions, Demand Requests, and Farmer Settlements Tables

-- 1. KYC Submissions
CREATE TABLE IF NOT EXISTS kyc_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL DEFAULT 'AADHAAR',
    document_number VARCHAR(100) NOT NULL,
    document_url VARCHAR(500),
    selfie_url VARCHAR(500),
    bank_account_number VARCHAR(50),
    ifsc_code VARCHAR(20),
    land_record_number VARCHAR(100),
    status VARCHAR(30) NOT NULL DEFAULT 'UNDER_REVIEW', -- NOT_SUBMITTED, UNDER_REVIEW, VERIFIED, REJECTED
    remarks TEXT,
    reviewed_by UUID REFERENCES users(id),
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_kyc_submissions_farmer_id ON kyc_submissions(farmer_id);
CREATE INDEX IF NOT EXISTS idx_kyc_submissions_status ON kyc_submissions(status);

-- 2. Demand Requests
CREATE TABLE IF NOT EXISTS demand_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity_kg NUMERIC(10, 2) NOT NULL,
    target_price_per_kg NUMERIC(10, 2) NOT NULL,
    required_by_date DATE NOT NULL,
    notes TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN', -- OPEN, ACCEPTED, FULFILLED, CANCELLED
    accepted_by_farmer_id UUID REFERENCES users(id),
    offered_price_per_kg NUMERIC(10, 2),
    confirmed_quantity_kg NUMERIC(10, 2),
    accepted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_demand_requests_product_id ON demand_requests(product_id);
CREATE INDEX IF NOT EXISTS idx_demand_requests_status ON demand_requests(status);
CREATE INDEX IF NOT EXISTS idx_demand_requests_farmer_id ON demand_requests(accepted_by_farmer_id);

-- 3. Farmer Settlements
CREATE TABLE IF NOT EXISTS settlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    gross_amount NUMERIC(12, 2) NOT NULL,
    platform_commission NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    net_amount NUMERIC(12, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING', -- PENDING, AUTHORIZED, PAID, FAILED
    bank_account_masked VARCHAR(30),
    transaction_reference VARCHAR(100),
    authorized_by UUID REFERENCES users(id),
    remarks TEXT,
    authorized_at TIMESTAMP WITH TIME ZONE,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_settlements_farmer_id ON settlements(farmer_id);
CREATE INDEX IF NOT EXISTS idx_settlements_status ON settlements(status);

-- Seed sample open demand requests & a settlement for Tukaram Patil (a0000000-0000-0000-0000-000000000003)
INSERT INTO demand_requests (id, requester_id, product_id, quantity_kg, target_price_per_kg, required_by_date, notes, status) VALUES
    ('d0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 200.00, 29.00, CURRENT_DATE + INTERVAL '3 days', 'Pune Retail Cluster morning demand - Grade A Desi Tomatoes', 'OPEN'),
    ('d0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000002', 500.00, 32.00, CURRENT_DATE + INTERVAL '4 days', 'Weekly subscription buffer - Nashik Red Onions', 'OPEN')
ON CONFLICT (id) DO NOTHING;

INSERT INTO settlements (id, farmer_id, gross_amount, platform_commission, net_amount, status, bank_account_masked, remarks) VALUES
    ('55000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003', 12500.00, 1250.00, 11250.00, 'PENDING', 'SBIN-XXXX-4521', 'Pending finance DBT authorization for weekly harvest batch')
ON CONFLICT (id) DO NOTHING;
