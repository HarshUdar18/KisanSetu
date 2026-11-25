package com.kisansetu.modules.demand.entity;

import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.user.entity.User;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "demand_requests")
public class DemandRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requester_id", nullable = false)
    private User requester;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "quantity_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantityKg;

    @Column(name = "target_price_per_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal targetPricePerKg;

    @Column(name = "required_by_date", nullable = false)
    private LocalDate requiredByDate;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(nullable = false, length = 30)
    private String status = "OPEN";

    @Column(name = "accepted_by_farmer_id")
    private UUID acceptedByFarmerId;

    @Column(name = "offered_price_per_kg", precision = 10, scale = 2)
    private BigDecimal offeredPricePerKg;

    @Column(name = "confirmed_quantity_kg", precision = 10, scale = 2)
    private BigDecimal confirmedQuantityKg;

    @Column(name = "accepted_at")
    private Instant acceptedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public User getRequester() { return requester; }
    public void setRequester(User requester) { this.requester = requester; }
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public BigDecimal getQuantityKg() { return quantityKg; }
    public void setQuantityKg(BigDecimal quantityKg) { this.quantityKg = quantityKg; }
    public BigDecimal getTargetPricePerKg() { return targetPricePerKg; }
    public void setTargetPricePerKg(BigDecimal targetPricePerKg) { this.targetPricePerKg = targetPricePerKg; }
    public LocalDate getRequiredByDate() { return requiredByDate; }
    public void setRequiredByDate(LocalDate requiredByDate) { this.requiredByDate = requiredByDate; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public UUID getAcceptedByFarmerId() { return acceptedByFarmerId; }
    public void setAcceptedByFarmerId(UUID acceptedByFarmerId) { this.acceptedByFarmerId = acceptedByFarmerId; }
    public BigDecimal getOfferedPricePerKg() { return offeredPricePerKg; }
    public void setOfferedPricePerKg(BigDecimal offeredPricePerKg) { this.offeredPricePerKg = offeredPricePerKg; }
    public BigDecimal getConfirmedQuantityKg() { return confirmedQuantityKg; }
    public void setConfirmedQuantityKg(BigDecimal confirmedQuantityKg) { this.confirmedQuantityKg = confirmedQuantityKg; }
    public Instant getAcceptedAt() { return acceptedAt; }
    public void setAcceptedAt(Instant acceptedAt) { this.acceptedAt = acceptedAt; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
