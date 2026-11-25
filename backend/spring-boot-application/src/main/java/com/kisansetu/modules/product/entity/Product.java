package com.kisansetu.modules.product.entity;

import com.kisansetu.modules.catalog.entity.ProductCategory;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "category_id", nullable = false)
    private ProductCategory category;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(name = "marathi_name", length = 150)
    private String marathiName;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 20)
    private String unit = "kg";

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "is_available", nullable = false)
    private boolean isAvailable = true;

    @Column(name = "stock_quantity", nullable = false, precision = 10, scale = 2)
    private BigDecimal stockQuantity = BigDecimal.valueOf(100.0);

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public Product() {}

    public Product(ProductCategory category, String name, String marathiName, String description, String unit, String imageUrl) {
        this.category = category;
        this.name = name;
        this.marathiName = marathiName;
        this.description = description;
        this.unit = unit;
        this.imageUrl = imageUrl;
        this.isAvailable = true;
        this.stockQuantity = BigDecimal.valueOf(100.0);
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public ProductCategory getCategory() { return category; }
    public void setCategory(ProductCategory category) { this.category = category; }
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
    public BigDecimal getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(BigDecimal stockQuantity) { this.stockQuantity = stockQuantity; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
