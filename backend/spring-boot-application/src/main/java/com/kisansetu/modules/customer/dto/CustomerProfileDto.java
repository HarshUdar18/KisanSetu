package com.kisansetu.modules.customer.dto;

import java.util.Set;
import java.util.UUID;

public class CustomerProfileDto {
    private UUID id;
    private String phone;
    private String email;
    private String fullName;
    private String defaultDeliveryAddress;
    private String pincode;
    private Set<String> roles;
    private String status;

    public CustomerProfileDto() {}

    public CustomerProfileDto(UUID id, String phone, String email, String fullName, String defaultDeliveryAddress, String pincode, Set<String> roles, String status) {
        this.id = id;
        this.phone = phone;
        this.email = email;
        this.fullName = fullName;
        this.defaultDeliveryAddress = defaultDeliveryAddress;
        this.pincode = pincode;
        this.roles = roles;
        this.status = status;
    }

    public static CustomerProfileDto fromEntity(com.kisansetu.modules.customer.entity.CustomerProfile profile) {
        CustomerProfileDto dto = new CustomerProfileDto();
        dto.setId(profile.getId());
        if (profile.getUser() != null) {
            dto.setPhone(profile.getUser().getPhone());
            dto.setEmail(profile.getUser().getEmail());
            dto.setStatus(profile.getUser().getStatus());
        }
        dto.setFullName(profile.getFullName());
        dto.setDefaultDeliveryAddress(profile.getDefaultDeliveryAddress());
        dto.setPincode(profile.getPincode());
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getDefaultDeliveryAddress() { return defaultDeliveryAddress; }
    public void setDefaultDeliveryAddress(String defaultDeliveryAddress) { this.defaultDeliveryAddress = defaultDeliveryAddress; }
    public String getPincode() { return pincode; }
    public void setPincode(String pincode) { this.pincode = pincode; }
    public Set<String> getRoles() { return roles; }
    public void setRoles(Set<String> roles) { this.roles = roles; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
