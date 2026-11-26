package com.kisansetu.modules.admin.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.BoundaryResponseDto;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.ImportBoundaryRequest;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.ImportPincodeRequest;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.PincodeServiceabilityDto;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.ReviewPincodeRequest;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.ServiceAreaSummaryDto;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.UpdateCoverageRulesRequest;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.WorkflowTransitionRequest;
import com.kisansetu.modules.servicearea.service.GeofenceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin/super/geofences")
@PreAuthorize("hasRole('SUPER_ADMIN')")
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "Super Admin Geofence Management", description = "Verified GeoJSON boundary import, workflow activation, coverage rules, and audit logs")
public class SuperAdminGeofenceController {

    private final GeofenceService geofenceService;

    public SuperAdminGeofenceController(GeofenceService geofenceService) {
        this.geofenceService = geofenceService;
    }

    @PostMapping("/localities/{localityId}/import")
    @Operation(summary = "Import verified GeoJSON boundary as DRAFT")
    public ResponseEntity<ApiResponse<BoundaryResponseDto>> importBoundary(
            @AuthenticationPrincipal UserPrincipal actor,
            @PathVariable UUID localityId,
            @RequestBody ImportBoundaryRequest request) {
        BoundaryResponseDto saved = geofenceService.importGeoJsonBoundary(actor.getId(), localityId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Boundary imported as DRAFT", saved));
    }

    @PostMapping("/{geofenceId}/submit-review")
    @Operation(summary = "Submit DRAFT boundary for verification")
    public ResponseEntity<ApiResponse<BoundaryResponseDto>> submitForReview(
            @AuthenticationPrincipal UserPrincipal actor,
            @PathVariable UUID geofenceId,
            @RequestBody(required = false) WorkflowTransitionRequest req) {
        BoundaryResponseDto updated = geofenceService.transitionBoundaryStatus(
                actor.getId(), geofenceId, "PENDING_REVIEW", req != null ? req.reason() : null);
        return ResponseEntity.ok(ApiResponse.ok("Boundary submitted for review", updated));
    }

    @PostMapping("/{geofenceId}/verify")
    @Operation(summary = "Verify PENDING_REVIEW boundary")
    public ResponseEntity<ApiResponse<BoundaryResponseDto>> verifyBoundary(
            @AuthenticationPrincipal UserPrincipal actor,
            @PathVariable UUID geofenceId,
            @RequestBody(required = false) WorkflowTransitionRequest req) {
        BoundaryResponseDto updated = geofenceService.transitionBoundaryStatus(
                actor.getId(), geofenceId, "VERIFIED", req != null ? req.reason() : null);
        return ResponseEntity.ok(ApiResponse.ok("Boundary verified", updated));
    }

    @PostMapping("/{geofenceId}/activate")
    @Operation(summary = "Activate VERIFIED boundary (supersedes previous active version)")
    public ResponseEntity<ApiResponse<BoundaryResponseDto>> activateBoundary(
            @AuthenticationPrincipal UserPrincipal actor,
            @PathVariable UUID geofenceId,
            @RequestBody(required = false) WorkflowTransitionRequest req) {
        BoundaryResponseDto updated = geofenceService.transitionBoundaryStatus(
                actor.getId(), geofenceId, "ACTIVE", req != null ? req.reason() : null);
        return ResponseEntity.ok(ApiResponse.ok("Boundary activated", updated));
    }

    @PostMapping("/{geofenceId}/deactivate")
    @Operation(summary = "Deactivate ACTIVE boundary")
    public ResponseEntity<ApiResponse<BoundaryResponseDto>> deactivateBoundary(
            @AuthenticationPrincipal UserPrincipal actor,
            @PathVariable UUID geofenceId,
            @RequestBody(required = false) WorkflowTransitionRequest req) {
        BoundaryResponseDto updated = geofenceService.transitionBoundaryStatus(
                actor.getId(), geofenceId, "INACTIVE", req != null ? req.reason() : null);
        return ResponseEntity.ok(ApiResponse.ok("Boundary deactivated", updated));
    }

    @PutMapping("/localities/{localityId}/rules")
    @Operation(summary = "Update capability-based service coverage rules for a locality")
    public ResponseEntity<ApiResponse<ServiceAreaSummaryDto>> updateCoverageRules(
            @AuthenticationPrincipal UserPrincipal actor,
            @PathVariable UUID localityId,
            @RequestBody UpdateCoverageRulesRequest request) {
        ServiceAreaSummaryDto updated = geofenceService.updateCoverageRules(actor.getId(), localityId, request);
        return ResponseEntity.ok(ApiResponse.ok("Coverage rules updated", updated));
    }

    @GetMapping("/pincodes")
    @Operation(summary = "List all PIN-code serviceability mappings for Super Admin management")
    public ResponseEntity<ApiResponse<List<PincodeServiceabilityDto>>> listPincodes() {
        return ResponseEntity.ok(ApiResponse.ok("PIN-code mappings retrieved", geofenceService.listPincodes(false)));
    }

    @PostMapping("/pincodes/import")
    @Operation(summary = "Import verified PIN-code mapping")
    public ResponseEntity<ApiResponse<PincodeServiceabilityDto>> importPincode(
            @AuthenticationPrincipal UserPrincipal actor,
            @RequestBody ImportPincodeRequest request) {
        PincodeServiceabilityDto saved = geofenceService.importPincode(actor.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("PIN-code record imported", saved));
    }

    @PostMapping("/pincodes/{pincodeId}/review")
    @Operation(summary = "Verify, approve, or reject a PIN-code mapping")
    public ResponseEntity<ApiResponse<PincodeServiceabilityDto>> reviewPincode(
            @AuthenticationPrincipal UserPrincipal actor,
            @PathVariable UUID pincodeId,
            @RequestBody ReviewPincodeRequest request) {
        PincodeServiceabilityDto updated = geofenceService.reviewPincode(actor.getId(), pincodeId, request);
        return ResponseEntity.ok(ApiResponse.ok("PIN-code mapping updated", updated));
    }

    @GetMapping("/audit")
    @Operation(summary = "List immutable geofence audit logs")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAuditLogs(
            @RequestParam(required = false) UUID localityId) {
        return ResponseEntity.ok(ApiResponse.ok("Geofence audit logs retrieved", geofenceService.listAuditLogs(localityId)));
    }
}
