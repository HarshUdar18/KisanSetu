package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "stock_movements")
public class StockMovement {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "product_id", nullable = false)
    private UUID productId;

    @Column(name = "warehouse_id")
    private UUID warehouseId;

    @Column(name = "movement_type", nullable = false, length = 40)
    private String movementType;

    @Column(name = "quantity_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantityKg;

    @Column(name = "reference_id")
    private UUID referenceId;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public StockMovement() {}

    public StockMovement(UUID productId, UUID warehouseId, String movementType, BigDecimal quantityKg, UUID referenceId, String notes) {
        this.productId = productId;
        this.warehouseId = warehouseId;
        this.movementType = movementType;
        this.quantityKg = quantityKg;
        this.referenceId = referenceId;
        this.notes = notes;
    }

    public UUID getId() { return id; }
    public UUID getProductId() { return productId; }
    public UUID getWarehouseId() { return warehouseId; }
    public String getMovementType() { return movementType; }
    public BigDecimal getQuantityKg() { return quantityKg; }
    public UUID getReferenceId() { return referenceId; }
    public String getNotes() { return notes; }
    public Instant getCreatedAt() { return createdAt; }
}
