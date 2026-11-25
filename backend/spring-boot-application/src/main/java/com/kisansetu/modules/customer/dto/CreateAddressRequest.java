package com.kisansetu.modules.customer.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import java.math.BigDecimal;

public class CreateAddressRequest {

    private String label = "Home";

    @NotBlank(message = "Address line 1 is required")
    private String addressLine1;

    private String addressLine2;

    private String city = "Pune";

    private String state = "Maharashtra";

    @NotBlank(message = "Pincode is required")
    @Pattern(regexp = "^[1-9][0-9]{5}$", message = "Pincode must be a valid 6-digit Indian PIN code")
    private String pincode;

    private BigDecimal latitude;
    private BigDecimal longitude;
    private boolean isDefault = false;

    public CreateAddressRequest() {}

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }
    public String getAddressLine1() { return addressLine1; }
    public void setAddressLine1(String addressLine1) { this.addressLine1 = addressLine1; }
    public String getAddressLine2() { return addressLine2; }
    public void setAddressLine2(String addressLine2) { this.addressLine2 = addressLine2; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    public String getPincode() { return pincode; }
    public void setPincode(String pincode) { this.pincode = pincode; }
    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }
    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }
    public boolean isDefault() { return isDefault; }
    public void setDefault(boolean aDefault) { isDefault = aDefault; }
}
