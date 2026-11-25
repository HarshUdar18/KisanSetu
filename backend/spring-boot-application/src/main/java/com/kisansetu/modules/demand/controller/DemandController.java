package com.kisansetu.modules.demand.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.demand.dto.DemandDto;
import com.kisansetu.modules.demand.service.DemandService;
import io.swagger.v3.oas.annotations.Operation;
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
@RequestMapping("/api/v1/demands")
@Tag(name = "Produce Demands", description = "Buyer/Cluster demand requests and farmer acceptances")
public class DemandController {

    private final DemandService demandService;

    public DemandController(DemandService demandService) {
        this.demandService = demandService;
    }

    @GetMapping
    @Operation(summary = "List demand requests")
    public ResponseEntity<ApiResponse<List<DemandDto>>> listDemands(@RequestParam(required = false) String status) {
        return ResponseEntity.ok(ApiResponse.ok("Demands retrieved", demandService.listDemands(status)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get demand request details")
    public ResponseEntity<ApiResponse<DemandDto>> getDemand(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Demand retrieved", demandService.getDemand(id)));
    }

    @PostMapping
    @Operation(summary = "Create a new produce demand request")
    public ResponseEntity<ApiResponse<DemandDto>> createDemand(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody Map<String, Object> body) {
        UUID productId = UUID.fromString(body.get("productId").toString());
        BigDecimal quantityKg = new BigDecimal(body.get("quantityKg").toString());
        BigDecimal targetPrice = new BigDecimal(body.get("targetPricePerKg").toString());
        LocalDate requiredBy = body.get("requiredByDate") != null
                ? LocalDate.parse(body.get("requiredByDate").toString())
                : LocalDate.now().plusDays(3);
        String notes = body.get("notes") != null ? body.get("notes").toString() : null;

        DemandDto dto = demandService.createDemand(principal.getId(), productId, quantityKg, targetPrice, requiredBy, notes);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Demand created", dto));
    }

    @PutMapping("/{id}/accept")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Accept a demand request as a farmer")
    public ResponseEntity<ApiResponse<DemandDto>> acceptDemand(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) Map<String, Object> body) {
        BigDecimal offeredPrice = (body != null && body.get("offeredPricePerKg") != null)
                ? new BigDecimal(body.get("offeredPricePerKg").toString()) : null;
        BigDecimal confirmedQty = (body != null && body.get("confirmedQuantityKg") != null)
                ? new BigDecimal(body.get("confirmedQuantityKg").toString()) : null;
        return ResponseEntity.ok(ApiResponse.ok("Demand accepted",
                demandService.acceptDemand(id, principal.getId(), offeredPrice, confirmedQty)));
    }
}
