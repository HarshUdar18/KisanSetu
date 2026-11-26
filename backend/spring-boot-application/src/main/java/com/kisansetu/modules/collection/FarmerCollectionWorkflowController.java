package com.kisansetu.modules.collection;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "Farmer Collection & Warehouse Traceability", description = "Collection point assignment, collection requests, quality inspection, and warehouse transfers")
public class FarmerCollectionWorkflowController {

    private final FarmerCollectionWorkflowService workflowService;

    public FarmerCollectionWorkflowController(FarmerCollectionWorkflowService workflowService) {
        this.workflowService = workflowService;
    }

    @GetMapping("/farmer/collection-point")
    @PreAuthorize("hasAnyRole('FARMER', 'ADMIN')")
    @Operation(summary = "Get farmer's active assigned collection point")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getAssignedCollectionPoint(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.ok("Assigned collection point retrieved",
                workflowService.getAssignedCollectionPoint(principal.getId())));
    }

    @PostMapping("/farmer/collection-point/assign")
    @PreAuthorize("hasAnyRole('FARMER', 'ADMIN')")
    @Operation(summary = "Assign nearest eligible or selected active collection point to farmer")
    public ResponseEntity<ApiResponse<Map<String, Object>>> assignCollectionPoint(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody Map<String, Object> body) {
        UUID hubId = body.get("hubId") != null ? UUID.fromString(body.get("hubId").toString()) : null;
        Double lat = body.get("latitude") != null ? Double.valueOf(body.get("latitude").toString()) : null;
        Double lon = body.get("longitude") != null ? Double.valueOf(body.get("longitude").toString()) : null;
        return ResponseEntity.ok(ApiResponse.ok("Collection point assigned",
                workflowService.assignCollectionPoint(principal.getId(), hubId, lat, lon, principal.getId(), "Farmer selection")));
    }

    @PutMapping("/admin/farmers/{farmerId}/collection-point")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Admin reassign farmer collection point")
    public ResponseEntity<ApiResponse<Map<String, Object>>> adminReassign(
            @AuthenticationPrincipal UserPrincipal admin,
            @PathVariable UUID farmerId,
            @RequestBody Map<String, Object> body) {
        UUID hubId = UUID.fromString(body.get("hubId").toString());
        String reason = body.get("reason") != null ? body.get("reason").toString() : "Admin reassignment";
        return ResponseEntity.ok(ApiResponse.ok("Farmer collection point reassigned",
                workflowService.assignCollectionPoint(farmerId, hubId, null, null, admin.getId(), reason)));
    }

    @PostMapping("/farmer/collection-requests")
    @PreAuthorize("hasAnyRole('FARMER', 'ADMIN')")
    @Operation(summary = "Create persistent collection request from a published farmer listing")
    public ResponseEntity<ApiResponse<Map<String, Object>>> createCollectionRequest(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody Map<String, Object> body) {
        UUID listingId = body.get("listingId") != null ? UUID.fromString(body.get("listingId").toString()) : null;
        UUID productId = body.get("productId") != null ? UUID.fromString(body.get("productId").toString()) : null;
        UUID hubId = UUID.fromString(body.get("hubId").toString());
        BigDecimal qty = new BigDecimal(body.get("quantityKg").toString());
        LocalDate date = body.get("scheduledDate") != null ? LocalDate.parse(body.get("scheduledDate").toString()) : null;
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Collection request created",
                workflowService.createCollectionRequest(principal.getId(), listingId, productId, hubId, qty, date)));
    }

    @PostMapping("/collection-points/collections/{collectionId}/inspect")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'COLLECTION_OPERATOR', 'QUALITY')")
    @Operation(summary = "Record collection point receipt and quality inspection")
    public ResponseEntity<ApiResponse<Map<String, Object>>> inspectCollection(
            @AuthenticationPrincipal UserPrincipal operator,
            @PathVariable UUID collectionId,
            @RequestBody Map<String, Object> body) {
        BigDecimal receivedKg = new BigDecimal(body.get("receivedKg").toString());
        BigDecimal acceptedKg = new BigDecimal(body.get("acceptedKg").toString());
        BigDecimal rejectedKg = body.get("rejectedKg") != null ? new BigDecimal(body.get("rejectedKg").toString()) : null;
        String grade = body.get("grade") != null ? body.get("grade").toString() : "A";
        String remarks = body.get("remarks") != null ? body.get("remarks").toString() : null;
        String rejectionReason = body.get("rejectionReason") != null ? body.get("rejectionReason").toString() : null;
        return ResponseEntity.ok(ApiResponse.ok("Quality inspection recorded",
                workflowService.recordInspection(operator.getId(), collectionId, receivedKg, acceptedKg, rejectedKg, grade, remarks, rejectionReason)));
    }

    @PostMapping("/collection-points/collections/{collectionId}/transfer")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'COLLECTION_OPERATOR')")
    @Operation(summary = "Dispatch inspected produce from collection point to warehouse")
    public ResponseEntity<ApiResponse<Map<String, Object>>> dispatchTransfer(
            @AuthenticationPrincipal UserPrincipal operator,
            @PathVariable UUID collectionId,
            @RequestBody Map<String, Object> body) {
        UUID warehouseId = UUID.fromString(body.get("destinationWarehouseId").toString());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Stock transfer dispatched",
                workflowService.createStockTransfer(operator.getId(), collectionId, warehouseId)));
    }

    @PostMapping("/warehouses/transfers/{transferId}/receive")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'WAREHOUSE_OPERATOR')")
    @Operation(summary = "Confirm warehouse receipt and atomically update inventory")
    public ResponseEntity<ApiResponse<Map<String, Object>>> receiveTransfer(
            @AuthenticationPrincipal UserPrincipal operator,
            @PathVariable UUID transferId,
            @RequestBody Map<String, Object> body) {
        BigDecimal receivedKg = new BigDecimal(body.get("receivedKg").toString());
        return ResponseEntity.ok(ApiResponse.ok("Warehouse receipt confirmed and inventory updated",
                workflowService.confirmWarehouseReceipt(operator.getId(), transferId, receivedKg)));
    }

    @GetMapping("/farmer/transfers")
    @PreAuthorize("hasAnyRole('FARMER', 'ADMIN')")
    @Operation(summary = "List authenticated farmer's stock transfers")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> listFarmerTransfers(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.ok("Farmer stock transfers retrieved",
                workflowService.listFarmerTransfers(principal.getId())));
    }
}
