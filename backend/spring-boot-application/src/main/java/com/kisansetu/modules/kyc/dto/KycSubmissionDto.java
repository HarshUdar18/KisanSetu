package com.kisansetu.modules.kyc.dto;

import com.kisansetu.modules.kyc.entity.KycSubmission;
import java.time.Instant;
import java.util.UUID;

public class KycSubmissionDto {
    private UUID id;
    private UUID farmerId;
    private String farmerPhone;
    private String documentType;
    private String documentNumber;
    private String documentUrl;
    private String selfieUrl;
    private String bankAccountNumber;
    private String ifscCode;
    private String landRecordNumber;
    private String status;
    private String remarks;
    private Instant submittedAt;
    private Instant reviewedAt;

    public static KycSubmissionDto fromEntity(KycSubmission e) {
        KycSubmissionDto dto = new KycSubmissionDto();
        dto.id = e.getId();
        dto.farmerId = e.getFarmer().getId();
        dto.farmerPhone = e.getFarmer().getPhone();
        dto.documentType = e.getDocumentType();
        dto.documentNumber = e.getDocumentNumber();
        dto.documentUrl = e.getDocumentUrl();
        dto.selfieUrl = e.getSelfieUrl();
        dto.bankAccountNumber = e.getBankAccountNumber();
        dto.ifscCode = e.getIfscCode();
        dto.landRecordNumber = e.getLandRecordNumber();
        dto.status = e.getStatus();
        dto.remarks = e.getRemarks();
        dto.submittedAt = e.getSubmittedAt();
        dto.reviewedAt = e.getReviewedAt();
        return dto;
    }

    public UUID getId() { return id; }
    public UUID getFarmerId() { return farmerId; }
    public String getFarmerPhone() { return farmerPhone; }
    public String getDocumentType() { return documentType; }
    public String getDocumentNumber() { return documentNumber; }
    public String getDocumentUrl() { return documentUrl; }
    public String getSelfieUrl() { return selfieUrl; }
    public String getBankAccountNumber() { return bankAccountNumber; }
    public String getIfscCode() { return ifscCode; }
    public String getLandRecordNumber() { return landRecordNumber; }
    public String getStatus() { return status; }
    public String getRemarks() { return remarks; }
    public Instant getSubmittedAt() { return submittedAt; }
    public Instant getReviewedAt() { return reviewedAt; }
}
