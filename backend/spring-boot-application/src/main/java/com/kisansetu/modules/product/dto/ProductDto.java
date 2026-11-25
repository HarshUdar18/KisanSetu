package com.kisansetu.modules.product.dto;

import com.kisansetu.modules.product.entity.Product;
import java.math.BigDecimal;
import java.util.UUID;

public class ProductDto {
    private UUID id;
    private UUID categoryId;
    private String categoryName;
    private String name;
    private String marathiName;
    private String description;
    private String unit;
    private String imageUrl;
    private boolean isAvailable;
    private BigDecimal currentPrice;
    private BigDecimal previousPrice;
    private BigDecimal stockQuantity;

    public ProductDto() {}

    public static ProductDto fromEntity(Product product, BigDecimal currentPrice, BigDecimal previousPrice) {
        ProductDto dto = new ProductDto();
        dto.setId(product.getId());
        if (product.getCategory() != null) {
            dto.setCategoryId(product.getCategory().getId());
            dto.setCategoryName(product.getCategory().getName());
        }
        dto.setName(product.getName());
        dto.setMarathiName(product.getMarathiName());
        dto.setDescription(product.getDescription());
        dto.setUnit(product.getUnit());
        dto.setImageUrl(product.getImageUrl());
        dto.setAvailable(product.isAvailable());
        dto.setCurrentPrice(currentPrice != null ? currentPrice : BigDecimal.ZERO);
        dto.setPreviousPrice(previousPrice);
        dto.setStockQuantity(product.getStockQuantity());
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getCategoryId() { return categoryId; }
    public void setCategoryId(UUID categoryId) { this.categoryId = categoryId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getMarathiName() { return marathiName; }
    public void setMarathiName(String marathiName) { this.marathiName = marathiName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { isAvailable = available; }
    public BigDecimal getCurrentPrice() { return currentPrice; }
    public void setCurrentPrice(BigDecimal currentPrice) { this.currentPrice = currentPrice; }
    public BigDecimal getPreviousPrice() { return previousPrice; }
    public void setPreviousPrice(BigDecimal previousPrice) { this.previousPrice = previousPrice; }
    public BigDecimal getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(BigDecimal stockQuantity) { this.stockQuantity = stockQuantity; }
}
