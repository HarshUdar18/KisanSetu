package com.kisansetu.modules.demand.dto;

import com.kisansetu.modules.demand.entity.DemandRequest;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class DemandDto {
    private UUID id;
    private UUID requesterId;
    private UUID productId;
    private String productName;
    private BigDecimal quantityKg;
    private BigDecimal targetPricePerKg;
    private LocalDate requiredByDate;
    private String notes;
    private String status;
    private UUID acceptedByFarmerId;
    private BigDecimal offeredPricePerKg;
    private BigDecimal confirmedQuantityKg;
    private Instant acceptedAt;
    private Instant createdAt;

    public static DemandDto fromEntity(DemandRequest d) {
        DemandDto dto = new DemandDto();
        dto.id = d.getId();
        dto.requesterId = d.getRequester().getId();
        dto.productId = d.getProduct().getId();
        dto.productName = d.getProduct().getName();
        dto.quantityKg = d.getQuantityKg();
        dto.targetPricePerKg = d.getTargetPricePerKg();
        dto.requiredByDate = d.getRequiredByDate();
        dto.notes = d.getNotes();
        dto.status = d.getStatus();
        dto.acceptedByFarmerId = d.getAcceptedByFarmerId();
        dto.offeredPricePerKg = d.getOfferedPricePerKg();
        dto.confirmedQuantityKg = d.getConfirmedQuantityKg();
        dto.acceptedAt = d.getAcceptedAt();
        dto.createdAt = d.getCreatedAt();
        return dto;
    }

    public UUID getId() { return id; }
    public UUID getRequesterId() { return requesterId; }
    public UUID getProductId() { return productId; }
    public String getProductName() { return productName; }
    public BigDecimal getQuantityKg() { return quantityKg; }
    public BigDecimal getTargetPricePerKg() { return targetPricePerKg; }
    public LocalDate getRequiredByDate() { return requiredByDate; }
    public String getNotes() { return notes; }
    public String getStatus() { return status; }
    public UUID getAcceptedByFarmerId() { return acceptedByFarmerId; }
    public BigDecimal getOfferedPricePerKg() { return offeredPricePerKg; }
    public BigDecimal getConfirmedQuantityKg() { return confirmedQuantityKg; }
    public Instant getAcceptedAt() { return acceptedAt; }
    public Instant getCreatedAt() { return createdAt; }
}
