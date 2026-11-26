package com.kisansetu.product.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "products")
public class ProductEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "category_id", nullable = false)
    private CategoryEntity category;
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
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public CategoryEntity getCategory() { return category; }
    public void setCategory(CategoryEntity category) { this.category = category; }
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
}
