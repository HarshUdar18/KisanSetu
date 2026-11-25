package com.kisansetu.modules.farmer.entity;

import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.user.entity.User;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "farmer_listings")
public class FarmerListing {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_id", nullable = false)
    private User farmer;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "quantity_available", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantityAvailable = BigDecimal.ZERO;

    @Column(name = "unit", nullable = false, length = 20)
    private String unit = "kg";

    @Column(name = "price_per_unit", nullable = false, precision = 10, scale = 2)
    private BigDecimal pricePerUnit;

    @Column(name = "harvest_date")
    private LocalDate harvestDate;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "quality_grade", length = 20)
    private String qualityGrade = "GRADE_A";

    @Column(name = "is_available", nullable = false)
    private Boolean isAvailable = true;

    @Column(name = "status", nullable = false, length = 20)
    private String status = "ACTIVE";

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public FarmerListing() {}

    public FarmerListing(User farmer, Product product, BigDecimal quantityAvailable, String unit,
                         BigDecimal pricePerUnit, LocalDate harvestDate, String description,
                         String qualityGrade) {
        this.farmer = farmer;
        this.product = product;
        this.quantityAvailable = quantityAvailable;
        this.unit = unit != null ? unit : "kg";
        this.pricePerUnit = pricePerUnit;
        this.harvestDate = harvestDate;
        this.description = description;
        this.qualityGrade = qualityGrade != null ? qualityGrade : "GRADE_A";
        this.isAvailable = true;
        this.status = "ACTIVE";
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public User getFarmer() { return farmer; }
    public void setFarmer(User farmer) { this.farmer = farmer; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public BigDecimal getQuantityAvailable() { return quantityAvailable; }
    public void setQuantityAvailable(BigDecimal quantityAvailable) { this.quantityAvailable = quantityAvailable; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public BigDecimal getPricePerUnit() { return pricePerUnit; }
    public void setPricePerUnit(BigDecimal pricePerUnit) { this.pricePerUnit = pricePerUnit; }

    public LocalDate getHarvestDate() { return harvestDate; }
    public void setHarvestDate(LocalDate harvestDate) { this.harvestDate = harvestDate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getQualityGrade() { return qualityGrade; }
    public void setQualityGrade(String qualityGrade) { this.qualityGrade = qualityGrade; }

    public Boolean getIsAvailable() { return isAvailable; }
    public void setIsAvailable(Boolean isAvailable) { this.isAvailable = isAvailable; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
