package com.kisansetu.modules.hub.dto;

import com.kisansetu.modules.hub.entity.Hub;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public class HubDto {

    private UUID id;
    private String name;
    private String code;
    private String hubType;
    private String addressLine;
    private String village;
    private String district;
    private String state;
    private String pincode;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private String contactName;
    private String contactPhone;
    private String status;
    private UUID createdById;
    private Instant createdAt;
    private Instant updatedAt;

    public HubDto() {}

    public static HubDto fromEntity(Hub hub) {
        HubDto dto = new HubDto();
        dto.setId(hub.getId());
        dto.setName(hub.getName());
        dto.setCode(hub.getCode());
        dto.setHubType(hub.getHubType());
        dto.setAddressLine(hub.getAddressLine());
        dto.setVillage(hub.getVillage());
        dto.setDistrict(hub.getDistrict());
        dto.setState(hub.getState());
        dto.setPincode(hub.getPincode());
        dto.setLatitude(hub.getLatitude());
        dto.setLongitude(hub.getLongitude());
        dto.setContactName(hub.getContactName());
        dto.setContactPhone(hub.getContactPhone());
        dto.setStatus(hub.getStatus());
        dto.setCreatedById(hub.getCreatedBy() != null ? hub.getCreatedBy().getId() : null);
        dto.setCreatedAt(hub.getCreatedAt());
        dto.setUpdatedAt(hub.getUpdatedAt());
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getHubType() { return hubType; }
    public void setHubType(String hubType) { this.hubType = hubType; }

    public String getAddressLine() { return addressLine; }
    public void setAddressLine(String addressLine) { this.addressLine = addressLine; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getPincode() { return pincode; }
    public void setPincode(String pincode) { this.pincode = pincode; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public String getContactName() { return contactName; }
    public void setContactName(String contactName) { this.contactName = contactName; }

    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public UUID getCreatedById() { return createdById; }
    public void setCreatedById(UUID createdById) { this.createdById = createdById; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
