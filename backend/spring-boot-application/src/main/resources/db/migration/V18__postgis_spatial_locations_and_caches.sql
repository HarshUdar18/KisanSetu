-- V18: PostGIS Spatial Infrastructure, Farmer Farms, Geocoding & Route Caches
-- Note: PostGIS extension is enabled in PostGIS-capable PostgreSQL instances.
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. Extend existing addresses with PostGIS geography & coordinate constraints
ALTER TABLE addresses
    ADD COLUMN IF NOT EXISTS location geography(Point, 4326),
    ADD COLUMN IF NOT EXISTS locality VARCHAR(150),
    ADD COLUMN IF NOT EXISTS district VARCHAR(100),
    ADD COLUMN IF NOT EXISTS landmark VARCHAR(255),
    ADD COLUMN IF NOT EXISTS recipient_name VARCHAR(100),
    ADD COLUMN IF NOT EXISTS phone_number VARCHAR(20),
    ADD COLUMN IF NOT EXISTS address_type VARCHAR(30) DEFAULT 'HOME';

UPDATE addresses
SET location = ST_SetSRID(ST_MakePoint(longitude::double precision, latitude::double precision), 4326)::geography
WHERE latitude IS NOT NULL AND longitude IS NOT NULL AND location IS NULL;

CREATE INDEX IF NOT EXISTS idx_addresses_location ON addresses USING GIST(location);

-- 2. Extend existing hubs with PostGIS geography & GiST index
ALTER TABLE hubs
    ADD COLUMN IF NOT EXISTS location geography(Point, 4326);

UPDATE hubs
SET location = ST_SetSRID(ST_MakePoint(longitude::double precision, latitude::double precision), 4326)::geography
WHERE latitude IS NOT NULL AND longitude IS NOT NULL AND location IS NULL;

CREATE INDEX IF NOT EXISTS idx_hubs_location ON hubs USING GIST(location);

-- 3. Extend existing warehouses with coordinates & PostGIS geography (keep existing VARCHAR location column intact)
ALTER TABLE warehouses
    ADD COLUMN IF NOT EXISTS latitude NUMERIC(10, 7),
    ADD COLUMN IF NOT EXISTS longitude NUMERIC(10, 7),
    ADD COLUMN IF NOT EXISTS geo_location geography(Point, 4326);

CREATE INDEX IF NOT EXISTS idx_warehouses_geo_location ON warehouses USING GIST(geo_location);

-- 4. Farmer Farms table (multi-farm support with private coordinates)
CREATE TABLE IF NOT EXISTS farmer_farms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    farm_name VARCHAR(150) NOT NULL,
    address_line TEXT,
    village VARCHAR(100),
    taluka VARCHAR(100),
    district VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    formatted_address TEXT,
    latitude NUMERIC(10, 7) CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90)),
    longitude NUMERIC(10, 7) CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180)),
    location geography(Point, 4326),
    land_area NUMERIC(14, 4),
    land_unit VARCHAR(30) DEFAULT 'acre',
    soil_type VARCHAR(80),
    irrigation_type VARCHAR(80),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_farmer_farms_farmer_id ON farmer_farms(farmer_id);
CREATE INDEX IF NOT EXISTS idx_farmer_farms_location ON farmer_farms USING GIST(location);

-- 5. Geocoding Cache
CREATE TABLE IF NOT EXISTS geocoding_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider VARCHAR(50) NOT NULL,
    operation_type VARCHAR(30) NOT NULL,
    normalized_query TEXT NOT NULL,
    query_hash VARCHAR(64) NOT NULL,
    response_json TEXT NOT NULL,
    latitude NUMERIC(10, 7),
    longitude NUMERIC(10, 7),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_geocoding_cache_key UNIQUE (provider, operation_type, query_hash)
);

CREATE INDEX IF NOT EXISTS idx_geocoding_cache_expires ON geocoding_cache(expires_at);

-- 6. Route Cache
CREATE TABLE IF NOT EXISTS route_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider VARCHAR(50) NOT NULL,
    travel_mode VARCHAR(30) NOT NULL,
    origin_hash VARCHAR(64) NOT NULL,
    destination_hash VARCHAR(64) NOT NULL,
    route_response TEXT NOT NULL,
    distance_meters NUMERIC(14, 2) NOT NULL,
    duration_seconds NUMERIC(14, 2) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_route_cache_key UNIQUE (provider, travel_mode, origin_hash, destination_hash)
);

CREATE INDEX IF NOT EXISTS idx_route_cache_expires ON route_cache(expires_at);
