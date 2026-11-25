package com.kisansetu.modules.cart.entity;

import com.kisansetu.modules.product.entity.Product;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "weekly_cart_items", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"weekly_cart_day_id", "product_id"})
})
public class WeeklyCartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "weekly_cart_day_id", nullable = false)
    private WeeklyCartDay weeklyCartDay;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal quantity = BigDecimal.ONE;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public WeeklyCartItem() {}

    public WeeklyCartItem(WeeklyCartDay weeklyCartDay, Product product, BigDecimal quantity) {
        this.weeklyCartDay = weeklyCartDay;
        this.product = product;
        this.quantity = quantity;
        this.createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public WeeklyCartDay getWeeklyCartDay() { return weeklyCartDay; }
    public void setWeeklyCartDay(WeeklyCartDay weeklyCartDay) { this.weeklyCartDay = weeklyCartDay; }
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }
    public Instant getCreatedAt() { return createdAt; }
}
