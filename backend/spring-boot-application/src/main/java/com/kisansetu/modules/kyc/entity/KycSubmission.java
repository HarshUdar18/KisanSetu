package com.kisansetu.modules.kyc.entity;

import com.kisansetu.modules.user.entity.User;
import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "kyc_submissions")
public class KycSubmission {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "farmer_id", nullable = false)
    private User farmer;

    @Column(name = "document_type", nullable = false, length = 50)
    private String documentType = "AADHAAR";

    @Column(name = "document_number", nullable = false, length = 100)
    private String documentNumber;

    @Column(name = "document_url", length = 500)
    private String documentUrl;

    @Column(name = "selfie_url", length = 500)
    private String selfieUrl;

    @Column(name = "bank_account_number", length = 50)
    private String bankAccountNumber;

    @Column(name = "ifsc_code", length = 20)
    private String ifscCode;

    @Column(name = "land_record_number", length = 100)
    private String landRecordNumber;

    @Column(nullable = false, length = 30)
    private String status = "UNDER_REVIEW";

    @Column(columnDefinition = "TEXT")
    private String remarks;

    @Column(name = "reviewed_by")
    private UUID reviewedBy;

    @Column(name = "submitted_at", nullable = false)
    private Instant submittedAt = Instant.now();

    @Column(name = "reviewed_at")
    private Instant reviewedAt;

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
    public String getDocumentType() { return documentType; }
    public void setDocumentType(String documentType) { this.documentType = documentType; }
    public String getDocumentNumber() { return documentNumber; }
    public void setDocumentNumber(String documentNumber) { this.documentNumber = documentNumber; }
    public String getDocumentUrl() { return documentUrl; }
    public void setDocumentUrl(String documentUrl) { this.documentUrl = documentUrl; }
    public String getSelfieUrl() { return selfieUrl; }
    public void setSelfieUrl(String selfieUrl) { this.selfieUrl = selfieUrl; }
    public String getBankAccountNumber() { return bankAccountNumber; }
    public void setBankAccountNumber(String bankAccountNumber) { this.bankAccountNumber = bankAccountNumber; }
    public String getIfscCode() { return ifscCode; }
    public void setIfscCode(String ifscCode) { this.ifscCode = ifscCode; }
    public String getLandRecordNumber() { return landRecordNumber; }
    public void setLandRecordNumber(String landRecordNumber) { this.landRecordNumber = landRecordNumber; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    public UUID getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(UUID reviewedBy) { this.reviewedBy = reviewedBy; }
    public Instant getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Instant submittedAt) { this.submittedAt = submittedAt; }
    public Instant getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Instant reviewedAt) { this.reviewedAt = reviewedAt; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
