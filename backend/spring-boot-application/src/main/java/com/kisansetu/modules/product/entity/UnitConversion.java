package com.kisansetu.modules.product.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "unit_conversions", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"from_unit_id", "to_unit_id"})
})
public class UnitConversion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "from_unit_id", nullable = false)
    private ProductUnit fromUnit;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "to_unit_id", nullable = false)
    private ProductUnit toUnit;

    @Column(name = "conversion_factor", nullable = false, precision = 18, scale = 6)
    private BigDecimal conversionFactor;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public ProductUnit getFromUnit() { return fromUnit; }
    public void setFromUnit(ProductUnit fromUnit) { this.fromUnit = fromUnit; }
    public ProductUnit getToUnit() { return toUnit; }
    public void setToUnit(ProductUnit toUnit) { this.toUnit = toUnit; }
    public BigDecimal getConversionFactor() { return conversionFactor; }
    public void setConversionFactor(BigDecimal conversionFactor) { this.conversionFactor = conversionFactor; }
    public Instant getCreatedAt() { return createdAt; }
}
