package com.kisansetu.modules.cart.dto;

import java.math.BigDecimal;
import java.util.UUID;

public class WeeklyCartItemDto {
    private UUID id;
    private UUID productId;
    private String productName;
    private String marathiName;
    private String unit;
    private String imageUrl;
    private BigDecimal quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;

    public WeeklyCartItemDto() {}

    public WeeklyCartItemDto(UUID id, UUID productId, String productName, String marathiName, String unit, String imageUrl, BigDecimal quantity, BigDecimal unitPrice, BigDecimal totalPrice) {
        this.id = id;
        this.productId = productId;
        this.productName = productName;
        this.marathiName = marathiName;
        this.unit = unit;
        this.imageUrl = imageUrl;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalPrice = totalPrice;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getMarathiName() { return marathiName; }
    public void setMarathiName(String marathiName) { this.marathiName = marathiName; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }
}
