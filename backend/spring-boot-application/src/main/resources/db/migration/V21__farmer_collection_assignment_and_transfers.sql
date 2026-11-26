-- V21: Farmer Collection Point Assignments, Farm Type, and Collection-to-Warehouse Stock Transfers

ALTER TABLE farmer_farms
    ADD COLUMN IF NOT EXISTS farm_type VARCHAR(40) DEFAULT 'INDIVIDUAL_FARM';

CREATE TABLE IF NOT EXISTS farmer_collection_assignments (
    assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    hub_id UUID NOT NULL REFERENCES hubs(id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    assigned_by UUID,
    assigned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    reason TEXT
);
CREATE INDEX IF NOT EXISTS idx_farmer_cp_assign_farmer ON farmer_collection_assignments(farmer_id, status);
CREATE INDEX IF NOT EXISTS idx_farmer_cp_assign_hub ON farmer_collection_assignments(hub_id, status);

CREATE TABLE IF NOT EXISTS collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    collection_point VARCHAR(150) NOT NULL,
    scheduled_date DATE NOT NULL,
    quantity_kg NUMERIC(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
    gate_pass_code VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE collections
    ADD COLUMN IF NOT EXISTS hub_id UUID,
    ADD COLUMN IF NOT EXISTS listing_id UUID,
    ADD COLUMN IF NOT EXISTS received_kg NUMERIC(12, 3),
    ADD COLUMN IF NOT EXISTS accepted_kg NUMERIC(12, 3),
    ADD COLUMN IF NOT EXISTS rejected_kg NUMERIC(12, 3),
    ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

CREATE TABLE IF NOT EXISTS stock_transfers (
    transfer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID REFERENCES collections(id),
    inspection_id UUID REFERENCES quality_inspections(id),
    source_hub_id UUID REFERENCES hubs(id),
    destination_warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    product_id UUID NOT NULL REFERENCES products(id),
    farmer_id UUID NOT NULL REFERENCES users(id),
    dispatched_kg NUMERIC(12, 3) NOT NULL CHECK (dispatched_kg > 0),
    received_kg NUMERIC(12, 3),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING_DISPATCH',
    dispatched_by UUID,
    received_by UUID,
    dispatched_at TIMESTAMP WITH TIME ZONE,
    received_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_stock_transfers_farmer ON stock_transfers(farmer_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_stock_transfers_warehouse ON stock_transfers(destination_warehouse_id, status);
