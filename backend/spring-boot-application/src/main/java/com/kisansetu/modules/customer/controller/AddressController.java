package com.kisansetu.modules.customer.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.customer.dto.AddressDto;
import com.kisansetu.modules.customer.dto.CreateAddressRequest;
import com.kisansetu.modules.customer.service.AddressService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/addresses")
@Tag(name = "Customer Addresses", description = "Delivery address management with customer ownership isolation")
public class AddressController {

    private final AddressService addressService;

    public AddressController(AddressService addressService) {
        this.addressService = addressService;
    }

    @GetMapping
    @Operation(summary = "Get user delivery addresses")
    public ResponseEntity<ApiResponse<List<AddressDto>>> getAddresses(@AuthenticationPrincipal UserPrincipal principal) {
        List<AddressDto> addresses = addressService.getAddresses(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Addresses retrieved", addresses));
    }

    @PostMapping
    @Operation(summary = "Add new delivery address")
    public ResponseEntity<ApiResponse<AddressDto>> createAddress(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateAddressRequest request) {
        AddressDto address = addressService.createAddress(principal.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Address saved successfully", address));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update delivery address")
    public ResponseEntity<ApiResponse<AddressDto>> updateAddress(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @Valid @RequestBody CreateAddressRequest request) {
        AddressDto address = addressService.updateAddress(principal.getId(), id, request);
        return ResponseEntity.ok(ApiResponse.ok("Address updated successfully", address));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete delivery address")
    public ResponseEntity<ApiResponse<Void>> deleteAddress(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        addressService.deleteAddress(principal.getId(), id);
        return ResponseEntity.ok(ApiResponse.ok("Address deleted successfully", null));
    }

    @PostMapping("/{id}/default")
    @Operation(summary = "Mark address as default")
    public ResponseEntity<ApiResponse<AddressDto>> setDefaultAddress(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        AddressDto address = addressService.setDefaultAddress(principal.getId(), id);
        return ResponseEntity.ok(ApiResponse.ok("Default address updated", address));
    }
}
