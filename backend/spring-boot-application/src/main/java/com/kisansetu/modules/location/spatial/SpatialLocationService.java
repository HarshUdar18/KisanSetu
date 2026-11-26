package com.kisansetu.modules.location.spatial;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.location.dto.LocationDtos.NearbyHubResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
public class SpatialLocationService {

    private static final Logger log = LoggerFactory.getLogger(SpatialLocationService.class);
    private static final double EARTH_RADIUS_METERS = 6_371_000.0;

    private final JdbcTemplate jdbcTemplate;

    public SpatialLocationService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void validateCoordinates(double latitude, double longitude) {
        if (Double.isNaN(latitude) || Double.isInfinite(latitude) || latitude < -90.0 || latitude > 90.0) {
            throw new ApiException("INVALID_COORDINATES", "Latitude must be between -90 and 90", HttpStatus.BAD_REQUEST);
        }
        if (Double.isNaN(longitude) || Double.isInfinite(longitude) || longitude < -180.0 || longitude > 180.0) {
            throw new ApiException("INVALID_COORDINATES", "Longitude must be between -180 and 180", HttpStatus.BAD_REQUEST);
        }
    }

    public List<NearbyHubResult> findNearbyHubs(double latitude, double longitude, double radiusKm, int limit, String hubType) {
        validateCoordinates(latitude, longitude);
        double clampedRadiusKm = Math.max(0.5, Math.min(radiusKm, 250.0));
        double radiusMeters = clampedRadiusKm * 1000.0;
        int clampedLimit = Math.max(1, Math.min(limit, 50));

        boolean hasHubType = hubType != null && !hubType.isBlank();
        String normalizedHubType = hasHubType ? hubType.trim().toUpperCase() : null;

        try {
            StringBuilder sql = new StringBuilder("""
                    SELECT CAST(id AS VARCHAR) AS hub_id,
                           code,
                           name,
                           hub_type,
                           COALESCE(address_line, '') AS address_line,
                           COALESCE(district, '') AS district,
                           COALESCE(state, '') AS state,
                           COALESCE(pincode, '') AS pincode,
                           CAST(latitude AS DOUBLE PRECISION) AS lat,
                           CAST(longitude AS DOUBLE PRECISION) AS lon,
                           ST_Distance(location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography) AS distance_meters
                    FROM hubs
                    WHERE status = 'ACTIVE'
                      AND location IS NOT NULL
                      AND ST_DWithin(location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)
                    """);
            List<Object> params = new ArrayList<>();
            params.add(longitude);
            params.add(latitude);
            params.add(longitude);
            params.add(latitude);
            params.add(radiusMeters);

            if (hasHubType) {
                sql.append(" AND hub_type = ?");
                params.add(normalizedHubType);
            }
            sql.append(" ORDER BY distance_meters ASC LIMIT ?");
            params.add(clampedLimit);

            return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> new NearbyHubResult(
                    rs.getString("hub_id"),
                    rs.getString("code"),
                    rs.getString("name"),
                    rs.getString("hub_type"),
                    rs.getString("address_line"),
                    rs.getString("district"),
                    rs.getString("state"),
                    rs.getString("pincode"),
                    rs.getDouble("lat"),
                    rs.getDouble("lon"),
                    rs.getDouble("distance_meters"),
                    "POSTGIS_GEOGRAPHY"
            ), params.toArray());
        } catch (DataAccessException ex) {
            log.debug("PostGIS query unavailable ({}), using Haversine fallback", ex.getMessage());
            return findNearbyHubsFallback(latitude, longitude, radiusMeters, clampedLimit, normalizedHubType);
        }
    }

    private List<NearbyHubResult> findNearbyHubsFallback(
            double latitude, double longitude, double radiusMeters, int limit, String normalizedHubType) {
        StringBuilder sql = new StringBuilder("""
                SELECT CAST(id AS VARCHAR) AS hub_id, code, name, hub_type,
                       COALESCE(address_line, '') AS address_line,
                       COALESCE(district, '') AS district,
                       COALESCE(state, '') AS state,
                       COALESCE(pincode, '') AS pincode,
                       latitude, longitude
                FROM hubs
                WHERE status = 'ACTIVE'
                  AND latitude IS NOT NULL
                  AND longitude IS NOT NULL
                """);
        List<Object> params = new ArrayList<>();
        if (normalizedHubType != null) {
            sql.append(" AND hub_type = ?");
            params.add(normalizedHubType);
        }

        List<NearbyHubResult> candidates = jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
            double hubLat = rs.getDouble("latitude");
            double hubLon = rs.getDouble("longitude");
            double dist = haversineMeters(latitude, longitude, hubLat, hubLon);
            return new NearbyHubResult(
                    rs.getString("hub_id"),
                    rs.getString("code"),
                    rs.getString("name"),
                    rs.getString("hub_type"),
                    rs.getString("address_line"),
                    rs.getString("district"),
                    rs.getString("state"),
                    rs.getString("pincode"),
                    hubLat,
                    hubLon,
                    dist,
                    "HAVERSINE_FALLBACK"
            );
        }, params.toArray());

        return candidates.stream()
                .filter(h -> h.distanceMeters() <= radiusMeters)
                .sorted(Comparator.comparingDouble(NearbyHubResult::distanceMeters))
                .limit(limit)
                .toList();
    }

    public double calculateGeodesicDistanceMeters(double originLat, double originLon, double destLat, double destLon) {
        validateCoordinates(originLat, originLon);
        validateCoordinates(destLat, destLon);
        try {
            Double result = jdbcTemplate.queryForObject(
                    "SELECT ST_Distance(ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography)",
                    Double.class,
                    originLon, originLat, destLon, destLat
            );
            return result != null ? result : haversineMeters(originLat, originLon, destLat, destLon);
        } catch (DataAccessException ex) {
            return haversineMeters(originLat, originLon, destLat, destLon);
        }
    }

    public void syncAddressLocation(UUID addressId, Double latitude, Double longitude) {
        syncPoint("addresses", addressId, latitude, longitude);
    }

    public void syncHubLocation(UUID hubId, Double latitude, Double longitude) {
        syncPoint("hubs", hubId, latitude, longitude);
    }

    public void syncFarmerFarmLocation(UUID farmId, Double latitude, Double longitude) {
        syncPoint("farmer_farms", farmId, latitude, longitude);
    }

    private void syncPoint(String tableName, UUID id, Double latitude, Double longitude) {
        if (id == null) {
            return;
        }
        try {
            if (latitude != null && longitude != null) {
                validateCoordinates(latitude, longitude);
                jdbcTemplate.update(
                        "UPDATE " + tableName + " SET location = ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography WHERE id = ?",
                        longitude, latitude, id
                );
            } else {
                jdbcTemplate.update("UPDATE " + tableName + " SET location = NULL WHERE id = ?", id);
            }
        } catch (DataAccessException ex) {
            log.debug("Skipping PostGIS point sync for {} ({}): {}", tableName, id, ex.getMessage());
        }
    }

    public static double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS_METERS * c;
    }
}
