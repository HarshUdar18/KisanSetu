package com.kisansetu.modules.farmer.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.kisansetu.modules.user.entity.User;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "farmer_farms")
public class FarmerFarm {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "farmer_id", nullable = false)
    private User farmer;

    @Column(name = "farm_name", nullable = false, length = 150)
    private String farmName;

    @Column(name = "address_line", columnDefinition = "TEXT")
    private String addressLine;

    @Column(length = 100)
    private String village;

    @Column(length = 100)
    private String taluka;

    @Column(length = 100)
    private String district;

    @Column(length = 100)
    private String state;

    @Column(length = 10)
    private String pincode;

    @Column(name = "formatted_address", columnDefinition = "TEXT")
    private String formattedAddress;

    @Column(precision = 10, scale = 7)
    private BigDecimal latitude;

    @Column(precision = 10, scale = 7)
    private BigDecimal longitude;

    @Column(name = "land_area", precision = 14, scale = 4)
    private BigDecimal landArea;

    @Column(name = "land_unit", length = 30)
    private String landUnit = "acre";

    @Column(name = "soil_type", length = 80)
    private String soilType;

    @Column(name = "irrigation_type", length = 80)
    private String irrigationType;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public User getFarmer() { return farmer; }
    public void setFarmer(User farmer) { this.farmer = farmer; }
    public String getFarmName() { return farmName; }
    public void setFarmName(String farmName) { this.farmName = farmName; }
    public String getAddressLine() { return addressLine; }
    public void setAddressLine(String addressLine) { this.addressLine = addressLine; }
    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }
    public String getTaluka() { return taluka; }
    public void setTaluka(String taluka) { this.taluka = taluka; }
    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    public String getPincode() { return pincode; }
    public void setPincode(String pincode) { this.pincode = pincode; }
    public String getFormattedAddress() { return formattedAddress; }
    public void setFormattedAddress(String formattedAddress) { this.formattedAddress = formattedAddress; }
    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }
    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }
    public BigDecimal getLandArea() { return landArea; }
    public void setLandArea(BigDecimal landArea) { this.landArea = landArea; }
    public String getLandUnit() { return landUnit; }
    public void setLandUnit(String landUnit) { this.landUnit = landUnit; }
    public String getSoilType() { return soilType; }
    public void setSoilType(String soilType) { this.soilType = soilType; }
    public String getIrrigationType() { return irrigationType; }
    public void setIrrigationType(String irrigationType) { this.irrigationType = irrigationType; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
