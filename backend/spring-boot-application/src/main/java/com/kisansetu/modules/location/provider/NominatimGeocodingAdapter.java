package com.kisansetu.modules.location.provider;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.location.cache.DistributedLocationRateLimiter;
import com.kisansetu.modules.location.config.LocationProperties;
import com.kisansetu.modules.location.dto.LocationDtos.GeocodeResult;
import com.kisansetu.modules.location.entity.GeocodingCache;
import com.kisansetu.modules.location.repository.GeocodingCacheRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

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
public class NominatimGeocodingAdapter implements GeocodingProvider, ReverseGeocodingProvider {

    private static final Logger log = LoggerFactory.getLogger(NominatimGeocodingAdapter.class);
    private static final String PROVIDER_KEY = "nominatim";

    private final LocationProperties properties;
    private final GeocodingCacheRepository cacheRepository;
    private final DistributedLocationRateLimiter rateLimiter;
    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate;

    public NominatimGeocodingAdapter(
            LocationProperties properties,
            GeocodingCacheRepository cacheRepository,
            DistributedLocationRateLimiter rateLimiter,
            ObjectMapper objectMapper) {
        this.properties = properties;
        this.cacheRepository = cacheRepository;
        this.rateLimiter = rateLimiter;
        this.objectMapper = objectMapper;

        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(5000);
        factory.setReadTimeout(8000);
        this.restTemplate = new RestTemplate(factory);
    }

    @Override
    public String getProviderName() {
        return PROVIDER_KEY;
    }

