package com.kisansetu.modules.settlement.entity;

import com.kisansetu.modules.user.entity.User;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "settlements")
public class Settlement {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "farmer_id", nullable = false)
    private User farmer;

    @Column(name = "order_id")
    private UUID orderId;

    @Column(name = "gross_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal grossAmount;

    @Column(name = "platform_commission", nullable = false, precision = 12, scale = 2)
    private BigDecimal platformCommission = BigDecimal.ZERO;

    @Column(name = "net_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal netAmount;

    @Column(nullable = false, length = 30)
    private String status = "PENDING";

    @Column(name = "bank_account_masked", length = 30)
    private String bankAccountMasked;

    @Column(name = "transaction_reference", length = 100)
    private String transactionReference;

    @Column(name = "authorized_by")
    private UUID authorizedBy;

    @Column(columnDefinition = "TEXT")
    private String remarks;

    @Column(name = "authorized_at")
    private Instant authorizedAt;

    @Column(name = "paid_at")
    private Instant paidAt;

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
    public User getFarmer() { return farmer; }
    public void setFarmer(User farmer) { this.farmer = farmer; }
    public UUID getOrderId() { return orderId; }
    public void setOrderId(UUID orderId) { this.orderId = orderId; }
    public BigDecimal getGrossAmount() { return grossAmount; }
    public void setGrossAmount(BigDecimal grossAmount) { this.grossAmount = grossAmount; }
    public BigDecimal getPlatformCommission() { return platformCommission; }
    public void setPlatformCommission(BigDecimal platformCommission) { this.platformCommission = platformCommission; }
    public BigDecimal getNetAmount() { return netAmount; }
    public void setNetAmount(BigDecimal netAmount) { this.netAmount = netAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getBankAccountMasked() { return bankAccountMasked; }
    public void setBankAccountMasked(String bankAccountMasked) { this.bankAccountMasked = bankAccountMasked; }
    public String getTransactionReference() { return transactionReference; }
    public void setTransactionReference(String transactionReference) { this.transactionReference = transactionReference; }
    public UUID getAuthorizedBy() { return authorizedBy; }
    public void setAuthorizedBy(UUID authorizedBy) { this.authorizedBy = authorizedBy; }
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    public Instant getAuthorizedAt() { return authorizedAt; }
    public void setAuthorizedAt(Instant authorizedAt) { this.authorizedAt = authorizedAt; }
    public Instant getPaidAt() { return paidAt; }
    public void setPaidAt(Instant paidAt) { this.paidAt = paidAt; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
