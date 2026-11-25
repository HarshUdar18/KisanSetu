package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "inventory_items")
public class InventoryItem {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(name = "warehouse_id")
    private UUID warehouseId;
    @Column(name = "product_id", nullable = false)
    private UUID productId;
    @Column(name = "available_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal availableKg = BigDecimal.ZERO;
    @Column(name = "reserved_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal reservedKg = BigDecimal.ZERO;
    @Column(name = "reorder_level_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal reorderLevelKg = BigDecimal.valueOf(50);
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getWarehouseId() { return warehouseId; }
    public void setWarehouseId(UUID warehouseId) { this.warehouseId = warehouseId; }
    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }
    public BigDecimal getAvailableKg() { return availableKg; }
    public void setAvailableKg(BigDecimal availableKg) { this.availableKg = availableKg; }
    public BigDecimal getReservedKg() { return reservedKg; }
    public void setReservedKg(BigDecimal reservedKg) { this.reservedKg = reservedKg; }
    public BigDecimal getReorderLevelKg() { return reorderLevelKg; }
    public void setReorderLevelKg(BigDecimal reorderLevelKg) { this.reorderLevelKg = reorderLevelKg; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
