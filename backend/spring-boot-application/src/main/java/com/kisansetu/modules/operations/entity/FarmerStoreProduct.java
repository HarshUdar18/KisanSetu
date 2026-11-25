package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "farmer_store_products")
public class FarmerStoreProduct {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false, length = 150)
    private String name;
    @Column(nullable = false, length = 80)
    private String category;
    @Column(nullable = false, length = 30)
    private String unit = "packet";
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal mrp;
    @Column(name = "subsidized_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal subsidizedPrice;
    @Column(name = "stock_quantity", nullable = false)
    private int stockQuantity = 100;
    @Column(name = "is_available", nullable = false)
    private boolean isAvailable = true;
    @Column(columnDefinition = "TEXT")
    private String description;
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public BigDecimal getMrp() { return mrp; }
    public void setMrp(BigDecimal mrp) { this.mrp = mrp; }
    public BigDecimal getSubsidizedPrice() { return subsidizedPrice; }
    public void setSubsidizedPrice(BigDecimal subsidizedPrice) { this.subsidizedPrice = subsidizedPrice; }
    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }
    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { isAvailable = available; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Instant getCreatedAt() { return createdAt; }
}
