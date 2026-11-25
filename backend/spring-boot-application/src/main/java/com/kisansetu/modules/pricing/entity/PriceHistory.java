package com.kisansetu.modules.pricing.entity;

import com.kisansetu.modules.product.entity.Product;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "price_history")
public class PriceHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(name = "effective_date", nullable = false)
    private Instant effectiveDate = Instant.now();

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public PriceHistory() {}

    public PriceHistory(Product product, BigDecimal price, Instant effectiveDate) {
        this.product = product;
        this.price = price;
        this.effectiveDate = effectiveDate;
        this.createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public Product getProduct() { return product; }
    public BigDecimal getPrice() { return price; }
    public Instant getEffectiveDate() { return effectiveDate; }
    public Instant getCreatedAt() { return createdAt; }
}
