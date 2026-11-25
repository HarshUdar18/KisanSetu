package com.kisansetu.modules.admin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class CreateCategoryRequest {

    @NotBlank(message = "Category name is required")
    private String name;

    @NotBlank(message = "Category code is required")
    @Pattern(regexp = "^[A-Z0-9_]+$", message = "Category code must be uppercase alphanumeric and underscores")
    private String code;

    private String description;

    private String iconUrl;

    private int displayOrder = 0;

    public CreateCategoryRequest() {}

    public CreateCategoryRequest(String name, String code, String description, String iconUrl, int displayOrder) {
        this.name = name;
        this.code = code;
        this.description = description;
        this.iconUrl = iconUrl;
        this.displayOrder = displayOrder;
    }

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
}
