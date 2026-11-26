package com.kisansetu.modules.product.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "product_variants")
public class ProductVariant {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "product_id", nullable = false)
    private UUID productId;

    @Column(name = "variety_id")
    private UUID varietyId;

    @Column(nullable = false, unique = true, length = 60)
    private String sku;

    @Column(name = "variant_name", nullable = false, length = 150)
    private String variantName;

    @Column(length = 30)
    private String grade;

    @Column(name = "size_label", length = 50)
    private String sizeLabel;

    @Column(name = "packaging_label", length = 80)
    private String packagingLabel;

    @Column(name = "weight_value", precision = 14, scale = 3)
    private BigDecimal weightValue;

    @Column(name = "unit_id")
    private UUID unitId;

    @Column(name = "attributes_json", columnDefinition = "TEXT")
    private String attributesJson;

    @Column(name = "is_active", nullable = false)
    private boolean isActive = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }
    public UUID getVarietyId() { return varietyId; }
    public void setVarietyId(UUID varietyId) { this.varietyId = varietyId; }
    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }
    public String getVariantName() { return variantName; }
    public void setVariantName(String variantName) { this.variantName = variantName; }
    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }
    public String getSizeLabel() { return sizeLabel; }
    public void setSizeLabel(String sizeLabel) { this.sizeLabel = sizeLabel; }
    public String getPackagingLabel() { return packagingLabel; }
    public void setPackagingLabel(String packagingLabel) { this.packagingLabel = packagingLabel; }
    public BigDecimal getWeightValue() { return weightValue; }
    public void setWeightValue(BigDecimal weightValue) { this.weightValue = weightValue; }
    public UUID getUnitId() { return unitId; }
    public void setUnitId(UUID unitId) { this.unitId = unitId; }
    public String getAttributesJson() { return attributesJson; }
    public void setAttributesJson(String attributesJson) { this.attributesJson = attributesJson; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
