package com.kisansetu.modules.subscription.dto;

import java.math.BigDecimal;
import java.util.UUID;

public class SubscriptionItemDto {
    private UUID id;
    private UUID productId;
    private String productName;
    private String unit;
    private String dayOfWeek;
    private BigDecimal quantity;
    private BigDecimal currentPrice;

    public SubscriptionItemDto() {}

    public SubscriptionItemDto(UUID id, UUID productId, String productName, String unit, String dayOfWeek, BigDecimal quantity, BigDecimal currentPrice) {
        this.id = id;
        this.productId = productId;
        this.productName = productName;
        this.unit = unit;
        this.dayOfWeek = dayOfWeek;
        this.quantity = quantity;
        this.currentPrice = currentPrice;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }
    public BigDecimal getCurrentPrice() { return currentPrice; }
    public void setCurrentPrice(BigDecimal currentPrice) { this.currentPrice = currentPrice; }
}
