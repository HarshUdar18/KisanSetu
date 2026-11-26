-- V19: Hierarchical PostGIS Geofencing, Service Coverage Rules, Versioning & Audit
-- Preserves existing service_areas table and business records.

CREATE TABLE IF NOT EXISTS service_regions (
    region_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    region_code VARCHAR(50) NOT NULL UNIQUE,
    region_name VARCHAR(150) NOT NULL,
    country_code VARCHAR(10) NOT NULL DEFAULT 'IN',
    state_name VARCHAR(100) NOT NULL DEFAULT 'Maharashtra',
    city_name VARCHAR(100) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS service_zones (
    zone_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    region_id UUID NOT NULL REFERENCES service_regions(region_id) ON DELETE CASCADE,
    zone_code VARCHAR(50) NOT NULL UNIQUE,
    zone_name VARCHAR(150) NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    priority INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_service_zones_region ON service_zones(region_id);

CREATE TABLE IF NOT EXISTS service_localities (
    locality_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_id UUID NOT NULL REFERENCES service_zones(zone_id) ON DELETE CASCADE,
    locality_code VARCHAR(50) NOT NULL UNIQUE,
    locality_name VARCHAR(150) NOT NULL,
    normalized_name VARCHAR(150) NOT NULL,
    locality_type VARCHAR(50) NOT NULL DEFAULT 'LOCALITY',
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_service_localities_zone ON service_localities(zone_id);
CREATE INDEX IF NOT EXISTS idx_service_localities_status ON service_localities(status);

CREATE TABLE IF NOT EXISTS geofence_boundaries (
    geofence_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    locality_id UUID NOT NULL REFERENCES service_localities(locality_id) ON DELETE CASCADE,
    boundary_name VARCHAR(150) NOT NULL,
    boundary_version INTEGER NOT NULL DEFAULT 1,
    previous_geofence_id UUID REFERENCES geofence_boundaries(geofence_id),
    geometry GEOMETRY(MultiPolygon, 4326),
    boundary_source VARCHAR(150),
    source_url TEXT,
    source_license VARCHAR(150),
    source_version VARCHAR(100),
    imported_at TIMESTAMP WITH TIME ZONE,
    verification_status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    change_reason TEXT,
    effective_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_geofence_boundaries_locality ON geofence_boundaries(locality_id);
CREATE INDEX IF NOT EXISTS idx_geofence_boundaries_status ON geofence_boundaries(verification_status);
CREATE INDEX IF NOT EXISTS idx_geofence_boundaries_geom ON geofence_boundaries USING GIST(geometry);

CREATE TABLE IF NOT EXISTS service_coverage_rules (
    rule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    locality_id UUID NOT NULL UNIQUE REFERENCES service_localities(locality_id) ON DELETE CASCADE,
    customer_delivery_enabled BOOLEAN NOT NULL DEFAULT false,
    farmer_registration_enabled BOOLEAN NOT NULL DEFAULT true,
    farmer_listing_enabled BOOLEAN NOT NULL DEFAULT false,
    customer_order_enabled BOOLEAN NOT NULL DEFAULT false,
    collection_enabled BOOLEAN NOT NULL DEFAULT false,
    delivery_enabled BOOLEAN NOT NULL DEFAULT false,
    minimum_order_amount NUMERIC(10, 2) DEFAULT 0.00,
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    effective_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS geofence_audit_log (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID NOT NULL,
    action VARCHAR(80) NOT NULL,
    geofence_id UUID,
    locality_id UUID,
    previous_state TEXT,
    new_state TEXT,
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_geofence_audit_locality ON geofence_audit_log(locality_id);
CREATE INDEX IF NOT EXISTS idx_geofence_audit_geofence ON geofence_audit_log(geofence_id);

-- Order auditability fields for geofence decision at checkout
ALTER TABLE orders
    ADD COLUMN IF NOT EXISTS service_locality_id UUID,
    ADD COLUMN IF NOT EXISTS geofence_version INTEGER,
    ADD COLUMN IF NOT EXISTS serviceability_decision VARCHAR(60);

-- Seed Initial Hierarchy (Localities start as DRAFT with NO invented polygons!)
INSERT INTO service_regions (region_code, region_name, country_code, state_name, city_name, status)
VALUES
    ('PUNE', 'Pune Urban Region', 'IN', 'Maharashtra', 'Pune', 'ACTIVE'),
    ('PCMC', 'Pimpri-Chinchwad Urban Region', 'IN', 'Maharashtra', 'Pimpri-Chinchwad', 'ACTIVE')
ON CONFLICT (region_code) DO NOTHING;

INSERT INTO service_zones (region_id, zone_code, zone_name, description, status, priority)
SELECT region_id, 'ZONE_PUNE', 'Zone 1 — Pune', 'Initial Pune service zone (Shivajinagar)', 'ACTIVE', 1
FROM service_regions WHERE region_code = 'PUNE'
ON CONFLICT (zone_code) DO NOTHING;

INSERT INTO service_zones (region_id, zone_code, zone_name, description, status, priority)
SELECT region_id, 'ZONE_PCMC', 'Zone 2 — Pimpri-Chinchwad', 'Initial PCMC service zone (Akurdi, Nigdi, Pradhikaran, Ravet, Pimpri)', 'ACTIVE', 2
FROM service_regions WHERE region_code = 'PCMC'
ON CONFLICT (zone_code) DO NOTHING;

INSERT INTO service_localities (zone_id, locality_code, locality_name, normalized_name, locality_type, status)
SELECT zone_id, 'SHIVAJINAGAR', 'Shivajinagar', 'shivajinagar', 'LOCALITY', 'DRAFT'
FROM service_zones WHERE zone_code = 'ZONE_PUNE'
ON CONFLICT (locality_code) DO NOTHING;

INSERT INTO service_localities (zone_id, locality_code, locality_name, normalized_name, locality_type, status)
SELECT z.zone_id, v.code, v.name, LOWER(v.name), 'LOCALITY', 'DRAFT'
FROM service_zones z
CROSS JOIN (VALUES
    ('AKURDI', 'Akurdi'),
    ('NIGDI', 'Nigdi'),
    ('PRADHIKARAN', 'Pradhikaran'),
    ('RAVET', 'Ravet'),
    ('PIMPRI', 'Pimpri')
) AS v(code, name)
WHERE z.zone_code = 'ZONE_PCMC'
ON CONFLICT (locality_code) DO NOTHING;

INSERT INTO service_coverage_rules (
    locality_id, customer_delivery_enabled, farmer_registration_enabled,
    farmer_listing_enabled, customer_order_enabled, collection_enabled,
    delivery_enabled, minimum_order_amount, status
)
SELECT locality_id, false, true, false, false, false, false, 99.00, 'DRAFT'
FROM service_localities
WHERE locality_code IN ('SHIVAJINAGAR', 'AKURDI', 'NIGDI', 'PRADHIKARAN', 'RAVET', 'PIMPRI')
ON CONFLICT (locality_id) DO NOTHING;
