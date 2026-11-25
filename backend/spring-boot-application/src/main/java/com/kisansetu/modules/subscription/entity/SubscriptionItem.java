package com.kisansetu.modules.subscription.entity;

import com.kisansetu.modules.product.entity.Product;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "subscription_items")
public class SubscriptionItem {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subscription_id", nullable = false)
    private Subscription subscription;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "day_of_week", nullable = false, length = 15)
    private String dayOfWeek;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal quantity = BigDecimal.ONE;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public SubscriptionItem() {}

    public SubscriptionItem(Subscription subscription, Product product, String dayOfWeek, BigDecimal quantity) {
        this.subscription = subscription;
        this.product = product;
        this.dayOfWeek = dayOfWeek;
        this.quantity = quantity;
        this.createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public Subscription getSubscription() { return subscription; }
    public void setSubscription(Subscription subscription) { this.subscription = subscription; }
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }
    public Instant getCreatedAt() { return createdAt; }
}
