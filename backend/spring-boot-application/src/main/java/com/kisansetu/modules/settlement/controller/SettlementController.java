package com.kisansetu.modules.settlement.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.settlement.dto.SettlementDto;
import com.kisansetu.modules.settlement.service.SettlementServiceImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Farmer Settlements", description = "Farmer DBT payouts and admin finance authorization")
public class SettlementController {

    private final SettlementServiceImpl settlementService;

    public SettlementController(SettlementServiceImpl settlementService) {
        this.settlementService = settlementService;
    }

    @GetMapping("/settlements")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Get settlements for authenticated farmer")
    public ResponseEntity<ApiResponse<List<SettlementDto>>> getMySettlements(@AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.ok("Settlements retrieved", settlementService.getFarmerSettlements(principal.getId())));
    }

    @GetMapping("/settlements/{id}")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Get settlement details by ID")
    public ResponseEntity<ApiResponse<SettlementDto>> getSettlement(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Settlement retrieved", settlementService.getSettlement(id)));
    }

    @GetMapping("/admin/settlements")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "List all farmer settlements for admin finance review")
    public ResponseEntity<ApiResponse<List<SettlementDto>>> listAllSettlements() {
        return ResponseEntity.ok(ApiResponse.ok("All settlements retrieved", settlementService.getAllSettlements()));
    }

    @PostMapping("/admin/settlements/{id}/authorize")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Authorize farmer settlement for DBT payout")
    public ResponseEntity<ApiResponse<SettlementDto>> authorizeSettlement(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) Map<String, String> body) {
        String remarks = body != null ? body.get("remarks") : null;
        return ResponseEntity.ok(ApiResponse.ok("Settlement authorized for DBT",
                settlementService.authorizeSettlement(id, principal.getId(), remarks)));
    }
}
