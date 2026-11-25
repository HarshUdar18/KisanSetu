package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "collection_records")
public class CollectionRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(name = "farmer_id", nullable = false)
    private UUID farmerId;
    @Column(name = "product_id", nullable = false)
    private UUID productId;
    @Column(name = "collection_point", nullable = false, length = 150)
    private String collectionPoint;
    @Column(name = "scheduled_date", nullable = false)
    private LocalDate scheduledDate;
    @Column(name = "quantity_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantityKg;
    @Column(nullable = false, length = 30)
    private String status = "SCHEDULED";
    @Column(name = "gate_pass_code", length = 50)
    private String gatePassCode;
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getFarmerId() { return farmerId; }
    public void setFarmerId(UUID farmerId) { this.farmerId = farmerId; }
    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }
    public String getCollectionPoint() { return collectionPoint; }
    public void setCollectionPoint(String collectionPoint) { this.collectionPoint = collectionPoint; }
    public LocalDate getScheduledDate() { return scheduledDate; }
    public void setScheduledDate(LocalDate scheduledDate) { this.scheduledDate = scheduledDate; }
    public BigDecimal getQuantityKg() { return quantityKg; }
    public void setQuantityKg(BigDecimal quantityKg) { this.quantityKg = quantityKg; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getGatePassCode() { return gatePassCode; }
    public void setGatePassCode(String gatePassCode) { this.gatePassCode = gatePassCode; }
    public Instant getCreatedAt() { return createdAt; }
}
