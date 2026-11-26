package com.kisansetu.modules.farmer.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.kisansetu.modules.user.entity.User;
import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "farmer_profiles")
public class FarmerProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @JsonIgnore
    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @Column(length = 100)
    private String village;

    @Column(length = 100)
    private String district;

    @Column(length = 100)
    private String state;

    @Column(length = 10)
    private String pincode;

    @Column(name = "primary_crop_category", length = 100)
    private String primaryCropCategory;

    @Column(name = "farm_name", length = 150)
    private String farmName;

    @Column(name = "land_area", precision = 10, scale = 2)
    private java.math.BigDecimal landArea;

    @Column(name = "land_unit", length = 20)
    private String landUnit = "Acres";

    @Column(name = "soil_type", length = 60)
    private String soilType;

    @Column(name = "irrigation_type", length = 60)
    private String irrigationType;

    @Column(name = "farming_experience_years")
    private Integer farmingExperienceYears;

    @Column(precision = 10, scale = 7)
    private java.math.BigDecimal latitude;

    @Column(precision = 10, scale = 7)
    private java.math.BigDecimal longitude;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public FarmerProfile() {}

    public FarmerProfile(User user, String fullName, String village, String district, String state, String pincode, String primaryCropCategory) {
        this.user = user;
        this.fullName = fullName;
        this.village = village;
        this.district = district;
        this.state = state;
        this.pincode = pincode;
        this.primaryCropCategory = primaryCropCategory;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = Instant.now();
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getVillage() {
        return village;
    }

    public void setVillage(String village) {
        this.village = village;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getPincode() {
        return pincode;
    }

    public void setPincode(String pincode) {
        this.pincode = pincode;
    }

    public String getPrimaryCropCategory() {
        return primaryCropCategory;
    }

    public void setPrimaryCropCategory(String primaryCropCategory) {
        this.primaryCropCategory = primaryCropCategory;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getFarmName() { return farmName; }
    public void setFarmName(String farmName) { this.farmName = farmName; }
    public java.math.BigDecimal getLandArea() { return landArea; }
    public void setLandArea(java.math.BigDecimal landArea) { this.landArea = landArea; }
    public String getLandUnit() { return landUnit; }
    public void setLandUnit(String landUnit) { this.landUnit = landUnit; }
    public String getSoilType() { return soilType; }
    public void setSoilType(String soilType) { this.soilType = soilType; }
    public String getIrrigationType() { return irrigationType; }
    public void setIrrigationType(String irrigationType) { this.irrigationType = irrigationType; }
    public Integer getFarmingExperienceYears() { return farmingExperienceYears; }
    public void setFarmingExperienceYears(Integer farmingExperienceYears) { this.farmingExperienceYears = farmingExperienceYears; }
    public java.math.BigDecimal getLatitude() { return latitude; }
    public void setLatitude(java.math.BigDecimal latitude) { this.latitude = latitude; }
    public java.math.BigDecimal getLongitude() { return longitude; }
    public void setLongitude(java.math.BigDecimal longitude) { this.longitude = longitude; }
}
