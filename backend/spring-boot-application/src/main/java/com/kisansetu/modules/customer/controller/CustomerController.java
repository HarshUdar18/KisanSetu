package com.kisansetu.modules.customer.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.customer.dto.CustomerProfileDto;
import com.kisansetu.modules.customer.dto.UpdateCustomerProfileRequest;
import com.kisansetu.modules.customer.service.CustomerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/customer")
@Tag(name = "Customer", description = "Endpoints for Customer Phase 1 profile and shopping foundation")
@SecurityRequirement(name = "BearerAuth")
public class CustomerController {

    private final CustomerService customerService;

    public CustomerController(CustomerService customerService) {
        this.customerService = customerService;
    }

    @GetMapping("/profile")
    @PreAuthorize("hasRole('CUSTOMER') or hasRole('ADMIN')")
    @Operation(summary = "Get Customer Profile", description = "Retrieves the authenticated customer's profile and default address.")
    public ResponseEntity<ApiResponse<CustomerProfileDto>> getProfile(@AuthenticationPrincipal UserPrincipal currentUser) {
        CustomerProfileDto profile = customerService.getProfileByUserId(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.ok("Customer profile retrieved successfully", profile));
    }

    @PutMapping("/profile")
    @PreAuthorize("hasRole('CUSTOMER') or hasRole('ADMIN')")
    @Operation(summary = "Update Customer Profile", description = "Updates delivery details and customer contact information.")
    public ResponseEntity<ApiResponse<CustomerProfileDto>> updateProfile(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @Valid @RequestBody UpdateCustomerProfileRequest request) {
        CustomerProfileDto updated = customerService.updateProfile(currentUser.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok("Customer profile updated successfully", updated));
    }

    @GetMapping("/serviceability")
    @Operation(summary = "Check delivery serviceability", description = "Checks whether direct farm-to-table delivery is available for the given pincode.")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkServiceability(@RequestParam String pincode) {
        Map<String, Object> serviceability = customerService.checkServiceability(pincode);
        return ResponseEntity.ok(ApiResponse.ok("Serviceability details", serviceability));
    }
}
