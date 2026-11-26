package com.kisansetu.modules.servicearea;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.BoundaryResponseDto;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.GeofenceValidateRequest;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.GeofenceValidationResult;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.PincodeServiceabilityDto;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.ServiceAreaSummaryDto;
import com.kisansetu.modules.servicearea.service.GeofenceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/service-areas")
@Tag(name = "Service Areas & Geofencing", description = "PostGIS polygon geofencing and capability-based serviceability")
public class ServiceAreaController {

    private final ServiceAreaService serviceAreaService;
    private final GeofenceService geofenceService;

    public ServiceAreaController(ServiceAreaService serviceAreaService, GeofenceService geofenceService) {
        this.serviceAreaService = serviceAreaService;
        this.geofenceService = geofenceService;
    }

    @GetMapping
    @Operation(summary = "List service areas with regions, zones, localities, and capabilities")
    public ResponseEntity<ApiResponse<List<ServiceAreaSummaryDto>>> getServiceAreas() {
        return ResponseEntity.ok(ApiResponse.ok("Service areas retrieved", geofenceService.listServiceAreas()));
    }

    @PostMapping("/validate")
    @Operation(summary = "Validate coordinates and PIN code against PostGIS geofence boundaries and verified PIN-code rules")
    public ResponseEntity<ApiResponse<GeofenceValidationResult>> validateLocation(@RequestBody GeofenceValidateRequest request) {
        GeofenceValidationResult result = geofenceService.validateServiceability(request);
        return ResponseEntity.ok(ApiResponse.ok(result.message(), result));
    }

    @GetMapping("/pincodes")
    @Operation(summary = "List approved PIN-code serviceability mappings")
    public ResponseEntity<ApiResponse<List<PincodeServiceabilityDto>>> getApprovedPincodes() {
        return ResponseEntity.ok(ApiResponse.ok("Approved PIN codes retrieved", geofenceService.listPincodes(true)));
    }

    @GetMapping("/locate")
    @Operation(summary = "Find active locality for coordinates")
    public ResponseEntity<ApiResponse<GeofenceValidationResult>> locateCoordinate(
            @RequestParam double latitude,
            @RequestParam double longitude) {
        GeofenceValidationResult result = geofenceService.validatePoint(latitude, longitude, null);
        return ResponseEntity.ok(ApiResponse.ok(result.message(), result));
    }

    @GetMapping("/zones/{zoneId}")
    @Operation(summary = "Retrieve service-zone details and localities")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getZoneDetails(@PathVariable UUID zoneId) {
        return ResponseEntity.ok(ApiResponse.ok("Zone details retrieved", geofenceService.getZoneDetails(zoneId)));
    }

    @GetMapping("/{localityId}")
    @Operation(summary = "Retrieve service locality details")
    public ResponseEntity<ApiResponse<ServiceAreaSummaryDto>> getLocalityDetails(@PathVariable UUID localityId) {
        return ResponseEntity.ok(ApiResponse.ok("Locality details retrieved", geofenceService.getLocalityDetails(localityId)));
    }

    @GetMapping("/{localityId}/boundary")
    @Operation(summary = "Retrieve active public GeoJSON boundary for a locality")
    public ResponseEntity<ApiResponse<BoundaryResponseDto>> getPublicBoundary(@PathVariable UUID localityId) {
        return ResponseEntity.ok(ApiResponse.ok("Boundary GeoJSON retrieved", geofenceService.getPublicBoundaryGeoJson(localityId)));
    }

    @GetMapping("/check")
    @Operation(summary = "Legacy PIN code serviceability check")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkPincode(@RequestParam String pincode) {
        return ResponseEntity.ok(ApiResponse.ok("Serviceability check result", serviceAreaService.checkPincode(pincode)));
    }

    @PostMapping("/check")
    @Operation(summary = "Legacy PIN code serviceability check via POST")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkPincodePost(@RequestBody Map<String, String> body) {
        String pincode = body.getOrDefault("pincode", "");
        return ResponseEntity.ok(ApiResponse.ok("Serviceability check result", serviceAreaService.checkPincode(pincode)));
    }
}
