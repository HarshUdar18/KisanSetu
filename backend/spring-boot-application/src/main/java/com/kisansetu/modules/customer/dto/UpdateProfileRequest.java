package com.kisansetu.modules.customer.dto;

public class UpdateProfileRequest {
    private String fullName;
    private String email;
    private String defaultDeliveryAddress;
    private String pincode;

    public UpdateProfileRequest() {}

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getDefaultDeliveryAddress() { return defaultDeliveryAddress; }
    public void setDefaultDeliveryAddress(String defaultDeliveryAddress) { this.defaultDeliveryAddress = defaultDeliveryAddress; }
    public String getPincode() { return pincode; }
    public void setPincode(String pincode) { this.pincode = pincode; }
}
