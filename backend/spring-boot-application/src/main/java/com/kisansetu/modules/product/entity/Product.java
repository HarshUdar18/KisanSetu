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

    @Column(name = "product_code", length = 30)
    private String productCode;

    @Column(name = "canonical_name", length = 150)
    private String canonicalName;

    @Column(name = "scientific_name", length = 150)
    private String scientificName;

    @Column(name = "botanical_family", length = 100)
    private String botanicalFamily;

    @Column(name = "default_unit_id")
    private UUID defaultUnitId;

    @Column(name = "product_type", nullable = false, length = 40)
    private String productType = "PRODUCE";

    @Column(name = "is_perishable", nullable = false)
    private boolean isPerishable = true;

    @Column(name = "storage_requirements", columnDefinition = "TEXT")
    private String storageRequirements;

    @Column(name = "shelf_life_info", length = 150)
    private String shelfLifeInfo;

    @Column(name = "is_seeded", nullable = false)
    private boolean isSeeded = false;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "updated_by")
    private UUID updatedBy;

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
    public String getProductCode() { return productCode; }
    public void setProductCode(String productCode) { this.productCode = productCode; }
    public String getCanonicalName() { return canonicalName; }
    public void setCanonicalName(String canonicalName) { this.canonicalName = canonicalName; }
    public String getScientificName() { return scientificName; }
    public void setScientificName(String scientificName) { this.scientificName = scientificName; }
    public String getBotanicalFamily() { return botanicalFamily; }
    public void setBotanicalFamily(String botanicalFamily) { this.botanicalFamily = botanicalFamily; }
    public UUID getDefaultUnitId() { return defaultUnitId; }
    public void setDefaultUnitId(UUID defaultUnitId) { this.defaultUnitId = defaultUnitId; }
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
    public UUID getCreatedBy() { return createdBy; }
    public void setCreatedBy(UUID createdBy) { this.createdBy = createdBy; }
    public UUID getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(UUID updatedBy) { this.updatedBy = updatedBy; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
