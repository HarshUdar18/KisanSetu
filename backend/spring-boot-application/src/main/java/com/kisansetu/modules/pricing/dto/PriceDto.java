package com.kisansetu.modules.pricing.dto;

import com.kisansetu.modules.pricing.entity.MarketPrice;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public class PriceDto {

    private UUID productId;
    private String productName;
    private String unit;
    private BigDecimal currentPrice;
    private BigDecimal previousPrice;
    private Instant effectiveFrom;

    public PriceDto() {}

    public PriceDto(UUID productId, String productName, String unit, BigDecimal currentPrice, BigDecimal previousPrice, Instant effectiveFrom) {
        this.productId = productId;
        this.productName = productName;
        this.unit = unit;
        this.currentPrice = currentPrice;
        this.previousPrice = previousPrice;
        this.effectiveFrom = effectiveFrom;
    }

    public static PriceDto fromEntity(MarketPrice entity) {
        PriceDto dto = new PriceDto();
        if (entity.getProduct() != null) {
            dto.setProductId(entity.getProduct().getId());
            dto.setProductName(entity.getProduct().getName());
            dto.setUnit(entity.getProduct().getUnit());
        }
        dto.setCurrentPrice(entity.getCurrentPrice());
        dto.setPreviousPrice(entity.getPreviousPrice());
        dto.setEffectiveFrom(entity.getEffectiveFrom());
        return dto;
    }

    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public BigDecimal getCurrentPrice() { return currentPrice; }
    public void setCurrentPrice(BigDecimal currentPrice) { this.currentPrice = currentPrice; }

    public BigDecimal getPreviousPrice() { return previousPrice; }
    public void setPreviousPrice(BigDecimal previousPrice) { this.previousPrice = previousPrice; }

    public Instant getEffectiveFrom() { return effectiveFrom; }
    public void setEffectiveFrom(Instant effectiveFrom) { this.effectiveFrom = effectiveFrom; }
}
