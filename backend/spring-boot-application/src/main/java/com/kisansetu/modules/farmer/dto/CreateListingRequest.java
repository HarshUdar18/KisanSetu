package com.kisansetu.modules.farmer.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public class CreateListingRequest {

    @NotNull(message = "Product ID is required")
    private UUID productId;

    @NotNull(message = "Quantity available is required")
    @DecimalMin(value = "0.01", message = "Quantity must be greater than zero")
    private BigDecimal quantityAvailable;

    private String unit;

    @NotNull(message = "Price per unit is required")
    @DecimalMin(value = "0.01", message = "Price per unit must be greater than zero")
    private BigDecimal pricePerUnit;

    private LocalDate harvestDate;

    private String description;

    private String qualityGrade; // e.g. GRADE_A, GRADE_B

    public CreateListingRequest() {}

    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }

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
}
