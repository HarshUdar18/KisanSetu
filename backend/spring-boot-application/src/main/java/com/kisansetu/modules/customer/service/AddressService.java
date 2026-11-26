package com.kisansetu.modules.customer.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.customer.dto.AddressDto;
import com.kisansetu.modules.customer.dto.CreateAddressRequest;
import com.kisansetu.modules.customer.entity.Address;
import com.kisansetu.modules.customer.repository.AddressRepository;
import com.kisansetu.modules.customer.repository.CustomerProfileRepository;
import com.kisansetu.modules.location.spatial.SpatialLocationService;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class AddressService {

    private final AddressRepository addressRepository;
    private final UserRepository userRepository;
    private final SpatialLocationService spatialLocationService;
    private final CustomerProfileRepository customerProfileRepository;

    @Autowired
    public AddressService(AddressRepository addressRepository, UserRepository userRepository,
            SpatialLocationService spatialLocationService,
            CustomerProfileRepository customerProfileRepository) {
        this.addressRepository = addressRepository;
        this.userRepository = userRepository;
        this.spatialLocationService = spatialLocationService;
        this.customerProfileRepository = customerProfileRepository;
    }

    public AddressService(AddressRepository addressRepository, UserRepository userRepository,
            SpatialLocationService spatialLocationService) {
        this(addressRepository, userRepository, spatialLocationService, null);
    }

    @Transactional(readOnly = true)
    public List<AddressDto> getAddresses(UUID userId) {
        return addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId)
                .stream()
                .map(AddressDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public AddressDto getAddress(UUID userId, UUID addressId) {
        Address address = addressRepository.findByIdAndUserId(addressId, userId)
                .orElseThrow(() -> new ApiException("ADDRESS_NOT_FOUND", "Address not found or unauthorized",
                        HttpStatus.NOT_FOUND));
        return AddressDto.fromEntity(address);
    }

    @Transactional
    public AddressDto createAddress(UUID userId, CreateAddressRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "User not found", HttpStatus.NOT_FOUND));

        List<Address> existing = addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId);
        boolean isFirst = existing.isEmpty();
        boolean shouldBeDefault = request.isDefault() || isFirst;

        if (shouldBeDefault && !existing.isEmpty()) {
            existing.forEach(a -> a.setDefault(false));
            addressRepository.saveAll(existing);
        }

        Address address = new Address(
                user,
                request.getLabel(),
                request.getAddressLine1(),
                request.getAddressLine2(),
                request.getCity(),
                request.getState(),
                request.getPincode(),
                request.getLatitude(),
                request.getLongitude(),
                shouldBeDefault);
        applyRecipientAndDetails(address, request);

        Address saved = addressRepository.saveAndFlush(address);
        spatialLocationService.syncAddressLocation(
                saved.getId(),
                saved.getLatitude() != null ? saved.getLatitude().doubleValue() : null,
                saved.getLongitude() != null ? saved.getLongitude().doubleValue() : null);
        if (saved.isDefault()) {
            syncCustomerProfileDefault(userId, saved);
        }
        return AddressDto.fromEntity(saved);
    }

    @Transactional
    public AddressDto updateAddress(UUID userId, UUID addressId, CreateAddressRequest request) {
        Address address = addressRepository.findByIdAndUserId(addressId, userId)
                .orElseThrow(() -> new ApiException("ADDRESS_NOT_FOUND", "Address not found or unauthorized",
                        HttpStatus.NOT_FOUND));

        address.setLabel(request.getLabel());
        address.setAddressLine1(request.getAddressLine1());
        address.setAddressLine2(request.getAddressLine2());
        address.setCity(request.getCity());
        address.setState(request.getState());
        address.setPincode(request.getPincode());
        address.setLatitude(request.getLatitude());
        address.setLongitude(request.getLongitude());
        applyRecipientAndDetails(address, request);

        if (request.isDefault() && !address.isDefault()) {
            List<Address> existing = addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId);
            existing.forEach(a -> a.setDefault(false));
            addressRepository.saveAll(existing);
            address.setDefault(true);
        }

        Address saved = addressRepository.saveAndFlush(address);
        spatialLocationService.syncAddressLocation(
                saved.getId(),
                saved.getLatitude() != null ? saved.getLatitude().doubleValue() : null,
                saved.getLongitude() != null ? saved.getLongitude().doubleValue() : null);
        if (saved.isDefault()) {
            syncCustomerProfileDefault(userId, saved);
        }
        return AddressDto.fromEntity(saved);
    }

    @Transactional
    public void deleteAddress(UUID userId, UUID addressId) {
        Address address = addressRepository.findByIdAndUserId(addressId, userId)
                .orElseThrow(() -> new ApiException("ADDRESS_NOT_FOUND", "Address not found or unauthorized",
                        HttpStatus.NOT_FOUND));
        addressRepository.delete(address);
    }

    @Transactional
    public AddressDto setDefaultAddress(UUID userId, UUID addressId) {
        Address address = addressRepository.findByIdAndUserId(addressId, userId)
                .orElseThrow(() -> new ApiException("ADDRESS_NOT_FOUND", "Address not found or unauthorized",
                        HttpStatus.NOT_FOUND));

        List<Address> existing = addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId);
        existing.forEach(a -> a.setDefault(false));
        addressRepository.saveAll(existing);

        address.setDefault(true);
        Address saved = addressRepository.saveAndFlush(address);
        spatialLocationService.syncAddressLocation(
                saved.getId(),
                saved.getLatitude() != null ? saved.getLatitude().doubleValue() : null,
                saved.getLongitude() != null ? saved.getLongitude().doubleValue() : null);
        if (saved.isDefault()) {
            syncCustomerProfileDefault(userId, saved);
        }
        return AddressDto.fromEntity(saved);
    }

    private void syncCustomerProfileDefault(UUID userId, Address saved) {
        if (customerProfileRepository == null) return;
        customerProfileRepository.findByUserId(userId).ifPresent(profile -> {
            String full = saved.getAddressLine1()
                    + (saved.getAddressLine2() != null && !saved.getAddressLine2().isBlank() ? ", " + saved.getAddressLine2() : "")
                    + ", " + saved.getCity() + ", " + saved.getState() + " - " + saved.getPincode();
            profile.setDefaultDeliveryAddress(full);
            profile.setPincode(saved.getPincode());
            if (saved.getLatitude() != null) profile.setLatitude(saved.getLatitude());
            if (saved.getLongitude() != null) profile.setLongitude(saved.getLongitude());
            customerProfileRepository.save(profile);
        });
    }

    private void applyRecipientAndDetails(Address address, CreateAddressRequest request) {
        String type = request.getRecipientType() != null && !request.getRecipientType().isBlank()
                ? request.getRecipientType().trim().toUpperCase()
                : "MYSELF";
        if (!"MYSELF".equals(type) && !"SOMEONE_ELSE".equals(type)) {
            throw new ApiException("INVALID_RECIPIENT_TYPE", "Recipient type must be MYSELF or SOMEONE_ELSE",
                    HttpStatus.BAD_REQUEST);
        }
        address.setRecipientType(type);
        address.setRecipientFirstName(trimToNull(request.getRecipientFirstName()));
        address.setRecipientLastName(trimToNull(request.getRecipientLastName()));
        String phone = trimToNull(request.getRecipientPhone());
        if (phone != null) {
            String digits = phone.replaceAll("\\D", "");
            if (digits.length() < 10 || digits.length() > 15) {
                throw new ApiException("INVALID_RECIPIENT_PHONE", "Please provide a valid mobile number",
                        HttpStatus.BAD_REQUEST);
            }
        }
        address.setRecipientPhone(phone);
        address.setStreetBuilding(trimToNull(request.getStreetBuilding()));
        address.setLandmark(trimToNull(request.getLandmark()));
        address.setLocationSummary(trimToNull(request.getLocationSummary()));
    }

    private String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
