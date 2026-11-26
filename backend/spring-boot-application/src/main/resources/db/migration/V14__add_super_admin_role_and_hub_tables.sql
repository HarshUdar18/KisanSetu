-- V14: Add SUPER_ADMIN role and Hub management tables

-- Insert ROLE_SUPER_ADMIN role if not exists
INSERT INTO roles (id, description)
VALUES ('ROLE_SUPER_ADMIN', 'Full platform control including admin management and hub creation')
ON CONFLICT (id) DO NOTHING;

-- Create hubs table
CREATE TABLE IF NOT EXISTS hubs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    code VARCHAR(30) NOT NULL UNIQUE,
    hub_type VARCHAR(50) NOT NULL DEFAULT 'COLLECTION_HUB',
    address_line TEXT,
    village VARCHAR(100),
    district VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    contact_name VARCHAR(100),
    contact_phone VARCHAR(15),
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_hubs_code ON hubs(code);
CREATE INDEX IF NOT EXISTS idx_hubs_status ON hubs(status);
CREATE INDEX IF NOT EXISTS idx_hubs_district ON hubs(district);

-- Hub admin assignments
CREATE TABLE IF NOT EXISTS hub_admin_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hub_id UUID NOT NULL REFERENCES hubs(id) ON DELETE CASCADE,
    admin_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES users(id),
    assigned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(hub_id, admin_user_id)
);
CREATE INDEX IF NOT EXISTS idx_hub_admin_hub_id ON hub_admin_assignments(hub_id);
CREATE INDEX IF NOT EXISTS idx_hub_admin_user_id ON hub_admin_assignments(admin_user_id);

-- Admin provisioning audit trail
CREATE TABLE IF NOT EXISTS admin_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES users(id),
    target_id UUID,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(100),
    resource_id VARCHAR(255),
    details TEXT,
    status VARCHAR(30) DEFAULT 'SUCCESS',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_admin_audit_actor ON admin_audit_log(actor_id);
CREATE INDEX IF NOT EXISTS idx_admin_audit_created ON admin_audit_log(created_at);
