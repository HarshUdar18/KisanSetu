-- V4: Create Service Areas Table

CREATE TABLE IF NOT EXISTS service_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    pincode VARCHAR(10),
    latitude NUMERIC(10, 7),
    longitude NUMERIC(10, 7),
    radius_km NUMERIC(5, 2) DEFAULT 5.0,
    city VARCHAR(50) DEFAULT 'Pune',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_service_areas_name ON service_areas(name);
CREATE INDEX IF NOT EXISTS idx_service_areas_status ON service_areas(status);
CREATE INDEX IF NOT EXISTS idx_service_areas_pincode ON service_areas(pincode);
