package com.kisansetu.modules.settlement.dto;

import com.kisansetu.modules.settlement.entity.Settlement;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public class SettlementDto {
    private UUID id;
    private UUID farmerId;
    private String farmerPhone;
    private UUID orderId;
    private BigDecimal grossAmount;
    private BigDecimal platformCommission;
    private BigDecimal netAmount;
    private String status;
    private String bankAccountMasked;
    private String transactionReference;
    private String remarks;
    private Instant authorizedAt;
    private Instant paidAt;
    private Instant createdAt;

    public static SettlementDto fromEntity(Settlement s) {
        SettlementDto dto = new SettlementDto();
        dto.id = s.getId();
        dto.farmerId = s.getFarmer().getId();
        dto.farmerPhone = s.getFarmer().getPhone();
        dto.orderId = s.getOrderId();
        dto.grossAmount = s.getGrossAmount();
        dto.platformCommission = s.getPlatformCommission();
        dto.netAmount = s.getNetAmount();
        dto.status = s.getStatus();
        dto.bankAccountMasked = s.getBankAccountMasked();
        dto.transactionReference = s.getTransactionReference();
        dto.remarks = s.getRemarks();
        dto.authorizedAt = s.getAuthorizedAt();
        dto.paidAt = s.getPaidAt();
        dto.createdAt = s.getCreatedAt();
        return dto;
    }

    public UUID getId() { return id; }
    public UUID getFarmerId() { return farmerId; }
    public String getFarmerPhone() { return farmerPhone; }
    public UUID getOrderId() { return orderId; }
    public BigDecimal getGrossAmount() { return grossAmount; }
    public BigDecimal getPlatformCommission() { return platformCommission; }
    public BigDecimal getNetAmount() { return netAmount; }
    public String getStatus() { return status; }
    public String getBankAccountMasked() { return bankAccountMasked; }
    public String getTransactionReference() { return transactionReference; }
    public String getRemarks() { return remarks; }
    public Instant getAuthorizedAt() { return authorizedAt; }
    public Instant getPaidAt() { return paidAt; }
    public Instant getCreatedAt() { return createdAt; }
}
