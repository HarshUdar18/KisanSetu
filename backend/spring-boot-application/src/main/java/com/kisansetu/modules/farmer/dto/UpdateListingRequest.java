package com.kisansetu.modules.farmer.dto;

import jakarta.validation.constraints.DecimalMin;
import java.math.BigDecimal;
import java.time.LocalDate;

public class UpdateListingRequest {

    @DecimalMin(value = "0.00", message = "Quantity cannot be negative")
    private BigDecimal quantityAvailable;

    private String unit;

    @DecimalMin(value = "0.01", message = "Price per unit must be greater than zero")
    private BigDecimal pricePerUnit;

    private LocalDate harvestDate;

    private String description;

    private String qualityGrade;

    private Boolean isAvailable;

    public UpdateListingRequest() {}

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
}