    @Override
    public List<GeocodeResult> forwardGeocode(String query) {
        if (!properties.getGeocoding().isEnabled()) {
            throw new ApiException("GEOCODING_DISABLED", "Geocoding service is currently disabled", HttpStatus.SERVICE_UNAVAILABLE);
        }
        String normalized = query == null ? "" : query.trim().replaceAll("\\s+", " ").toLowerCase(Locale.ROOT);
        if (normalized.length() < 3) {
            throw new ApiException("INVALID_QUERY", "Search query must be at least 3 characters", HttpStatus.BAD_REQUEST);
        }

        String hash = sha256("forward:" + normalized);
        Optional<GeocodingCache> cached = cacheRepository.findByProviderAndOperationTypeAndQueryHash(PROVIDER_KEY, "FORWARD", hash);
        if (cached.isPresent() && cached.get().getExpiresAt().isAfter(Instant.now())) {
            try {
                return objectMapper.readValue(cached.get().getResponseJson(), new TypeReference<>() {});
            } catch (Exception ignored) {
                // Cache payload corrupted; fetch fresh
            }
        }

        rateLimiter.acquireSlot(PROVIDER_KEY, properties.getGeocoding().getMinimumIntervalMs());

        String url = UriComponentsBuilder
                .fromHttpUrl(properties.getGeocoding().getBaseUrl() + "/search")
                .queryParam("format", "jsonv2")
                .queryParam("addressdetails", 1)
                .queryParam("limit", 5)
                .queryParam("countrycodes", "in")
                .queryParam("q", normalized)
                .build()
                .toUriString();

        try {
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, buildHeadersEntity(), String.class);
            JsonNode root = objectMapper.readTree(response.getBody());
            List<GeocodeResult> results = new ArrayList<>();
            if (root.isArray()) {
                for (JsonNode item : root) {
                    GeocodeResult parsed = parseNominatimNode(item);
                    if (parsed != null) {
                        results.add(parsed);
                    }
                }
            }

            if (!results.isEmpty()) {
                saveCache("FORWARD", normalized, hash, objectMapper.writeValueAsString(results),
                        results.get(0).latitude(), results.get(0).longitude(), cached.orElse(null));
            }
            return results;
        } catch (HttpClientErrorException.TooManyRequests ex) {
            throw new ApiException("GEOCODING_RATE_LIMITED", "Geocoding provider rate limit reached. Please retry shortly.", HttpStatus.TOO_MANY_REQUESTS);
        } catch (ApiException ex) {
            throw ex;
        } catch (Exception ex) {
            log.warn("Nominatim forward geocode failed: {}", ex.getMessage());
            throw new ApiException("GEOCODING_UNAVAILABLE", "Unable to reach geocoding provider right now", HttpStatus.SERVICE_UNAVAILABLE);
        }
    }

    @Override
    public GeocodeResult reverseGeocode(double latitude, double longitude) {
        if (!properties.getGeocoding().isEnabled()) {
            throw new ApiException("GEOCODING_DISABLED", "Geocoding service is currently disabled", HttpStatus.SERVICE_UNAVAILABLE);
        }

        String normalized = String.format(Locale.US, "%.5f,%.5f", latitude, longitude);
        String hash = sha256("reverse:" + normalized);

        Optional<GeocodingCache> cached = cacheRepository.findByProviderAndOperationTypeAndQueryHash(PROVIDER_KEY, "REVERSE", hash);
        if (cached.isPresent() && cached.get().getExpiresAt().isAfter(Instant.now())) {
            try {
                return objectMapper.readValue(cached.get().getResponseJson(), GeocodeResult.class);
            } catch (Exception ignored) {
                // Fall through to fresh request
            }
        }

        rateLimiter.acquireSlot(PROVIDER_KEY, properties.getGeocoding().getMinimumIntervalMs());

        String url = UriComponentsBuilder
                .fromHttpUrl(properties.getGeocoding().getBaseUrl() + "/reverse")
                .queryParam("format", "jsonv2")
                .queryParam("addressdetails", 1)
                .queryParam("lat", String.format(Locale.US, "%.6f", latitude))
                .queryParam("lon", String.format(Locale.US, "%.6f", longitude))
                .build()
                .toUriString();

        try {
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, buildHeadersEntity(), String.class);
            JsonNode root = objectMapper.readTree(response.getBody());
            if (root.has("error")) {
                throw new ApiException("ADDRESS_NOT_FOUND", "No address found at the selected coordinates", HttpStatus.NOT_FOUND);
            }
            GeocodeResult result = parseNominatimNode(root);
            if (result == null) {
                throw new ApiException("ADDRESS_NOT_FOUND", "No address found at the selected coordinates", HttpStatus.NOT_FOUND);
            }

            saveCache("REVERSE", normalized, hash, objectMapper.writeValueAsString(result),
                    result.latitude(), result.longitude(), cached.orElse(null));
            return result;
        } catch (HttpClientErrorException.TooManyRequests ex) {
            throw new ApiException("GEOCODING_RATE_LIMITED", "Geocoding provider rate limit reached. Please retry shortly.", HttpStatus.TOO_MANY_REQUESTS);
        } catch (ApiException ex) {
            throw ex;
        } catch (Exception ex) {
            log.warn("Nominatim reverse geocode failed: {}", ex.getMessage());
            throw new ApiException("GEOCODING_UNAVAILABLE", "Unable to reach geocoding provider right now", HttpStatus.SERVICE_UNAVAILABLE);
        }
    }

    private HttpEntity<Void> buildHeadersEntity() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("User-Agent", properties.getGeocoding().getUserAgent());
        headers.set("Accept", "application/json");
        headers.set("Accept-Language", "en");
        return new HttpEntity<>(headers);
    }

    private GeocodeResult parseNominatimNode(JsonNode node) {
        if (node == null || !node.has("lat") || !node.has("lon")) {
            return null;
        }
        double lat = node.path("lat").asDouble();
        double lon = node.path("lon").asDouble();
        String displayName = node.path("display_name").asText("");
        String osmType = node.hasNonNull("osm_type") ? node.path("osm_type").asText() : null;
        Long osmId = node.hasNonNull("osm_id") ? node.path("osm_id").asLong() : null;

        JsonNode addr = node.path("address");
        String village = firstNonBlank(addr, "village", "hamlet", "suburb", "town", "city");
        String district = firstNonBlank(addr, "state_district", "county", "district");
        String state = firstNonBlank(addr, "state");
        String pincode = firstNonBlank(addr, "postcode");
        String country = firstNonBlank(addr, "country");

        List<Double> boundingBox = new ArrayList<>();
        if (node.has("boundingbox") && node.get("boundingbox").isArray()) {
            for (JsonNode b : node.get("boundingbox")) {
                try {
                    boundingBox.add(Double.parseDouble(b.asText()));
                } catch (NumberFormatException ignored) {
                }
            }
        }

        return new GeocodeResult(
                lat,
                lon,
                displayName,
                village,
                district,
                state,
                pincode,
                country,
                osmType,
                osmId,
                boundingBox,
                PROVIDER_KEY
        );
    }

    private String firstNonBlank(JsonNode addr, String... keys) {
        if (addr == null || addr.isMissingNode()) {
            return null;
        }
        for (String key : keys) {
            if (addr.hasNonNull(key)) {
                String val = addr.get(key).asText().trim();
                if (!val.isEmpty()) {
                    return val;
                }
            }
        }
        return null;
    }

    private void saveCache(
            String operationType,
            String normalizedQuery,
            String hash,
            String responseJson,
            double lat,
            double lon,
            GeocodingCache existing) {
        GeocodingCache entry = existing != null ? existing : new GeocodingCache();
        entry.setProvider(PROVIDER_KEY);
        entry.setOperationType(operationType);
        entry.setNormalizedQuery(normalizedQuery);
        entry.setQueryHash(hash);
        entry.setResponseJson(responseJson);
        entry.setLatitude(BigDecimal.valueOf(lat));
        entry.setLongitude(BigDecimal.valueOf(lon));
        entry.setExpiresAt(Instant.now().plus(properties.getGeocoding().getCacheTtlHours(), ChronoUnit.HOURS));
        cacheRepository.save(entry);
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
