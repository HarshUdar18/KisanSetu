package com.kisansetu.modules.kyc.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.kyc.dto.KycSubmissionDto;
import com.kisansetu.modules.kyc.service.KycService;
import io.swagger.v3.oas.annotations.Operation;
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
@RequestMapping("/api/v1")
@Tag(name = "Farmer KYC", description = "Farmer KYC submission and admin verification workflow")
public class KycController {

    private final KycService kycService;

    public KycController(KycService kycService) {
        this.kycService = kycService;
    }

    @PostMapping("/kyc")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Submit KYC documents for verification")
    public ResponseEntity<ApiResponse<KycSubmissionDto>> submitKyc(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody Map<String, String> body) {
        KycSubmissionDto dto = kycService.submitKyc(
                principal.getId(),
                body.getOrDefault("documentType", "AADHAAR"),
                body.getOrDefault("documentNumber", "PENDING-DOC"),
                body.get("documentUrl"),
                body.get("selfieUrl"),
                body.get("bankAccountNumber"),
                body.get("ifscCode"),
                body.get("landRecordNumber")
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("KYC submitted for review", dto));
    }

    @GetMapping("/kyc/status")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    @Operation(summary = "Get current farmer KYC status")
    public ResponseEntity<ApiResponse<KycSubmissionDto>> getMyKycStatus(@AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.ok("KYC status retrieved", kycService.getStatus(principal.getId())));
    }

    @GetMapping("/admin/kyc")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "List KYC submissions for admin review")
    public ResponseEntity<ApiResponse<List<KycSubmissionDto>>> listKyc(@RequestParam(required = false) String status) {
        return ResponseEntity.ok(ApiResponse.ok("KYC submissions retrieved", kycService.listAll(status)));
    }

    @PutMapping("/admin/kyc/{id}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Approve a farmer KYC submission")
    public ResponseEntity<ApiResponse<KycSubmissionDto>> approveKyc(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) Map<String, String> body) {
        String remarks = body != null ? body.getOrDefault("remarks", "Approved by admin") : "Approved by admin";
        return ResponseEntity.ok(ApiResponse.ok("KYC approved", kycService.reviewKyc(id, principal.getId(), true, remarks)));
    }

    @PutMapping("/admin/kyc/{id}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Reject a farmer KYC submission")
    public ResponseEntity<ApiResponse<KycSubmissionDto>> rejectKyc(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) Map<String, String> body) {
        String remarks = body != null ? body.getOrDefault("remarks", "Rejected by admin") : "Rejected by admin";
        return ResponseEntity.ok(ApiResponse.ok("KYC rejected", kycService.reviewKyc(id, principal.getId(), false, remarks)));
    }
}
