package com.kisansetu.modules.location.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.location.config.LocationProperties;
import com.kisansetu.modules.location.dto.LocationDtos.DistanceRequest;
import com.kisansetu.modules.location.dto.LocationDtos.GeocodeResult;
import com.kisansetu.modules.location.dto.LocationDtos.NearbyHubResult;
import com.kisansetu.modules.location.dto.LocationDtos.ProviderStatus;
import com.kisansetu.modules.location.dto.LocationDtos.RouteRequest;
import com.kisansetu.modules.location.dto.LocationDtos.RouteResult;
import com.kisansetu.modules.location.provider.GeocodingProvider;
import com.kisansetu.modules.location.provider.ReverseGeocodingProvider;
import com.kisansetu.modules.location.provider.RoutingProvider;
import com.kisansetu.modules.location.spatial.SpatialLocationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/locations")
@Tag(name = "Geospatial & OpenStreetMap Location Services", description = "Shared geocoding, reverse geocoding, PostGIS nearby hub search, and OSRM routing")
public class LocationController {

    private final GeocodingProvider geocodingProvider;
    private final ReverseGeocodingProvider reverseGeocodingProvider;
    private final RoutingProvider routingProvider;
    private final SpatialLocationService spatialLocationService;
    private final LocationProperties properties;

    public LocationController(
            GeocodingProvider geocodingProvider,
            ReverseGeocodingProvider reverseGeocodingProvider,
            RoutingProvider routingProvider,
            SpatialLocationService spatialLocationService,
            LocationProperties properties) {
        this.geocodingProvider = geocodingProvider;
        this.reverseGeocodingProvider = reverseGeocodingProvider;
        this.routingProvider = routingProvider;
        this.spatialLocationService = spatialLocationService;
        this.properties = properties;
    }

    @GetMapping("/providers/status")
    @Operation(summary = "Get Location Provider Configuration Status")
    public ResponseEntity<ApiResponse<ProviderStatus>> getProviderStatus() {
        ProviderStatus status = new ProviderStatus(
                properties.getMap().getProvider(),
                properties.getMap().getTileUrl(),
                properties.getMap().getAttribution(),
                properties.getGeocoding().getProvider(),
                properties.getGeocoding().isEnabled(),
                properties.getRouting().getProvider(),
                properties.getRouting().isEnabled(),
                properties.getNearby().getDatabaseProvider(),
                Map.of(
                        "geocodingMinIntervalMs", properties.getGeocoding().getMinimumIntervalMs(),
                        "geocodingCacheTtlHours", properties.getGeocoding().getCacheTtlHours(),
                        "routingCacheTtlHours", properties.getRouting().getCacheTtlHours()
                )
        );
        return ResponseEntity.ok(ApiResponse.ok("Location provider status retrieved", status));
    }

    @GetMapping("/geocode")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Forward Geocode Address or Place Name")
    public ResponseEntity<ApiResponse<List<GeocodeResult>>> geocode(@RequestParam("q") String query) {
        List<GeocodeResult> results = geocodingProvider.forwardGeocode(query);
        return ResponseEntity.ok(ApiResponse.ok("Geocoding results retrieved", results));
    }

    @GetMapping("/reverse-geocode")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Reverse Geocode Coordinates to Address")
    public ResponseEntity<ApiResponse<GeocodeResult>> reverseGeocode(
            @RequestParam("lat") double latitude,
            @RequestParam("lon") double longitude) {
        spatialLocationService.validateCoordinates(latitude, longitude);
        GeocodeResult result = reverseGeocodingProvider.reverseGeocode(latitude, longitude);
        return ResponseEntity.ok(ApiResponse.ok("Reverse geocoding result retrieved", result));
    }

    @GetMapping("/nearby/hubs")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Find Nearby Hubs and Collection Centres using PostGIS")
    public ResponseEntity<ApiResponse<List<NearbyHubResult>>> findNearbyHubs(
            @RequestParam("lat") double latitude,
            @RequestParam("lon") double longitude,
            @RequestParam(value = "radiusKm", defaultValue = "25") double radiusKm,
            @RequestParam(value = "limit", defaultValue = "20") int limit,
            @RequestParam(value = "hubType", required = false) String hubType) {
        List<NearbyHubResult> hubs = spatialLocationService.findNearbyHubs(latitude, longitude, radiusKm, limit, hubType);
        return ResponseEntity.ok(ApiResponse.ok("Nearby hubs retrieved", hubs));
    }

    @PostMapping("/routes")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Calculate Road Route between Two Coordinates via OSRM")
    public ResponseEntity<ApiResponse<RouteResult>> calculateRoute(@RequestBody RouteRequest request) {
        spatialLocationService.validateCoordinates(request.originLatitude(), request.originLongitude());
        spatialLocationService.validateCoordinates(request.destinationLatitude(), request.destinationLongitude());
        RouteResult route = routingProvider.calculateRoute(
                request.originLatitude(),
                request.originLongitude(),
                request.destinationLatitude(),
                request.destinationLongitude(),
                request.travelMode()
        );
        return ResponseEntity.ok(ApiResponse.ok("Route calculated", route));
    }

    @PostMapping("/distance")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Calculate Geodesic or Road Distance")
    public ResponseEntity<ApiResponse<Map<String, Object>>> calculateDistance(@RequestBody DistanceRequest request) {
        spatialLocationService.validateCoordinates(request.originLatitude(), request.originLongitude());
        spatialLocationService.validateCoordinates(request.destinationLatitude(), request.destinationLongitude());

        String type = request.calculationType() != null ? request.calculationType().trim().toUpperCase() : "GEODESIC";
        if ("ROAD".equals(type)) {
            RouteResult route = routingProvider.calculateRoute(
                    request.originLatitude(),
                    request.originLongitude(),
                    request.destinationLatitude(),
                    request.destinationLongitude(),
                    "driving"
            );
            return ResponseEntity.ok(ApiResponse.ok("Road distance calculated", Map.of(
                    "distanceMeters", route.distanceMeters(),
                    "durationSeconds", route.durationSeconds(),
                    "calculationType", "ROAD",
                    "provider", route.provider()
            )));
        }

        double meters = spatialLocationService.calculateGeodesicDistanceMeters(
                request.originLatitude(),
                request.originLongitude(),
                request.destinationLatitude(),
                request.destinationLongitude()
        );
        return ResponseEntity.ok(ApiResponse.ok("Geodesic distance calculated", Map.of(
                "distanceMeters", meters,
                "calculationType", "GEODESIC",
                "provider", "postgis"
        )));
    }
}
