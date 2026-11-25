package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "farmer_store_orders")
public class FarmerStoreOrder {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(name = "farmer_id", nullable = false)
    private UUID farmerId;
    @Column(name = "total_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalAmount;
    @Column(nullable = false, length = 30)
    private String status = "CONFIRMED";
    @Column(name = "items_json", nullable = false, columnDefinition = "TEXT")
    private String itemsJson;
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId() { return id; }
    public UUID getFarmerId() { return farmerId; }
    public void setFarmerId(UUID farmerId) { this.farmerId = farmerId; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getItemsJson() { return itemsJson; }
    public void setItemsJson(String itemsJson) { this.itemsJson = itemsJson; }
    public Instant getCreatedAt() { return createdAt; }
}
