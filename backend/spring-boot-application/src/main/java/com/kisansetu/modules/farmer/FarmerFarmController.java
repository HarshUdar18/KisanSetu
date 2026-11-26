package com.kisansetu.modules.farmer;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.farmer.entity.FarmerFarm;
import com.kisansetu.modules.farmer.repository.FarmerFarmRepository;
import com.kisansetu.modules.location.spatial.SpatialLocationService;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.GeofenceValidationResult;
import com.kisansetu.modules.servicearea.service.GeofenceService;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/farmer/farms")
@Tag(name = "Farmer Farms & Geospatial Mapping", description = "CRUD for farmer farm locations with PostGIS coordinate storage")
@SecurityRequirement(name = "BearerAuth")
public class FarmerFarmController {

    private final FarmerFarmRepository farmRepository;
    private final UserRepository userRepository;
    private final SpatialLocationService spatialLocationService;
    private final GeofenceService geofenceService;

    public FarmerFarmController(
            FarmerFarmRepository farmRepository,
            UserRepository userRepository,
            SpatialLocationService spatialLocationService,
            GeofenceService geofenceService) {
        this.farmRepository = farmRepository;
        this.userRepository = userRepository;
        this.spatialLocationService = spatialLocationService;
        this.geofenceService = geofenceService;
    }

    public record FarmerFarmRequest(
            String farmName,
            String addressLine,
            String village,
            String taluka,
            String district,
            String state,
            String pincode,
            String formattedAddress,
            Double latitude,
            Double longitude,
            BigDecimal landArea,
            String landUnit,
            String soilType,
            String irrigationType
    ) {}

    public record FarmerFarmDto(
            UUID id,
            String farmName,
            String addressLine,
            String village,
            String taluka,
            String district,
            String state,
            String pincode,
            String formattedAddress,
            Double latitude,
            Double longitude,
            BigDecimal landArea,
            String landUnit,
            String soilType,
            String irrigationType,
            Instant createdAt,
            Instant updatedAt,
            GeofenceValidationResult serviceAreaStatus
    ) {
        public static FarmerFarmDto from(FarmerFarm farm, GeofenceValidationResult serviceAreaStatus) {
            return new FarmerFarmDto(
                    farm.getId(),
                    farm.getFarmName(),
                    farm.getAddressLine(),
                    farm.getVillage(),
                    farm.getTaluka(),
                    farm.getDistrict(),
                    farm.getState(),
                    farm.getPincode(),
                    farm.getFormattedAddress(),
                    farm.getLatitude() != null ? farm.getLatitude().doubleValue() : null,
                    farm.getLongitude() != null ? farm.getLongitude().doubleValue() : null,
                    farm.getLandArea(),
                    farm.getLandUnit(),
                    farm.getSoilType(),
                    farm.getIrrigationType(),
                    farm.getCreatedAt(),
                    farm.getUpdatedAt(),
                    serviceAreaStatus
            );
        }

        public static FarmerFarmDto from(FarmerFarm farm) {
            return from(farm, null);
        }
    }

