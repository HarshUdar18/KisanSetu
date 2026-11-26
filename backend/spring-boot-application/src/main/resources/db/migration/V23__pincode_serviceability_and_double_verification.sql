-- V23: Verified PIN-Code Serviceability Master Data & Double-Verification Fallback Controls

CREATE TABLE IF NOT EXISTS pincode_serviceability (
    pincode_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pin_code VARCHAR(6) NOT NULL,
    state_name VARCHAR(100) NOT NULL DEFAULT 'Maharashtra',
    district_name VARCHAR(100) NOT NULL DEFAULT 'Pune',
    postal_locality_name VARCHAR(150) NOT NULL,
    locality_id UUID REFERENCES service_localities(locality_id) ON DELETE SET NULL,
    zone_id UUID REFERENCES service_zones(zone_id) ON DELETE SET NULL,
    serviceability_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    customer_delivery_enabled BOOLEAN NOT NULL DEFAULT false,
    farmer_collection_enabled BOOLEAN NOT NULL DEFAULT false,
    effective_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_until TIMESTAMP WITH TIME ZONE,
    data_source VARCHAR(150),
    source_url TEXT,
    verification_status VARCHAR(30) NOT NULL DEFAULT 'UNVERIFIED',
    last_verified_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pincode_serviceability_pin ON pincode_serviceability(pin_code);
CREATE INDEX IF NOT EXISTS idx_pincode_serviceability_locality ON pincode_serviceability(locality_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_pincode_postal_locality
    ON pincode_serviceability (pin_code, postal_locality_name, COALESCE(locality_id, '00000000-0000-0000-0000-000000000000'::uuid));

ALTER TABLE service_coverage_rules
    ADD COLUMN IF NOT EXISTS pincode_fallback_customer_enabled BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS pincode_fallback_farmer_enabled BOOLEAN NOT NULL DEFAULT false;

-- Activate the 6 pilot localities with controlled PIN-code fallback enabled
-- (No fabricated polygons inserted into geofence_boundaries)
UPDATE service_localities
SET status = 'ACTIVE', updated_at = CURRENT_TIMESTAMP
WHERE locality_code IN ('SHIVAJINAGAR', 'AKURDI', 'NIGDI', 'PRADHIKARAN', 'RAVET', 'PIMPRI');

UPDATE service_coverage_rules scr
SET customer_delivery_enabled = true,
    farmer_registration_enabled = true,
    farmer_listing_enabled = true,
    customer_order_enabled = true,
    collection_enabled = true,
    delivery_enabled = true,
    pincode_fallback_customer_enabled = true,
    pincode_fallback_farmer_enabled = true,
    status = 'ACTIVE',
    updated_at = CURRENT_TIMESTAMP
FROM service_localities l
WHERE scr.locality_id = l.locality_id
  AND l.locality_code IN ('SHIVAJINAGAR', 'AKURDI', 'NIGDI', 'PRADHIKARAN', 'RAVET', 'PIMPRI');

-- Seed verified India Post PIN-code records for the 6 pilot localities
INSERT INTO pincode_serviceability (
    pin_code, state_name, district_name, postal_locality_name,
    locality_id, zone_id, serviceability_status,
    customer_delivery_enabled, farmer_collection_enabled,
    data_source, source_url, verification_status, last_verified_at, approved_at
)
SELECT
    v.pin_code, 'Maharashtra', 'Pune', v.postal_name,
    l.locality_id, l.zone_id, 'APPROVED',
    true, true,
    'India Post Postal PIN Code API', v.source_url, 'VERIFIED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
    ('411005', 'Shivajinagar', 'SHIVAJINAGAR', 'https://api.postalpincode.in/pincode/411005'),
    ('411035', 'Akurdi', 'AKURDI', 'https://api.postalpincode.in/pincode/411035'),
    ('411044', 'Yamunanagar (Nigdi)', 'NIGDI', 'https://api.postalpincode.in/pincode/411044'),
    ('411044', 'P.C.N.T. (Pradhikaran)', 'PRADHIKARAN', 'https://api.postalpincode.in/pincode/411044'),
    ('412101', 'Dehu Road Cantt / Kiwale (Ravet)', 'RAVET', 'https://api.postalpincode.in/pincode/412101'),
    ('411017', 'Pimpri Colony', 'PIMPRI', 'https://api.postalpincode.in/pincode/411017'),
    ('411018', 'Pimpri P F', 'PIMPRI', 'https://api.postalpincode.in/pincode/411018')
) AS v(pin_code, postal_name, locality_code, source_url)
JOIN service_localities l ON l.locality_code = v.locality_code
ON CONFLICT DO NOTHING;
