package com.kisansetu.modules.farmer.dto;

import com.kisansetu.modules.farmer.entity.FarmerListing;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class FarmerListingDto {

    private UUID id;
    private UUID farmerId;
    private String farmerName;
    private UUID productId;
    private String productName;
    private String categoryName;
    private BigDecimal quantityAvailable;
    private String unit;
    private BigDecimal pricePerUnit;
    private LocalDate harvestDate;
    private String description;
    private String qualityGrade;
    private Boolean isAvailable;
    private String status;
    private Instant createdAt;
    private Instant updatedAt;

    public FarmerListingDto() {}

    public static FarmerListingDto fromEntity(FarmerListing entity, String farmerName) {
        FarmerListingDto dto = new FarmerListingDto();
        dto.setId(entity.getId());
        dto.setFarmerId(entity.getFarmer().getId());
        dto.setFarmerName(farmerName != null ? farmerName : "Farmer " + entity.getFarmer().getPhone());
        if (entity.getProduct() != null) {
            dto.setProductId(entity.getProduct().getId());
            dto.setProductName(entity.getProduct().getName());
            if (entity.getProduct().getCategory() != null) {
                dto.setCategoryName(entity.getProduct().getCategory().getName());
            }
        }
        dto.setQuantityAvailable(entity.getQuantityAvailable());
        dto.setUnit(entity.getUnit());
        dto.setPricePerUnit(entity.getPricePerUnit());
        dto.setHarvestDate(entity.getHarvestDate());
        dto.setDescription(entity.getDescription());
        dto.setQualityGrade(entity.getQualityGrade());
        dto.setIsAvailable(entity.getIsAvailable());
        dto.setStatus(entity.getStatus());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getFarmerId() { return farmerId; }
    public void setFarmerId(UUID farmerId) { this.farmerId = farmerId; }

    public String getFarmerName() { return farmerName; }
    public void setFarmerName(String farmerName) { this.farmerName = farmerName; }

    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public BigDecimal getQuantityAvailable() { return quantityAvailable; }
    public void setQuantityAvailable(BigDecimal quantityAvailable) { this.quantityAvailable = quantityAvailable; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public BigDecimal getPricePerUnit() { return pricePerUnit; }
    public void setPricePerUnit(BigDecimal pricePerUnit) { this.pricePerUnit = pricePerUnit; }

    public LocalDate getHarvestDate() { return harvestDate; }
    public void setHarvestDate(LocalDate harvestDate) { this.harvestDate = harvestDate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getQualityGrade() { return qualityGrade; }
    public void setQualityGrade(String qualityGrade) { this.qualityGrade = qualityGrade; }

    public Boolean getIsAvailable() { return isAvailable; }
    public void setIsAvailable(Boolean isAvailable) { this.isAvailable = isAvailable; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
