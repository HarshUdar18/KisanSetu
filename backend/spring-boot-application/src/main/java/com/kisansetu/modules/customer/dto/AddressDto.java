package com.kisansetu.modules.customer.dto;

import com.kisansetu.modules.customer.entity.Address;
import java.math.BigDecimal;
import java.util.UUID;

public class AddressDto {
    private UUID id;
    private String label;
    private String addressLine1;
    private String addressLine2;
    private String city;
    private String state;
    private String pincode;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private boolean isDefault;
    private String recipientType;
    private String recipientFirstName;
    private String recipientLastName;
    private String recipientPhone;
    private String streetBuilding;
    private String landmark;
    private String locationSummary;

    public AddressDto() {}

    public static AddressDto fromEntity(Address address) {
        AddressDto dto = new AddressDto();
        dto.setId(address.getId());
        dto.setLabel(address.getLabel());
        dto.setAddressLine1(address.getAddressLine1());
        dto.setAddressLine2(address.getAddressLine2());
        dto.setCity(address.getCity());
        dto.setState(address.getState());
        dto.setPincode(address.getPincode());
        dto.setLatitude(address.getLatitude());
        dto.setLongitude(address.getLongitude());
        dto.setDefault(address.isDefault());
        dto.setRecipientType(address.getRecipientType());
        dto.setRecipientFirstName(address.getRecipientFirstName());
        dto.setRecipientLastName(address.getRecipientLastName());
        dto.setRecipientPhone(address.getRecipientPhone());
        dto.setStreetBuilding(address.getStreetBuilding());
        dto.setLandmark(address.getLandmark());
        dto.setLocationSummary(address.getLocationSummary());
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
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
    public String getRecipientType() { return recipientType; }
    public void setRecipientType(String recipientType) { this.recipientType = recipientType; }
    public String getRecipientFirstName() { return recipientFirstName; }
    public void setRecipientFirstName(String recipientFirstName) { this.recipientFirstName = recipientFirstName; }
    public String getRecipientLastName() { return recipientLastName; }
    public void setRecipientLastName(String recipientLastName) { this.recipientLastName = recipientLastName; }
    public String getRecipientPhone() { return recipientPhone; }
    public void setRecipientPhone(String recipientPhone) { this.recipientPhone = recipientPhone; }
    public String getStreetBuilding() { return streetBuilding; }
    public void setStreetBuilding(String streetBuilding) { this.streetBuilding = streetBuilding; }
    public String getLandmark() { return landmark; }
    public void setLandmark(String landmark) { this.landmark = landmark; }
    public String getLocationSummary() { return locationSummary; }
    public void setLocationSummary(String locationSummary) { this.locationSummary = locationSummary; }
}