    @GetMapping
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "List Authenticated Farmer Farms")
    @Transactional(readOnly = true)
    public ResponseEntity<ApiResponse<List<FarmerFarmDto>>> listFarms(@AuthenticationPrincipal UserPrincipal currentUser) {
        List<FarmerFarmDto> farms = farmRepository.findByFarmerIdOrderByCreatedAtDesc(currentUser.getId())
                .stream()
                .map(FarmerFarmDto::from)
                .toList();
        return ResponseEntity.ok(ApiResponse.ok("Farmer farms retrieved", farms));
    }

    @GetMapping("/{farmId}")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Get Farmer Farm by ID")
    @Transactional(readOnly = true)
    public ResponseEntity<ApiResponse<FarmerFarmDto>> getFarm(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @PathVariable UUID farmId) {
        FarmerFarm farm = farmRepository.findByIdAndFarmerId(farmId, currentUser.getId())
                .orElseThrow(() -> new ApiException("FARM_NOT_FOUND", "Farm not found or unauthorized", HttpStatus.NOT_FOUND));
        return ResponseEntity.ok(ApiResponse.ok("Farmer farm retrieved", FarmerFarmDto.from(farm)));
    }

    @PostMapping
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Create Farmer Farm")
    @Transactional
    public ResponseEntity<ApiResponse<FarmerFarmDto>> createFarm(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @RequestBody FarmerFarmRequest request) {
        if (request.farmName() == null || request.farmName().isBlank()) {
            throw new ApiException("INVALID_FARM_NAME", "Farm name is required", HttpStatus.BAD_REQUEST);
        }
        validateOptionalCoords(request.latitude(), request.longitude());

        User farmer = userRepository.findById(currentUser.getId())
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "Farmer account not found", HttpStatus.NOT_FOUND));

        FarmerFarm farm = new FarmerFarm();
        farm.setFarmer(farmer);
        applyRequest(farm, request);

        FarmerFarm saved = farmRepository.saveAndFlush(farm);
        spatialLocationService.syncFarmerFarmLocation(saved.getId(), request.latitude(), request.longitude());
        GeofenceValidationResult geo = evaluateFarmCoverage(request.latitude(), request.longitude());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Farmer farm created", FarmerFarmDto.from(saved, geo)));
    }

    @PutMapping("/{farmId}")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Update Farmer Farm")
    @Transactional
    public ResponseEntity<ApiResponse<FarmerFarmDto>> updateFarm(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @PathVariable UUID farmId,
            @RequestBody FarmerFarmRequest request) {
        FarmerFarm farm = farmRepository.findByIdAndFarmerId(farmId, currentUser.getId())
                .orElseThrow(() -> new ApiException("FARM_NOT_FOUND", "Farm not found or unauthorized", HttpStatus.NOT_FOUND));
        validateOptionalCoords(request.latitude(), request.longitude());

        applyRequest(farm, request);
        farm.setUpdatedAt(Instant.now());

        FarmerFarm saved = farmRepository.saveAndFlush(farm);
        spatialLocationService.syncFarmerFarmLocation(saved.getId(), request.latitude(), request.longitude());
        GeofenceValidationResult geo = evaluateFarmCoverage(request.latitude(), request.longitude());
        return ResponseEntity.ok(ApiResponse.ok("Farmer farm updated", FarmerFarmDto.from(saved, geo)));
    }

    private GeofenceValidationResult evaluateFarmCoverage(Double lat, Double lon) {
        if (lat == null || lon == null) return null;
        try {
            return geofenceService.validatePoint(lat, lon, "FARM_COLLECTION");
        } catch (Exception ex) {
            return null;
        }
    }

    @DeleteMapping("/{farmId}")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Delete Farmer Farm")
    @Transactional
    public ResponseEntity<ApiResponse<Void>> deleteFarm(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @PathVariable UUID farmId) {
        FarmerFarm farm = farmRepository.findByIdAndFarmerId(farmId, currentUser.getId())
                .orElseThrow(() -> new ApiException("FARM_NOT_FOUND", "Farm not found or unauthorized", HttpStatus.NOT_FOUND));
        farmRepository.delete(farm);
        return ResponseEntity.ok(ApiResponse.ok("Farmer farm deleted", null));
    }

    private void validateOptionalCoords(Double lat, Double lon) {
        if (lat != null && lon != null) {
            spatialLocationService.validateCoordinates(lat, lon);
        } else if (lat != null || lon != null) {
            throw new ApiException("INVALID_COORDINATES", "Both latitude and longitude must be provided together", HttpStatus.BAD_REQUEST);
        }
    }

    private void applyRequest(FarmerFarm farm, FarmerFarmRequest request) {
        if (request.farmName() != null && !request.farmName().isBlank()) {
            farm.setFarmName(request.farmName().trim());
        }
        farm.setAddressLine(request.addressLine());
        farm.setVillage(request.village());
        farm.setTaluka(request.taluka());
        farm.setDistrict(request.district());
        farm.setState(request.state());
        farm.setPincode(request.pincode());
        farm.setFormattedAddress(request.formattedAddress());
        farm.setLatitude(request.latitude() != null ? BigDecimal.valueOf(request.latitude()) : null);
        farm.setLongitude(request.longitude() != null ? BigDecimal.valueOf(request.longitude()) : null);
        farm.setLandArea(request.landArea());
        if (request.landUnit() != null && !request.landUnit().isBlank()) {
            farm.setLandUnit(request.landUnit().trim());
        }
        farm.setSoilType(request.soilType());
        farm.setIrrigationType(request.irrigationType());
    }
}
