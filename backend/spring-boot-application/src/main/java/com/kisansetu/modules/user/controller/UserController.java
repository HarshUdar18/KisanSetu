package com.kisansetu.modules.user.controller;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.customer.dto.CustomerProfileDto;
import com.kisansetu.modules.customer.dto.UpdateProfileRequest;
import com.kisansetu.modules.customer.entity.CustomerProfile;
import com.kisansetu.modules.customer.repository.CustomerProfileRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "Users", description = "Current user profile and roles")
@SecurityRequirement(name = "BearerAuth")
public class UserController {

    private final UserRepository userRepository;
    private final CustomerProfileRepository customerProfileRepository;
    private final com.kisansetu.modules.farmer.repository.FarmerProfileRepository farmerProfileRepository;

    public UserController(
            UserRepository userRepository,
            CustomerProfileRepository customerProfileRepository,
            com.kisansetu.modules.farmer.repository.FarmerProfileRepository farmerProfileRepository) {
        this.userRepository = userRepository;
        this.customerProfileRepository = customerProfileRepository;
        this.farmerProfileRepository = farmerProfileRepository;
    }

    @GetMapping("/me")
    @Operation(summary = "Get current authenticated user profile", description = "Returns the user ID, phone, email, full name, and roles.")
    public ResponseEntity<ApiResponse<CustomerProfileDto>> getCurrentUser(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        User user = userRepository.findById(userPrincipal.getId())
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "User not found", HttpStatus.NOT_FOUND));

        CustomerProfile customerProfile = customerProfileRepository.findByUserId(user.getId()).orElse(null);
        com.kisansetu.modules.farmer.entity.FarmerProfile farmerProfile = null;
        if (customerProfile == null) {
            farmerProfile = farmerProfileRepository.findByUserId(user.getId()).orElse(null);
        }

        String fullName;
        String address = null;
        String pincode = null;

        if (customerProfile != null) {
            fullName = customerProfile.getFullName();
            address = customerProfile.getDefaultDeliveryAddress();
            pincode = customerProfile.getPincode();
        } else if (farmerProfile != null) {
            fullName = farmerProfile.getFullName();
            address = String.format("%s, %s, %s", 
                    farmerProfile.getVillage() != null ? farmerProfile.getVillage() : "",
                    farmerProfile.getDistrict() != null ? farmerProfile.getDistrict() : "",
                    farmerProfile.getState() != null ? farmerProfile.getState() : "").replaceAll("^, |, $", "").trim();
            pincode = farmerProfile.getPincode();
        } else {
            fullName = user.getPhone();
        }

        CustomerProfileDto dto = new CustomerProfileDto(
                user.getId(),
                user.getPhone(),
                user.getEmail(),
                fullName,
                address,
                pincode,
                userPrincipal.getRoles(),
                user.getStatus()
        );

        return ResponseEntity.ok(ApiResponse.ok("User profile retrieved", dto));
    }

    @PutMapping("/me")
    @Operation(summary = "Update current user profile")
    public ResponseEntity<ApiResponse<CustomerProfileDto>> updateCurrentUser(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestBody UpdateProfileRequest request) {
        User user = userRepository.findById(userPrincipal.getId())
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "User not found", HttpStatus.NOT_FOUND));

        if (request.getEmail() != null && !request.getEmail().trim().isEmpty()) {
            user.setEmail(request.getEmail().trim());
            userRepository.save(user);
        }

        CustomerProfile profile = customerProfileRepository.findByUserId(user.getId()).orElse(null);
        if (profile == null) {
            profile = new CustomerProfile(user, request.getFullName(), request.getDefaultDeliveryAddress(), request.getPincode());
        } else {
            if (request.getFullName() != null) profile.setFullName(request.getFullName());
            if (request.getDefaultDeliveryAddress() != null) profile.setDefaultDeliveryAddress(request.getDefaultDeliveryAddress());
            if (request.getPincode() != null) profile.setPincode(request.getPincode());
        }
        customerProfileRepository.save(profile);

        CustomerProfileDto dto = new CustomerProfileDto(
                user.getId(),
                user.getPhone(),
                user.getEmail(),
                profile.getFullName(),
                profile.getDefaultDeliveryAddress(),
                profile.getPincode(),
                userPrincipal.getRoles(),
                user.getStatus()
        );

        return ResponseEntity.ok(ApiResponse.ok("Profile updated successfully", dto));
    }
}
