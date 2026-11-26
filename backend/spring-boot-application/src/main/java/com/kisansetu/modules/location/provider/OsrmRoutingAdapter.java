package com.kisansetu.modules.location.provider;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.location.config.LocationProperties;
import com.kisansetu.modules.location.dto.LocationDtos.RouteCoordinate;
import com.kisansetu.modules.location.dto.LocationDtos.RouteResult;
import com.kisansetu.modules.location.entity.RouteCache;
import com.kisansetu.modules.location.repository.RouteCacheRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Component
public class OsrmRoutingAdapter implements RoutingProvider {

    private static final Logger log = LoggerFactory.getLogger(OsrmRoutingAdapter.class);
    private static final String PROVIDER_KEY = "osrm";
    private static final String DISCLAIMER = "Route provided by OSRM/OpenStreetMap for planning purposes. Actual travel time may vary with road and traffic conditions.";

    private final LocationProperties properties;
    private final RouteCacheRepository cacheRepository;
    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate;

    public OsrmRoutingAdapter(
            LocationProperties properties,
            RouteCacheRepository cacheRepository,
            ObjectMapper objectMapper) {
        this.properties = properties;
        this.cacheRepository = cacheRepository;
        this.objectMapper = objectMapper;

        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(5000);
        factory.setReadTimeout(10000);
        this.restTemplate = new RestTemplate(factory);
    }

    @Override
    public String getProviderName() {
        return PROVIDER_KEY;
    }

    @Override
    public RouteResult calculateRoute(double originLat, double originLon, double destLat, double destLon, String travelMode) {
        if (!properties.getRouting().isEnabled()) {
            throw new ApiException("ROUTING_DISABLED", "Routing service is currently disabled", HttpStatus.SERVICE_UNAVAILABLE);
        }

        String normalizedMode = normalizeTravelMode(travelMode);
        String osrmProfile = toOsrmProfile(normalizedMode);

        String originHash = sha256(String.format(Locale.US, "%.5f,%.5f", originLat, originLon));
        String destHash = sha256(String.format(Locale.US, "%.5f,%.5f", destLat, destLon));

        Optional<RouteCache> cached = cacheRepository.findByProviderAndTravelModeAndOriginHashAndDestinationHash(
                PROVIDER_KEY, normalizedMode, originHash, destHash);
        if (cached.isPresent() && cached.get().getExpiresAt().isAfter(Instant.now())) {
            try {
                return objectMapper.readValue(cached.get().getRouteResponse(), RouteResult.class);
            } catch (Exception ignored) {
                // Fall through to live call
            }
        }

        String url = String.format(
                Locale.US,
                "%s/route/v1/%s/%.6f,%.6f;%.6f,%.6f?overview=full&geometries=geojson",
                properties.getRouting().getBaseUrl(),
                osrmProfile,
                originLon,
                originLat,
                destLon,
                destLat
        );

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("User-Agent", properties.getGeocoding().getUserAgent());
            headers.set("Accept", "application/json");
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(headers), String.class);

            JsonNode root = objectMapper.readTree(response.getBody());
            String code = root.path("code").asText("");
            JsonNode routes = root.path("routes");
            if (!"Ok".equalsIgnoreCase(code) || !routes.isArray() || routes.isEmpty()) {
                throw new ApiException("ROUTE_NOT_FOUND", "No drivable route found between the specified locations", HttpStatus.NOT_FOUND);
            }

            JsonNode primary = routes.get(0);
            double distanceMeters = primary.path("distance").asDouble();
            double durationSeconds = primary.path("duration").asDouble();

            List<RouteCoordinate> geometry = new ArrayList<>();
            JsonNode coords = primary.path("geometry").path("coordinates");
            if (coords.isArray()) {
                for (JsonNode point : coords) {
                    if (point.isArray() && point.size() >= 2) {
                        // GeoJSON uses [longitude, latitude]
                        double lon = point.get(0).asDouble();
                        double lat = point.get(1).asDouble();
                        geometry.add(new RouteCoordinate(lat, lon));
                    }
                }
            }

            RouteResult result = new RouteResult(
                    distanceMeters,
                    durationSeconds,
                    normalizedMode,
                    PROVIDER_KEY,
                    geometry,
                    DISCLAIMER
            );

            RouteCache entry = cached.orElseGet(RouteCache::new);
            entry.setProvider(PROVIDER_KEY);
            entry.setTravelMode(normalizedMode);
            entry.setOriginHash(originHash);
            entry.setDestinationHash(destHash);
            entry.setDistanceMeters(BigDecimal.valueOf(distanceMeters));
            entry.setDurationSeconds(BigDecimal.valueOf(durationSeconds));
            entry.setRouteResponse(objectMapper.writeValueAsString(result));
            entry.setExpiresAt(Instant.now().plus(properties.getRouting().getCacheTtlHours(), ChronoUnit.HOURS));
            cacheRepository.save(entry);

            return result;
        } catch (ApiException ex) {
            throw ex;
        } catch (Exception ex) {
            log.warn("OSRM route calculation failed: {}", ex.getMessage());
            throw new ApiException("ROUTING_UNAVAILABLE", "Unable to reach routing provider right now", HttpStatus.SERVICE_UNAVAILABLE);
        }
    }

    private String normalizeTravelMode(String travelMode) {
        if (travelMode == null || travelMode.isBlank()) {
            return "driving";
        }
        return switch (travelMode.trim().toLowerCase(Locale.ROOT)) {
            case "cycling", "bike" -> "cycling";
            case "walking", "foot" -> "walking";
            default -> "driving";
        };
    }

    private String toOsrmProfile(String normalizedMode) {
        return switch (normalizedMode) {
            case "cycling" -> "bike";
            case "walking" -> "foot";
            default -> "driving";
        };
    }

    private String sha256(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(bytes);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }
}
