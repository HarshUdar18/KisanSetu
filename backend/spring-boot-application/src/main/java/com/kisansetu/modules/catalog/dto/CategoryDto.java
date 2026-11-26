package com.kisansetu.modules.catalog.dto;

import com.kisansetu.modules.catalog.entity.ProductCategory;
import java.util.UUID;

public class CategoryDto {
    private UUID id;
    private UUID parentCategoryId;
    private String name;
    private String code;
    private String description;
    private String iconUrl;
    private int displayOrder;
    private boolean isActive = true;
    private long productCount;

    public CategoryDto() {}

    public static CategoryDto fromEntity(ProductCategory category, long productCount) {
        CategoryDto dto = new CategoryDto();
        dto.setId(category.getId());
        dto.setParentCategoryId(category.getParentCategoryId());
        dto.setName(category.getName());
        dto.setCode(category.getCode());
        dto.setDescription(category.getDescription());
        dto.setIconUrl(category.getIconUrl());
        dto.setDisplayOrder(category.getDisplayOrder());
        dto.setActive(category.isActive());
        dto.setProductCount(productCount);
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getParentCategoryId() { return parentCategoryId; }
    public void setParentCategoryId(UUID parentCategoryId) { this.parentCategoryId = parentCategoryId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getIconUrl() { return iconUrl; }
    public void setIconUrl(String iconUrl) { this.iconUrl = iconUrl; }
    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public long getProductCount() { return productCount; }
    public void setProductCount(long productCount) { this.productCount = productCount; }
}
