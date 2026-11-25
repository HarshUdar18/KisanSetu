package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "warehouses")
public class Warehouse {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false, length = 150)
    private String name;
    @Column(nullable = false, unique = true, length = 50)
    private String code;
    @Column(nullable = false, length = 150)
    private String location;
    @Column(name = "capacity_tons", nullable = false, precision = 10, scale = 2)
    private BigDecimal capacityTons = BigDecimal.valueOf(100);
    @Column(name = "used_tons", nullable = false, precision = 10, scale = 2)
    private BigDecimal usedTons = BigDecimal.ZERO;
    @Column(name = "cold_storage_available", nullable = false)
    private boolean coldStorageAvailable = true;
    @Column(nullable = false, length = 30)
    private String status = "OPERATIONAL";
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public BigDecimal getCapacityTons() { return capacityTons; }
    public void setCapacityTons(BigDecimal capacityTons) { this.capacityTons = capacityTons; }
    public BigDecimal getUsedTons() { return usedTons; }
    public void setUsedTons(BigDecimal usedTons) { this.usedTons = usedTons; }
    public boolean isColdStorageAvailable() { return coldStorageAvailable; }
    public void setColdStorageAvailable(boolean coldStorageAvailable) { this.coldStorageAvailable = coldStorageAvailable; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getCreatedAt() { return createdAt; }
}
