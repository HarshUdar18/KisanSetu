package com.kisansetu.modules.customer.service;

import com.kisansetu.common.exception.ResourceNotFoundException;
import com.kisansetu.modules.customer.dto.CustomerProfileDto;
import com.kisansetu.modules.customer.dto.UpdateCustomerProfileRequest;
import com.kisansetu.modules.customer.entity.CustomerProfile;
import com.kisansetu.modules.customer.repository.CustomerProfileRepository;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

@Service
public class CustomerService {

    private final CustomerProfileRepository profileRepository;

    public CustomerService(CustomerProfileRepository profileRepository) {
        this.profileRepository = profileRepository;
    }

    @Transactional(readOnly = true)
    @Cacheable(value = "customerProfiles", key = "#userId")
    public CustomerProfileDto getProfileByUserId(UUID userId) {
        CustomerProfile profile = profileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("CustomerProfile", "userId", userId));
        return CustomerProfileDto.fromEntity(profile);
    }

    @Transactional
    @CacheEvict(value = "customerProfiles", key = "#userId")
    public CustomerProfileDto updateProfile(UUID userId, UpdateCustomerProfileRequest request) {
        CustomerProfile profile = profileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("CustomerProfile", "userId", userId));

        profile.setFullName(request.getFullName().trim());
        if (request.getDefaultDeliveryAddress() != null) {
            profile.setDefaultDeliveryAddress(request.getDefaultDeliveryAddress().trim());
        }
        if (request.getPincode() != null) {
            profile.setPincode(request.getPincode().trim());
        }
        if (request.getLatitude() != null) {
            profile.setLatitude(request.getLatitude());
        }
        if (request.getLongitude() != null) {
            profile.setLongitude(request.getLongitude());
        }

        CustomerProfile updated = profileRepository.save(profile);
        return CustomerProfileDto.fromEntity(updated);
    }

    public Map<String, Object> checkServiceability(String pincode) {
        // Standard baseline verification for customer phase 1 delivery routing
        boolean serviceable = pincode != null && pincode.matches("^[1-9][0-9]{5}$");
        return Map.of(
                "pincode", pincode != null ? pincode : "",
                "isServiceable", serviceable,
                "estimatedDeliveryHours", 24,
                "directFromFarmAvailable", true,
                "hubAssigned", serviceable ? "Central-Agri-Hub-01" : "None"
        );
    }
}
