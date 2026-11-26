package com.kisansetu.modules.servicearea.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.location.spatial.SpatialLocationService;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.*;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.*;

@Service
public class GeofenceService {

    private static final String OUTSIDE_MESSAGE = "Sorry, Kisan Setu is not currently available at this location.";

    private final JdbcTemplate jdbcTemplate;
    private final SpatialLocationService spatialLocationService;
    private final ObjectMapper objectMapper;

    public GeofenceService(
            JdbcTemplate jdbcTemplate,
            SpatialLocationService spatialLocationService,
            ObjectMapper objectMapper) {
        this.jdbcTemplate = jdbcTemplate;
        this.spatialLocationService = spatialLocationService;
        this.objectMapper = objectMapper;
    }

    @Transactional(readOnly = true)
    public List<ServiceAreaSummaryDto> listServiceAreas() {
        try {
            String sql = """
                    SELECT r.region_id, r.region_code, r.region_name, r.city_name,
                           z.zone_id, z.zone_code, z.zone_name,
                           l.locality_id, l.locality_code, l.locality_name, l.status AS locality_status,
                           g.boundary_version, g.boundary_source,
                           scr.customer_delivery_enabled, scr.collection_enabled, scr.customer_order_enabled,
                           scr.farmer_registration_enabled, scr.farmer_listing_enabled, scr.delivery_enabled,
                           scr.pincode_fallback_customer_enabled, scr.pincode_fallback_farmer_enabled,
                           scr.minimum_order_amount, scr.status AS rule_status
                    FROM service_localities l
                    JOIN service_zones z ON z.zone_id = l.zone_id
                    JOIN service_regions r ON r.region_id = z.region_id
                    LEFT JOIN geofence_boundaries g
                        ON g.locality_id = l.locality_id
                       AND g.verification_status = 'ACTIVE'
                       AND g.effective_from <= NOW()
                       AND (g.effective_until IS NULL OR g.effective_until > NOW())
                    LEFT JOIN service_coverage_rules scr ON scr.locality_id = l.locality_id
                    ORDER BY z.priority ASC, l.locality_name ASC
                    """;
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Integer version = rs.getObject("boundary_version") != null ? rs.getInt("boundary_version") : null;
                ServiceCapabilitiesDto caps = new ServiceCapabilitiesDto(
                        rs.getBoolean("customer_delivery_enabled"),
                        rs.getBoolean("collection_enabled"),
                        rs.getBoolean("customer_order_enabled"),
                        rs.getBoolean("farmer_registration_enabled"),
                        rs.getBoolean("farmer_listing_enabled"),
                        rs.getBoolean("collection_enabled"),
                        rs.getBoolean("pincode_fallback_customer_enabled"),
                        rs.getBoolean("pincode_fallback_farmer_enabled"),
                        rs.getBigDecimal("minimum_order_amount") != null ? rs.getBigDecimal("minimum_order_amount") : BigDecimal.ZERO,
                        rs.getString("rule_status") != null ? rs.getString("rule_status") : "DRAFT"
                );
                return new ServiceAreaSummaryDto(
                        UUID.fromString(rs.getString("region_id")),
                        rs.getString("region_code"),
                        rs.getString("region_name"),
                        rs.getString("city_name"),
                        UUID.fromString(rs.getString("zone_id")),
                        rs.getString("zone_code"),
                        rs.getString("zone_name"),
                        UUID.fromString(rs.getString("locality_id")),
                        rs.getString("locality_code"),
                        rs.getString("locality_name"),
                        rs.getString("locality_status"),
                        version != null,
                        version,
                        rs.getString("boundary_source"),
                        caps
                );
            });
        } catch (DataAccessException ex) {
            return List.of();
        }
    }

    @Transactional(readOnly = true)
    public boolean hasAnyActiveGeofence() {
        try {
            Integer count = jdbcTemplate.queryForObject(
                    "SELECT count(*) FROM geofence_boundaries WHERE verification_status = 'ACTIVE' AND geometry IS NOT NULL",
                    Integer.class
            );
            return count != null && count > 0;
        } catch (DataAccessException ex) {
            return false;
        }
    }

    @Transactional(readOnly = true)
    public GeofenceValidationResult validatePoint(double latitude, double longitude, String requestedOperation) {
        return validateServiceability(new GeofenceValidateRequest(latitude, longitude, requestedOperation));
    }

    @Transactional(readOnly = true)
    public GeofenceValidationResult validateServiceability(GeofenceValidateRequest request) {
        double latitude = request.latitude();
        double longitude = request.longitude();
        String requestedOperation = request.requestedOperation();
        String normalizedPin = normalizePin(request.pinCode());
        spatialLocationService.validateCoordinates(latitude, longitude);

        String sql = """
                SELECT r.region_id, r.region_name,
                       z.zone_id, z.zone_name,
                       l.locality_id, l.locality_code, l.locality_name,
                       g.boundary_version,
                       scr.customer_delivery_enabled, scr.collection_enabled, scr.customer_order_enabled,
                       scr.farmer_registration_enabled, scr.farmer_listing_enabled, scr.delivery_enabled,
                       scr.pincode_fallback_customer_enabled, scr.pincode_fallback_farmer_enabled,
                       scr.minimum_order_amount, scr.status AS rule_status
                FROM geofence_boundaries g
                JOIN service_localities l ON l.locality_id = g.locality_id
                JOIN service_zones z ON z.zone_id = l.zone_id
                JOIN service_regions r ON r.region_id = z.region_id
                LEFT JOIN service_coverage_rules scr ON scr.locality_id = l.locality_id
                WHERE g.verification_status = 'ACTIVE'
                  AND l.status = 'ACTIVE'
                  AND z.status = 'ACTIVE'
                  AND r.status = 'ACTIVE'
                  AND g.effective_from <= NOW()
                  AND (g.effective_until IS NULL OR g.effective_until > NOW())
                  AND g.geometry IS NOT NULL
                  AND ST_Covers(g.geometry, ST_SetSRID(ST_MakePoint(?, ?), 4326))
                """;

        List<GeofenceValidationResult> matches = jdbcTemplate.query(sql, (rs, rowNum) -> {
            ServiceCapabilitiesDto caps = new ServiceCapabilitiesDto(
                    rs.getBoolean("customer_delivery_enabled"),
                    rs.getBoolean("collection_enabled"),
                    rs.getBoolean("customer_order_enabled"),
                    rs.getBoolean("farmer_registration_enabled"),
                    rs.getBoolean("farmer_listing_enabled"),
                    rs.getBoolean("collection_enabled"),
                    rs.getBoolean("pincode_fallback_customer_enabled"),
                    rs.getBoolean("pincode_fallback_farmer_enabled"),
                    rs.getBigDecimal("minimum_order_amount") != null ? rs.getBigDecimal("minimum_order_amount") : BigDecimal.ZERO,
                    rs.getString("rule_status") != null ? rs.getString("rule_status") : "DRAFT"
            );
            return new GeofenceValidationResult(
                    true,
                    false,
                    "MATCHED",
                    "GEOFENCE_ONLY",
                    "Matched active locality",
                    UUID.fromString(rs.getString("region_id")),
                    rs.getString("region_name"),
                    UUID.fromString(rs.getString("zone_id")),
                    rs.getString("zone_name"),
                    UUID.fromString(rs.getString("locality_id")),
                    rs.getString("locality_code"),
                    rs.getString("locality_name"),
                    rs.getInt("boundary_version"),
                    normalizedPin,
                    false,
                    true,
                    requestedOperation,
                    caps
            );
        }, longitude, latitude);

        if (matches.size() > 1) {
            return new GeofenceValidationResult(
                    true, false, "AMBIGUOUS_BOUNDARY", "NONE",
                    "Selected coordinates overlap multiple active service boundaries; administrative review required.",
                    null, null, null, null, null, null, null, null,
                    normalizedPin, false, true, requestedOperation, null
            );
        }

        if (matches.size() == 1) {
            GeofenceValidationResult matched = matches.get(0);
            if (!isOperationAllowed(matched.capabilities(), requestedOperation)) {
                return new GeofenceValidationResult(
                        true, false, "CAPABILITY_DISABLED", "GEOFENCE_ONLY",
                        "This location is inside " + matched.localityName() + ", but " +
                                (requestedOperation != null ? requestedOperation : "requested service") + " is currently disabled there.",
                        matched.regionId(), matched.regionName(),
                        matched.zoneId(), matched.zoneName(),
                        matched.localityId(), matched.localityCode(), matched.localityName(),
                        matched.boundaryVersion(), normalizedPin, false, true, requestedOperation, matched.capabilities()
                );
            }
            if (normalizedPin != null) {
                boolean pinMatchesLocality = hasApprovedPincodeForLocality(normalizedPin, matched.localityId(), requestedOperation);
                if (!pinMatchesLocality) {
                    return new GeofenceValidationResult(
                            true, false, "PINCODE_MISMATCH", "GEOFENCE_ONLY",
                            "We couldn't verify this address. Please check your PIN code and location.",
                            matched.regionId(), matched.regionName(),
                            matched.zoneId(), matched.zoneName(),
                            matched.localityId(), matched.localityCode(), matched.localityName(),
                            matched.boundaryVersion(), normalizedPin, false, true, requestedOperation, matched.capabilities()
                    );
                }
                return new GeofenceValidationResult(
                        true, true, "SERVICEABLE", "GEOFENCE_AND_PINCODE",
                        "Great! Kisan Setu delivers to your location.",
                        matched.regionId(), matched.regionName(),
                        matched.zoneId(), matched.zoneName(),
                        matched.localityId(), matched.localityCode(), matched.localityName(),
                        matched.boundaryVersion(), normalizedPin, true, true, requestedOperation, matched.capabilities()
                );
            }
            return new GeofenceValidationResult(
                    true, true, "SERVICEABLE", "GEOFENCE_ONLY",
                    "Great! Kisan Setu delivers to your location.",
                    matched.regionId(), matched.regionName(),
                    matched.zoneId(), matched.zoneName(),
                    matched.localityId(), matched.localityCode(), matched.localityName(),
                    matched.boundaryVersion(), null, false, true, requestedOperation, matched.capabilities()
            );
        }

        // No active polygon matched -> check PIN-code fallback when approved & enabled
        boolean anyActivePolygon = hasAnyActiveGeofence();
        if (normalizedPin != null) {
            List<GeofenceValidationResult> pinMatches = findApprovedPincodeMatches(normalizedPin, requestedOperation);
            if (!pinMatches.isEmpty()) {
                for (GeofenceValidationResult candidate : pinMatches) {
                    boolean opAllowed = isOperationAllowed(candidate.capabilities(), requestedOperation);
                    boolean fallbackAllowed = isFallbackAllowed(candidate.capabilities(), requestedOperation);
                    if (opAllowed && fallbackAllowed) {
                        return new GeofenceValidationResult(
                                false, true, "SERVICEABLE", "PINCODE_FALLBACK",
                                "Your location is verified using your PIN code.",
                                candidate.regionId(), candidate.regionName(),
                                candidate.zoneId(), candidate.zoneName(),
                                candidate.localityId(), candidate.localityCode(), candidate.localityName(),
                                null, normalizedPin, true, false, requestedOperation, candidate.capabilities()
                        );
                    }
                }
                GeofenceValidationResult first = pinMatches.get(0);
                return new GeofenceValidationResult(
                        false, false, "CAPABILITY_DISABLED", "PINCODE_FALLBACK",
                        "Service is currently disabled for this PIN code.",
                        first.regionId(), first.regionName(),
                        first.zoneId(), first.zoneName(),
                        first.localityId(), first.localityCode(), first.localityName(),
                        null, normalizedPin, true, false, requestedOperation, first.capabilities()
                );
            }
        }

        if (!anyActivePolygon) {
            return new GeofenceValidationResult(
                    false, false, "NOT_VERIFIABLE", "NONE",
                    "We couldn't verify this address. Please check your PIN code and location.",
                    null, null, null, null, null, null, null, null,
                    normalizedPin, false, false, requestedOperation, null
            );
        }

        return new GeofenceValidationResult(
                false, false, "OUTSIDE_SERVICE_AREA", "NONE",
                OUTSIDE_MESSAGE,
                null, null, null, null, null, null, null, null,
                normalizedPin, false, false, requestedOperation, null
        );
    }

    private boolean isOperationAllowed(ServiceCapabilitiesDto caps, String requestedOperation) {
        if (caps == null) return false;
        if (!"ACTIVE".equalsIgnoreCase(caps.ruleStatus())) {
            return false;
        }
        if (requestedOperation == null || requestedOperation.isBlank()) {
            return caps.customerDeliveryEnabled() || caps.customerCollectionEnabled() || caps.farmerListingEnabled();
        }
        return switch (requestedOperation.trim().toUpperCase(Locale.ROOT)) {
            case "CUSTOMER_DELIVERY" -> caps.customerDeliveryEnabled();
            case "CUSTOMER_COLLECTION" -> caps.customerCollectionEnabled();
            case "CUSTOMER_ORDER" -> caps.customerOrderEnabled();
            case "FARMER_REGISTRATION" -> caps.farmerRegistrationEnabled();
            case "FARMER_LISTING" -> caps.farmerListingEnabled();
            case "FARM_COLLECTION" -> caps.farmCollectionEnabled();
            default -> throw new ApiException("INVALID_OPERATION", "Unsupported serviceability operation: " + requestedOperation, HttpStatus.BAD_REQUEST);
        };
    }

    @Transactional(readOnly = true)
    public ServiceAreaSummaryDto getLocalityDetails(UUID localityId) {
        return listServiceAreas().stream()
                .filter(s -> s.localityId().equals(localityId))
                .findFirst()
                .orElseThrow(() -> new ApiException("LOCALITY_NOT_FOUND", "Service locality not found", HttpStatus.NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getZoneDetails(UUID zoneId) {
        List<ServiceAreaSummaryDto> localities = listServiceAreas().stream()
                .filter(s -> s.zoneId().equals(zoneId))
                .toList();
        if (localities.isEmpty()) {
            throw new ApiException("ZONE_NOT_FOUND", "Service zone not found", HttpStatus.NOT_FOUND);
        }
        ServiceAreaSummaryDto first = localities.get(0);
        return Map.of(
                "zoneId", first.zoneId(),
                "zoneCode", first.zoneCode(),
                "zoneName", first.zoneName(),
                "regionId", first.regionId(),
                "regionName", first.regionName(),
                "localities", localities
        );
    }

    @Transactional(readOnly = true)
    @Cacheable(value = "geofenceBoundaries", key = "#localityId")
    public BoundaryResponseDto getPublicBoundaryGeoJson(UUID localityId) {
        String sql = """
                SELECT g.geofence_id, l.locality_id, l.locality_code, l.locality_name,
                       g.boundary_name, g.boundary_version, g.verification_status,
                       g.boundary_source, g.source_url, g.source_license, g.source_version,
                       ST_AsGeoJSON(g.geometry) AS geojson, g.verified_at
                FROM geofence_boundaries g
                JOIN service_localities l ON l.locality_id = g.locality_id
                WHERE g.locality_id = ?
                  AND g.verification_status = 'ACTIVE'
                  AND g.geometry IS NOT NULL
                LIMIT 1
                """;
        List<BoundaryResponseDto> rows = jdbcTemplate.query(sql, (rs, rowNum) -> {
            Timestamp ts = rs.getTimestamp("verified_at");
            return new BoundaryResponseDto(
                    UUID.fromString(rs.getString("geofence_id")),
                    UUID.fromString(rs.getString("locality_id")),
                    rs.getString("locality_code"),
                    rs.getString("locality_name"),
                    rs.getString("boundary_name"),
                    rs.getInt("boundary_version"),
                    rs.getString("verification_status"),
                    rs.getString("boundary_source"),
                    rs.getString("source_url"),
                    rs.getString("source_license"),
                    rs.getString("source_version"),
                    rs.getString("geojson"),
                    ts != null ? ts.toInstant() : null
            );
        }, localityId);

        if (rows.isEmpty()) {
            throw new ApiException("BOUNDARY_NOT_ACTIVE", "No active verified boundary available for this locality", HttpStatus.NOT_FOUND);
        }
        return rows.get(0);
    }

    @Transactional
    @CacheEvict(value = {"geofenceBoundaries", "serviceAreas"}, allEntries = true)
    public BoundaryResponseDto importGeoJsonBoundary(UUID actorId, UUID localityId, ImportBoundaryRequest req) {
        if (req.geoJson() == null || req.geoJson().isBlank()) {
            throw new ApiException("INVALID_GEOJSON", "GeoJSON geometry payload is required", HttpStatus.BAD_REQUEST);
        }
        if (req.boundarySource() == null || req.boundarySource().isBlank() ||
                req.sourceLicense() == null || req.sourceLicense().isBlank()) {
            throw new ApiException("MISSING_PROVENANCE", "boundarySource and sourceLicense are required for boundary import", HttpStatus.BAD_REQUEST);
        }

        // Verify locality exists
        Integer localityCount = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM service_localities WHERE locality_id = ?", Integer.class, localityId);
        if (localityCount == null || localityCount == 0) {
            throw new ApiException("LOCALITY_NOT_FOUND", "Locality not found", HttpStatus.NOT_FOUND);
        }

        String geometryJson = extractGeometryJson(req.geoJson());

        // Validate geometry via PostGIS before storing
        Map<String, Object> validation;
        try {
            validation = jdbcTemplate.queryForMap("""
                    WITH g AS (
                        SELECT ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON(?), 4326)) AS geom
                    )
                    SELECT ST_IsValid(geom) AS is_valid,
                           ST_IsEmpty(geom) AS is_empty,
                           ST_IsValidReason(geom) AS valid_reason,
                           ST_GeometryType(geom) AS geom_type
                    FROM g
                    """, geometryJson);
        } catch (DataAccessException ex) {
            throw new ApiException("INVALID_GEOJSON", "Unable to parse GeoJSON geometry: " + ex.getMostSpecificCause().getMessage(), HttpStatus.BAD_REQUEST);
        }

        boolean isValid = Boolean.TRUE.equals(validation.get("is_valid"));
        boolean isEmpty = Boolean.TRUE.equals(validation.get("is_empty"));
        String geomType = String.valueOf(validation.get("geom_type"));
        if (!isValid || isEmpty || !"ST_MultiPolygon".equalsIgnoreCase(geomType)) {
            throw new ApiException(
                    "INVALID_GEOMETRY",
                    "Geometry rejected (" + geomType + "): " + validation.get("valid_reason"),
                    HttpStatus.BAD_REQUEST
            );
        }

        Integer nextVersion = jdbcTemplate.queryForObject(
                "SELECT COALESCE(MAX(boundary_version), 0) + 1 FROM geofence_boundaries WHERE locality_id = ?",
                Integer.class, localityId);
        int version = nextVersion != null ? nextVersion : 1;

        UUID geofenceId = UUID.randomUUID();
        String boundaryName = (req.boundaryName() != null && !req.boundaryName().isBlank())
                ? req.boundaryName().trim() : "Imported Boundary v" + version;

        jdbcTemplate.update("""
                INSERT INTO geofence_boundaries (
                    geofence_id, locality_id, boundary_name, boundary_version,
                    geometry, boundary_source, source_url, source_license, source_version,
                    imported_at, verification_status, change_reason, effective_from
                ) VALUES (
                    ?, ?, ?, ?,
                    ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON(?), 4326)),
                    ?, ?, ?, ?, NOW(), 'DRAFT', ?, NOW()
                )
                """,
                geofenceId, localityId, boundaryName, version,
                geometryJson,
                req.boundarySource().trim(),
                req.sourceUrl(),
                req.sourceLicense().trim(),
                req.sourceVersion(),
                req.changeReason() != null ? req.changeReason() : "Initial GeoJSON import"
        );

        writeAudit(actorId, "BOUNDARY_IMPORTED", geofenceId, localityId, null,
                "DRAFT v" + version + " (" + req.boundarySource() + ")", req.changeReason());

        return fetchBoundaryById(geofenceId);
    }

    @Transactional
    @CacheEvict(value = {"geofenceBoundaries", "serviceAreas"}, allEntries = true)
    public BoundaryResponseDto transitionBoundaryStatus(UUID actorId, UUID geofenceId, String targetStatus, String reason) {
        Map<String, Object> current = jdbcTemplate.queryForMap(
                "SELECT locality_id, boundary_version, verification_status FROM geofence_boundaries WHERE geofence_id = ?",
                geofenceId
        );
        UUID localityId = UUID.fromString(current.get("locality_id").toString());
        String prevStatus = String.valueOf(current.get("verification_status"));
        String normalizedTarget = targetStatus.trim().toUpperCase(Locale.ROOT);

        validateTransition(prevStatus, normalizedTarget);

        if ("ACTIVE".equals(normalizedTarget)) {
            jdbcTemplate.update("""
                    UPDATE geofence_boundaries
                    SET verification_status = 'SUPERSEDED', effective_until = NOW(), updated_at = NOW()
                    WHERE locality_id = ? AND verification_status = 'ACTIVE' AND geofence_id <> ?
                    """, localityId, geofenceId);
            jdbcTemplate.update(
                    "UPDATE service_localities SET status = 'ACTIVE', updated_at = NOW() WHERE locality_id = ?",
                    localityId
            );
        } else if ("INACTIVE".equals(normalizedTarget)) {
            jdbcTemplate.update(
                    "UPDATE service_localities SET status = 'INACTIVE', updated_at = NOW() WHERE locality_id = ?",
                    localityId
            );
        }

        if ("VERIFIED".equals(normalizedTarget) || "ACTIVE".equals(normalizedTarget)) {
            jdbcTemplate.update("""
                    UPDATE geofence_boundaries
                    SET verification_status = ?, verified_by = ?, verified_at = NOW(), updated_at = NOW()
                    WHERE geofence_id = ?
                    """, normalizedTarget, actorId, geofenceId);
        } else {
            jdbcTemplate.update("""
                    UPDATE geofence_boundaries
                    SET verification_status = ?, updated_at = NOW()
                    WHERE geofence_id = ?
                    """, normalizedTarget, geofenceId);
        }

        writeAudit(actorId, "BOUNDARY_STATUS_" + normalizedTarget, geofenceId, localityId,
                prevStatus, normalizedTarget, reason);

        return fetchBoundaryById(geofenceId);
    }

    @Transactional
    @CacheEvict(value = {"geofenceBoundaries", "serviceAreas"}, allEntries = true)
    public ServiceAreaSummaryDto updateCoverageRules(UUID actorId, UUID localityId, UpdateCoverageRulesRequest req) {
        ServiceAreaSummaryDto before = getLocalityDetails(localityId);
        ServiceCapabilitiesDto prev = before.capabilities();

        boolean custDel = req.customerDeliveryEnabled() != null ? req.customerDeliveryEnabled() : prev.customerDeliveryEnabled();
        boolean farmReg = req.farmerRegistrationEnabled() != null ? req.farmerRegistrationEnabled() : prev.farmerRegistrationEnabled();
        boolean farmList = req.farmerListingEnabled() != null ? req.farmerListingEnabled() : prev.farmerListingEnabled();
        boolean custOrd = req.customerOrderEnabled() != null ? req.customerOrderEnabled() : prev.customerOrderEnabled();
        boolean coll = req.collectionEnabled() != null ? req.collectionEnabled() : prev.customerCollectionEnabled();
        boolean deliv = req.deliveryEnabled() != null ? req.deliveryEnabled() : custDel;
        boolean fallbackCust = req.pincodeFallbackCustomerEnabled() != null
                ? req.pincodeFallbackCustomerEnabled()
                : prev.pincodeFallbackCustomerEnabled();
        boolean fallbackFarm = req.pincodeFallbackFarmerEnabled() != null
                ? req.pincodeFallbackFarmerEnabled()
                : prev.pincodeFallbackFarmerEnabled();
        BigDecimal minAmt = req.minimumOrderAmount() != null ? req.minimumOrderAmount() : prev.minimumOrderAmount();
        String status = req.status() != null && !req.status().isBlank() ? req.status().trim().toUpperCase(Locale.ROOT) : prev.ruleStatus();

        jdbcTemplate.update("""
                UPDATE service_coverage_rules
                SET customer_delivery_enabled = ?,
                    farmer_registration_enabled = ?,
                    farmer_listing_enabled = ?,
                    customer_order_enabled = ?,
                    collection_enabled = ?,
                    delivery_enabled = ?,
                    pincode_fallback_customer_enabled = ?,
                    pincode_fallback_farmer_enabled = ?,
                    minimum_order_amount = ?,
                    status = ?,
                    updated_at = NOW()
                WHERE locality_id = ?
                """, custDel, farmReg, farmList, custOrd, coll, deliv, fallbackCust, fallbackFarm, minAmt, status, localityId);

        writeAudit(actorId, "COVERAGE_RULES_UPDATED", null, localityId,
                prev.ruleStatus(), status + " (delivery=" + custDel + ", listing=" + farmList + ")", req.reason());

        return getLocalityDetails(localityId);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> listAuditLogs(UUID localityId) {
        if (localityId != null) {
            return jdbcTemplate.queryForList(
                    "SELECT * FROM geofence_audit_log WHERE locality_id = ? ORDER BY created_at DESC LIMIT 100",
                    localityId
            );
        }
        return jdbcTemplate.queryForList("SELECT * FROM geofence_audit_log ORDER BY created_at DESC LIMIT 100");
    }

    private void validateTransition(String from, String to) {
        boolean allowed = switch (from) {
            case "DRAFT" -> "PENDING_REVIEW".equals(to) || "INACTIVE".equals(to);
            case "PENDING_REVIEW" -> "VERIFIED".equals(to) || "DRAFT".equals(to) || "INACTIVE".equals(to);
            case "VERIFIED" -> "ACTIVE".equals(to) || "INACTIVE".equals(to);
            case "ACTIVE" -> "INACTIVE".equals(to);
            case "INACTIVE" -> "PENDING_REVIEW".equals(to);
            default -> false;
        };
        if (!allowed) {
            throw new ApiException("INVALID_WORKFLOW_TRANSITION",
                    "Cannot transition geofence boundary from " + from + " to " + to, HttpStatus.BAD_REQUEST);
        }
    }

    private String extractGeometryJson(String rawGeoJson) {
        try {
            JsonNode root = objectMapper.readTree(rawGeoJson);
            String type = root.path("type").asText("");
            if ("FeatureCollection".equalsIgnoreCase(type)) {
                JsonNode features = root.path("features");
                if (!features.isArray() || features.isEmpty()) {
                    throw new ApiException("INVALID_GEOJSON", "FeatureCollection has no features", HttpStatus.BAD_REQUEST);
                }
                return objectMapper.writeValueAsString(features.get(0).path("geometry"));
            }
            if ("Feature".equalsIgnoreCase(type)) {
                return objectMapper.writeValueAsString(root.path("geometry"));
            }
            return objectMapper.writeValueAsString(root);
        } catch (ApiException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new ApiException("INVALID_GEOJSON", "Malformed GeoJSON: " + ex.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    private BoundaryResponseDto fetchBoundaryById(UUID geofenceId) {
        String sql = """
                SELECT g.geofence_id, l.locality_id, l.locality_code, l.locality_name,
                       g.boundary_name, g.boundary_version, g.verification_status,
                       g.boundary_source, g.source_url, g.source_license, g.source_version,
                       ST_AsGeoJSON(g.geometry) AS geojson, g.verified_at
                FROM geofence_boundaries g
                JOIN service_localities l ON l.locality_id = g.locality_id
                WHERE g.geofence_id = ?
                """;
        return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
            Timestamp ts = rs.getTimestamp("verified_at");
            return new BoundaryResponseDto(
                    UUID.fromString(rs.getString("geofence_id")),
                    UUID.fromString(rs.getString("locality_id")),
                    rs.getString("locality_code"),
                    rs.getString("locality_name"),
                    rs.getString("boundary_name"),
                    rs.getInt("boundary_version"),
                    rs.getString("verification_status"),
                    rs.getString("boundary_source"),
                    rs.getString("source_url"),
                    rs.getString("source_license"),
                    rs.getString("source_version"),
                    rs.getString("geojson"),
                    ts != null ? ts.toInstant() : null
            );
        }, geofenceId);
    }

    @Transactional(readOnly = true)
    public List<PincodeServiceabilityDto> listPincodes(boolean approvedOnly) {
        String sql = """
                SELECT p.pincode_id, p.pin_code, p.state_name, p.district_name, p.postal_locality_name,
                       p.locality_id, l.locality_code, l.locality_name, p.zone_id,
                       p.serviceability_status, p.customer_delivery_enabled, p.farmer_collection_enabled,
                       p.data_source, p.source_url, p.verification_status,
                       p.last_verified_at, p.approved_at, p.effective_from, p.effective_until
                FROM pincode_serviceability p
                LEFT JOIN service_localities l ON l.locality_id = p.locality_id
                """ + (approvedOnly ? "WHERE p.verification_status = 'VERIFIED' AND p.serviceability_status = 'APPROVED' " : "") + """
                ORDER BY p.pin_code ASC, p.postal_locality_name ASC
                """;
        return jdbcTemplate.query(sql, (rs, rowNum) -> mapPincodeDto(rs));
    }

    @Transactional
    public PincodeServiceabilityDto importPincode(UUID actorId, ImportPincodeRequest req) {
        String pin = normalizePin(req.pinCode());
        if (pin == null) {
            throw new ApiException("INVALID_PINCODE", "PIN code must be a valid 6-digit Indian PIN code", HttpStatus.BAD_REQUEST);
        }
        if (req.postalLocalityName() == null || req.postalLocalityName().isBlank()) {
            throw new ApiException("POSTAL_LOCALITY_REQUIRED", "Postal locality name is required", HttpStatus.BAD_REQUEST);
        }
        UUID zoneId = null;
        if (req.localityId() != null) {
            ServiceAreaSummaryDto loc = getLocalityDetails(req.localityId());
            zoneId = loc.zoneId();
        }
        UUID id = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO pincode_serviceability (
                    pincode_id, pin_code, state_name, district_name, postal_locality_name,
                    locality_id, zone_id, serviceability_status, customer_delivery_enabled,
                    farmer_collection_enabled, data_source, source_url, verification_status, last_verified_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING', ?, ?, ?, ?, 'UNVERIFIED', NOW())
                """,
                id, pin,
                req.stateName() != null && !req.stateName().isBlank() ? req.stateName().trim() : "Maharashtra",
                req.districtName() != null && !req.districtName().isBlank() ? req.districtName().trim() : "Pune",
                req.postalLocalityName().trim(),
                req.localityId(), zoneId,
                req.customerDeliveryEnabled(), req.farmerCollectionEnabled(),
                req.dataSource(), req.sourceUrl());

        writeAudit(actorId, "PINCODE_IMPORTED", null, req.localityId(), null,
                pin + " (" + req.postalLocalityName().trim() + ")", req.dataSource());
        return fetchPincodeById(id);
    }

    @Transactional
    public PincodeServiceabilityDto reviewPincode(UUID actorId, UUID pincodeId, ReviewPincodeRequest req) {
        PincodeServiceabilityDto prev = fetchPincodeById(pincodeId);
        String verStatus = req.verificationStatus() != null && !req.verificationStatus().isBlank()
                ? req.verificationStatus().trim().toUpperCase(Locale.ROOT)
                : prev.verificationStatus();
        String svcStatus = req.serviceabilityStatus() != null && !req.serviceabilityStatus().isBlank()
                ? req.serviceabilityStatus().trim().toUpperCase(Locale.ROOT)
                : prev.serviceabilityStatus();
        boolean custDel = req.customerDeliveryEnabled() != null ? req.customerDeliveryEnabled() : prev.customerDeliveryEnabled();
        boolean farmCol = req.farmerCollectionEnabled() != null ? req.farmerCollectionEnabled() : prev.farmerCollectionEnabled();

        jdbcTemplate.update("""
                UPDATE pincode_serviceability
                SET verification_status = ?,
                    serviceability_status = ?,
                    customer_delivery_enabled = ?,
                    farmer_collection_enabled = ?,
                    last_verified_at = CASE WHEN ? = 'VERIFIED' THEN NOW() ELSE last_verified_at END,
                    approved_by = CASE WHEN ? = 'APPROVED' THEN ? ELSE approved_by END,
                    approved_at = CASE WHEN ? = 'APPROVED' THEN NOW() ELSE approved_at END,
                    updated_at = NOW()
                WHERE pincode_id = ?
                """, verStatus, svcStatus, custDel, farmCol, verStatus, svcStatus, actorId, svcStatus, pincodeId);

        writeAudit(actorId, "PINCODE_REVIEWED", null, prev.localityId(),
                prev.verificationStatus() + "/" + prev.serviceabilityStatus(),
                verStatus + "/" + svcStatus, req.reason());
        return fetchPincodeById(pincodeId);
    }

    private PincodeServiceabilityDto fetchPincodeById(UUID pincodeId) {
        String sql = """
                SELECT p.pincode_id, p.pin_code, p.state_name, p.district_name, p.postal_locality_name,
                       p.locality_id, l.locality_code, l.locality_name, p.zone_id,
                       p.serviceability_status, p.customer_delivery_enabled, p.farmer_collection_enabled,
                       p.data_source, p.source_url, p.verification_status,
                       p.last_verified_at, p.approved_at, p.effective_from, p.effective_until
                FROM pincode_serviceability p
                LEFT JOIN service_localities l ON l.locality_id = p.locality_id
                WHERE p.pincode_id = ?
                """;
        List<PincodeServiceabilityDto> rows = jdbcTemplate.query(sql, (rs, rowNum) -> mapPincodeDto(rs), pincodeId);
        if (rows.isEmpty()) {
            throw new ApiException("PINCODE_NOT_FOUND", "PIN-code mapping not found", HttpStatus.NOT_FOUND);
        }
        return rows.get(0);
    }

    private PincodeServiceabilityDto mapPincodeDto(java.sql.ResultSet rs) throws java.sql.SQLException {
        String locIdStr = rs.getString("locality_id");
        String zoneIdStr = rs.getString("zone_id");
        Timestamp lv = rs.getTimestamp("last_verified_at");
        Timestamp ap = rs.getTimestamp("approved_at");
        Timestamp ef = rs.getTimestamp("effective_from");
        Timestamp eu = rs.getTimestamp("effective_until");
        return new PincodeServiceabilityDto(
                UUID.fromString(rs.getString("pincode_id")),
                rs.getString("pin_code"),
                rs.getString("state_name"),
                rs.getString("district_name"),
                rs.getString("postal_locality_name"),
                locIdStr != null ? UUID.fromString(locIdStr) : null,
                rs.getString("locality_code"),
                rs.getString("locality_name"),
                zoneIdStr != null ? UUID.fromString(zoneIdStr) : null,
                rs.getString("serviceability_status"),
                rs.getBoolean("customer_delivery_enabled"),
                rs.getBoolean("farmer_collection_enabled"),
                rs.getString("data_source"),
                rs.getString("source_url"),
                rs.getString("verification_status"),
                lv != null ? lv.toInstant() : null,
                ap != null ? ap.toInstant() : null,
                ef != null ? ef.toInstant() : null,
                eu != null ? eu.toInstant() : null
        );
    }

    private String normalizePin(String raw) {
        if (raw == null) return null;
        String clean = raw.trim().replaceAll("\\D", "");
        return clean.matches("^[1-9][0-9]{5}$") ? clean : null;
    }

    private boolean isFallbackAllowed(ServiceCapabilitiesDto caps, String requestedOperation) {
        if (caps == null) return false;
        if (requestedOperation == null || requestedOperation.isBlank()) {
            return caps.pincodeFallbackCustomerEnabled() || caps.pincodeFallbackFarmerEnabled();
        }
        String op = requestedOperation.trim().toUpperCase(Locale.ROOT);
        if (op.startsWith("FARM")) {
            return caps.pincodeFallbackFarmerEnabled();
        }
        return caps.pincodeFallbackCustomerEnabled();
    }

    private boolean hasApprovedPincodeForLocality(String pinCode, UUID localityId, String requestedOperation) {
        boolean isFarmer = requestedOperation != null && requestedOperation.trim().toUpperCase(Locale.ROOT).startsWith("FARM");
        String capCol = isFarmer ? "p.farmer_collection_enabled" : "p.customer_delivery_enabled";
        Integer count = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM pincode_serviceability p WHERE p.pin_code = ? AND p.locality_id = ? " +
                        "AND p.verification_status = 'VERIFIED' AND p.serviceability_status = 'APPROVED' " +
                        "AND " + capCol + " = true AND p.effective_from <= NOW() " +
                        "AND (p.effective_until IS NULL OR p.effective_until > NOW())",
                Integer.class, pinCode, localityId
        );
        return count != null && count > 0;
    }

    private List<GeofenceValidationResult> findApprovedPincodeMatches(String pinCode, String requestedOperation) {
        boolean isFarmer = requestedOperation != null && requestedOperation.trim().toUpperCase(Locale.ROOT).startsWith("FARM");
        String capCol = isFarmer ? "p.farmer_collection_enabled" : "p.customer_delivery_enabled";
        String sql = """
                SELECT r.region_id, r.region_name,
                       z.zone_id, z.zone_name,
                       l.locality_id, l.locality_code, l.locality_name,
                       scr.customer_delivery_enabled, scr.collection_enabled, scr.customer_order_enabled,
                       scr.farmer_registration_enabled, scr.farmer_listing_enabled, scr.delivery_enabled,
                       scr.pincode_fallback_customer_enabled, scr.pincode_fallback_farmer_enabled,
                       scr.minimum_order_amount, scr.status AS rule_status
                FROM pincode_serviceability p
                JOIN service_localities l ON l.locality_id = p.locality_id
                JOIN service_zones z ON z.zone_id = l.zone_id
                JOIN service_regions r ON r.region_id = z.region_id
                LEFT JOIN service_coverage_rules scr ON scr.locality_id = l.locality_id
                WHERE p.pin_code = ?
                  AND p.verification_status = 'VERIFIED'
                  AND p.serviceability_status = 'APPROVED'
                  AND p.effective_from <= NOW()
                  AND (p.effective_until IS NULL OR p.effective_until > NOW())
                  AND l.status = 'ACTIVE'
                  AND z.status = 'ACTIVE'
                  AND r.status = 'ACTIVE'
                  AND """ + capCol + " = true";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            ServiceCapabilitiesDto caps = new ServiceCapabilitiesDto(
                    rs.getBoolean("customer_delivery_enabled"),
                    rs.getBoolean("collection_enabled"),
                    rs.getBoolean("customer_order_enabled"),
                    rs.getBoolean("farmer_registration_enabled"),
                    rs.getBoolean("farmer_listing_enabled"),
                    rs.getBoolean("collection_enabled"),
                    rs.getBoolean("pincode_fallback_customer_enabled"),
                    rs.getBoolean("pincode_fallback_farmer_enabled"),
                    rs.getBigDecimal("minimum_order_amount") != null ? rs.getBigDecimal("minimum_order_amount") : BigDecimal.ZERO,
                    rs.getString("rule_status") != null ? rs.getString("rule_status") : "DRAFT"
            );
            return new GeofenceValidationResult(
                    false, false, "MATCHED", "PINCODE_FALLBACK", "Matched verified PIN code",
                    UUID.fromString(rs.getString("region_id")),
                    rs.getString("region_name"),
                    UUID.fromString(rs.getString("zone_id")),
                    rs.getString("zone_name"),
                    UUID.fromString(rs.getString("locality_id")),
                    rs.getString("locality_code"),
                    rs.getString("locality_name"),
                    null, pinCode, true, false, requestedOperation, caps
            );
        }, pinCode);
    }

    private void writeAudit(UUID actorId, String action, UUID geofenceId, UUID localityId, String prev, String next, String reason) {
        jdbcTemplate.update("""
                INSERT INTO geofence_audit_log (audit_id, actor_id, action, geofence_id, locality_id, previous_state, new_state, reason)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """, UUID.randomUUID(), actorId, action, geofenceId, localityId, prev, next, reason);
    }
}
