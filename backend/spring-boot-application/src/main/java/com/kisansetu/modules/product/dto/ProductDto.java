package com.kisansetu.modules.product.dto;

import com.kisansetu.modules.product.entity.Product;
import java.math.BigDecimal;
import java.util.UUID;

public class ProductDto {
    private UUID id;
    private UUID categoryId;
    private String categoryName;
    private String productCode;
    private String name;
    private String canonicalName;
    private String marathiName;
    private String description;
    private String scientificName;
    private String botanicalFamily;
    private UUID defaultUnitId;
    private String unit;
    private String productType;
    private boolean isPerishable;
    private String storageRequirements;
    private String shelfLifeInfo;
    private boolean isSeeded;
    private String imageUrl;
    private boolean isAvailable;
    private BigDecimal currentPrice;
    private BigDecimal previousPrice;
    private BigDecimal stockQuantity;
    private String stockStatus;
    private int activeListingCount;
    private BigDecimal lowestListingPrice;

    public ProductDto() {}

    public static ProductDto fromEntity(Product product, BigDecimal currentPrice, BigDecimal previousPrice) {
        ProductDto dto = new ProductDto();
        dto.setId(product.getId());
        if (product.getCategory() != null) {
            dto.setCategoryId(product.getCategory().getId());
            dto.setCategoryName(product.getCategory().getName());
        }
        dto.setProductCode(product.getProductCode());
        dto.setName(product.getName());
        dto.setCanonicalName(product.getCanonicalName() != null ? product.getCanonicalName() : product.getName());
        dto.setMarathiName(product.getMarathiName());
        dto.setDescription(product.getDescription());
        dto.setScientificName(product.getScientificName());
        dto.setBotanicalFamily(product.getBotanicalFamily());
        dto.setDefaultUnitId(product.getDefaultUnitId());
        dto.setUnit(product.getUnit());
        dto.setProductType(product.getProductType());
        dto.setPerishable(product.isPerishable());
        dto.setStorageRequirements(product.getStorageRequirements());
        dto.setShelfLifeInfo(product.getShelfLifeInfo());
        dto.setSeeded(product.isSeeded());
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
    public String getProductCode() { return productCode; }
    public void setProductCode(String productCode) { this.productCode = productCode; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCanonicalName() { return canonicalName; }
    public void setCanonicalName(String canonicalName) { this.canonicalName = canonicalName; }
    public String getMarathiName() { return marathiName; }
    public void setMarathiName(String marathiName) { this.marathiName = marathiName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getScientificName() { return scientificName; }
    public void setScientificName(String scientificName) { this.scientificName = scientificName; }
    public String getBotanicalFamily() { return botanicalFamily; }
    public void setBotanicalFamily(String botanicalFamily) { this.botanicalFamily = botanicalFamily; }
    public UUID getDefaultUnitId() { return defaultUnitId; }
    public void setDefaultUnitId(UUID defaultUnitId) { this.defaultUnitId = defaultUnitId; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public String getProductType() { return productType; }
    public void setProductType(String productType) { this.productType = productType; }
    public boolean isPerishable() { return isPerishable; }
    public void setPerishable(boolean perishable) { isPerishable = perishable; }
    public String getStorageRequirements() { return storageRequirements; }
    public void setStorageRequirements(String storageRequirements) { this.storageRequirements = storageRequirements; }
    public String getShelfLifeInfo() { return shelfLifeInfo; }
    public void setShelfLifeInfo(String shelfLifeInfo) { this.shelfLifeInfo = shelfLifeInfo; }
    public boolean isSeeded() { return isSeeded; }
    public void setSeeded(boolean seeded) { isSeeded = seeded; }
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
    public String getStockStatus() { return stockStatus; }
    public void setStockStatus(String stockStatus) { this.stockStatus = stockStatus; }
    public int getActiveListingCount() { return activeListingCount; }
    public void setActiveListingCount(int activeListingCount) { this.activeListingCount = activeListingCount; }
    public BigDecimal getLowestListingPrice() { return lowestListingPrice; }
    public void setLowestListingPrice(BigDecimal lowestListingPrice) { this.lowestListingPrice = lowestListingPrice; }
}
