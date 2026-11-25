package com.kisansetu.modules.customer.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.customer.dto.AddressDto;
import com.kisansetu.modules.customer.dto.CreateAddressRequest;
import com.kisansetu.modules.customer.entity.Address;
import com.kisansetu.modules.customer.repository.AddressRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
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

    public AddressService(AddressRepository addressRepository, UserRepository userRepository) {
        this.addressRepository = addressRepository;
        this.userRepository = userRepository;
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
                .orElseThrow(() -> new ApiException("ADDRESS_NOT_FOUND", "Address not found or unauthorized", HttpStatus.NOT_FOUND));
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
                shouldBeDefault
        );

        Address saved = addressRepository.save(address);
        return AddressDto.fromEntity(saved);
    }

    @Transactional
    public AddressDto updateAddress(UUID userId, UUID addressId, CreateAddressRequest request) {
        Address address = addressRepository.findByIdAndUserId(addressId, userId)
                .orElseThrow(() -> new ApiException("ADDRESS_NOT_FOUND", "Address not found or unauthorized", HttpStatus.NOT_FOUND));

        address.setLabel(request.getLabel());
        address.setAddressLine1(request.getAddressLine1());
        address.setAddressLine2(request.getAddressLine2());
        address.setCity(request.getCity());
        address.setState(request.getState());
        address.setPincode(request.getPincode());
        address.setLatitude(request.getLatitude());
        address.setLongitude(request.getLongitude());

        if (request.isDefault() && !address.isDefault()) {
            List<Address> existing = addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId);
            existing.forEach(a -> a.setDefault(false));
            addressRepository.saveAll(existing);
            address.setDefault(true);
        }

        Address saved = addressRepository.save(address);
        return AddressDto.fromEntity(saved);
    }

    @Transactional
    public void deleteAddress(UUID userId, UUID addressId) {
        Address address = addressRepository.findByIdAndUserId(addressId, userId)
                .orElseThrow(() -> new ApiException("ADDRESS_NOT_FOUND", "Address not found or unauthorized", HttpStatus.NOT_FOUND));
        addressRepository.delete(address);
    }

    @Transactional
    public AddressDto setDefaultAddress(UUID userId, UUID addressId) {
        Address address = addressRepository.findByIdAndUserId(addressId, userId)
                .orElseThrow(() -> new ApiException("ADDRESS_NOT_FOUND", "Address not found or unauthorized", HttpStatus.NOT_FOUND));

        List<Address> existing = addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId);
        existing.forEach(a -> a.setDefault(false));
        addressRepository.saveAll(existing);

        address.setDefault(true);
        Address saved = addressRepository.save(address);
        return AddressDto.fromEntity(saved);
    }
}
