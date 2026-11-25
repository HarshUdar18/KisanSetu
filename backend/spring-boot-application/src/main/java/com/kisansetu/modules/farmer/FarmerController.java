package com.kisansetu.modules.farmer;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.farmer.dto.CreateListingRequest;
import com.kisansetu.modules.farmer.dto.FarmerListingDto;
import com.kisansetu.modules.farmer.dto.UpdateAvailabilityRequest;
import com.kisansetu.modules.farmer.dto.UpdateListingRequest;
import com.kisansetu.modules.farmer.entity.FarmerProfile;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/farmer")
@Tag(name = "Farmer Produce Listings & Dashboard", description = "Endpoints restricted to registered Farmers and Administrators")
@SecurityRequirement(name = "BearerAuth")
public class FarmerController {

    private final FarmerService farmerService;
    private final FarmerListingService farmerListingService;

    public FarmerController(FarmerService farmerService, FarmerListingService farmerListingService) {
        this.farmerService = farmerService;
        this.farmerListingService = farmerListingService;
    }

    @GetMapping("/profile")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Get Farmer Profile", description = "Retrieves farm profile, land location, and agronomy details for the authenticated farmer.")
    public ResponseEntity<ApiResponse<FarmerProfile>> getProfile(@AuthenticationPrincipal UserPrincipal currentUser) {
        FarmerProfile profile = farmerService.getProfileByUserId(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.ok("Farmer profile retrieved successfully", profile));
    }

    @PutMapping("/profile")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Update Farmer Profile & Agronomy Details")
    public ResponseEntity<ApiResponse<FarmerProfile>> updateProfile(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @RequestBody Map<String, Object> body) {
        FarmerProfile updated = farmerService.updateProfile(currentUser.getId(), body);
        return ResponseEntity.ok(ApiResponse.ok("Farmer profile updated successfully", updated));
    }

    @GetMapping("/dashboard-summary")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Get Farmer Dashboard Summary", description = "Returns active listing count, pending collections, and financial settlement balance.")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDashboardSummary(
            @AuthenticationPrincipal UserPrincipal currentUser) {
        Map<String, Object> summary = farmerService.getDashboardSummary(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.ok("Farmer dashboard summary", summary));
    }

    // --- Farmer Produce Listings Endpoints ---

    @PostMapping("/listings")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Create a produce listing", description = "Allows a farmer to list available produce stock with quantity, unit, price, and harvest date.")
    public ResponseEntity<ApiResponse<FarmerListingDto>> createListing(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @Valid @RequestBody CreateListingRequest request) {
        FarmerListingDto listing = farmerListingService.createListing(currentUser.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Listing created successfully", listing));
    }

    @GetMapping("/listings")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "View the farmer's listings", description = "Retrieves only the produce listings belonging to the authenticated farmer.")
    public ResponseEntity<ApiResponse<List<FarmerListingDto>>> getMyListings(
            @AuthenticationPrincipal UserPrincipal currentUser) {
        List<FarmerListingDto> listings = farmerListingService.getFarmerListings(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.ok("Farmer listings retrieved successfully", listings));
    }

    @GetMapping("/listings/{id}")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Get listing details by ID")
    public ResponseEntity<ApiResponse<FarmerListingDto>> getListingById(@PathVariable UUID id) {
        FarmerListingDto listing = farmerListingService.getListingById(id);
        return ResponseEntity.ok(ApiResponse.ok("Listing details retrieved", listing));
    }

    @PutMapping("/listings/{id}")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Update a listing", description = "Allows a farmer to update quantity, price, or details of their own listing.")
    public ResponseEntity<ApiResponse<FarmerListingDto>> updateListing(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @PathVariable UUID id,
            @Valid @RequestBody UpdateListingRequest request) {
        FarmerListingDto updated = farmerListingService.updateListing(currentUser.getId(), id, request);
        return ResponseEntity.ok(ApiResponse.ok("Listing updated successfully", updated));
    }

    @PatchMapping("/listings/{id}/availability")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Update stock availability", description = "Toggles availability or updates stock quantity for the farmer's listing.")
    public ResponseEntity<ApiResponse<FarmerListingDto>> updateAvailability(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @PathVariable UUID id,
            @Valid @RequestBody UpdateAvailabilityRequest request) {
        FarmerListingDto updated = farmerListingService.updateAvailability(currentUser.getId(), id, request);
        return ResponseEntity.ok(ApiResponse.ok("Listing availability updated", updated));
    }
}
