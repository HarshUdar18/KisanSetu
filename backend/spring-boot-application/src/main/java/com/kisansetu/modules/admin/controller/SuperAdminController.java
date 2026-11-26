package com.kisansetu.modules.admin.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.admin.dto.ProvisionSuperAdminRequest;
import com.kisansetu.modules.admin.dto.UserSummaryDto;
import com.kisansetu.modules.admin.service.SuperAdminProvisioningService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/super")
@Tag(name = "Super Admin Bootstrap", description = "One-time controlled Super Admin provisioning")
public class SuperAdminController {

    private final SuperAdminProvisioningService provisioningService;

    public SuperAdminController(SuperAdminProvisioningService provisioningService) {
        this.provisioningService = provisioningService;
    }

    @PostMapping("/provision")
    @Operation(summary = "Provision initial Super Admin using environment bootstrap secret")
    public ResponseEntity<ApiResponse<UserSummaryDto>> provision(@Valid @RequestBody ProvisionSuperAdminRequest request) {
        UserSummaryDto created = provisioningService.provisionSuperAdmin(
                request.getBootstrapSecret(),
                request.getPhone(),
                request.getPassword(),
                request.getEmail()
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Super Admin provisioned successfully", created));
    }
}
