package com.kisansetu.modules.kyc.service;

import com.kisansetu.common.events.DomainEventPublisher;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.kyc.dto.KycSubmissionDto;
import com.kisansetu.modules.kyc.entity.KycSubmission;
import com.kisansetu.modules.kyc.repository.KycSubmissionRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class KycService {

    private final KycSubmissionRepository kycRepository;
    private final UserRepository userRepository;
    private final DomainEventPublisher eventPublisher;

    public KycService(KycSubmissionRepository kycRepository,
                      UserRepository userRepository,
                      DomainEventPublisher eventPublisher) {
        this.kycRepository = kycRepository;
        this.userRepository = userRepository;
        this.eventPublisher = eventPublisher;
    }

    @Transactional
    public KycSubmissionDto submitKyc(UUID farmerId, String documentType, String documentNumber,
                                      String documentUrl, String selfieUrl,
                                      String bankAccountNumber, String ifscCode, String landRecordNumber) {
        User farmer = userRepository.findById(farmerId)
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "Farmer user not found", HttpStatus.NOT_FOUND));

        KycSubmission submission = new KycSubmission();
        submission.setFarmer(farmer);
        submission.setDocumentType(documentType != null ? documentType : "AADHAAR");
        submission.setDocumentNumber(documentNumber);
        submission.setDocumentUrl(documentUrl);
        submission.setSelfieUrl(selfieUrl);
        submission.setBankAccountNumber(bankAccountNumber);
        submission.setIfscCode(ifscCode);
        submission.setLandRecordNumber(landRecordNumber);
        submission.setStatus("UNDER_REVIEW");
        submission.setSubmittedAt(Instant.now());

        KycSubmission saved = kycRepository.save(submission);

        eventPublisher.publish("kyc.submitted", "com.kisansetu.events.KycSubmitted", Map.of(
                "submissionId", saved.getId().toString(),
                "farmerId", farmer.getId().toString(),
                "documentType", saved.getDocumentType()
        ));

        return KycSubmissionDto.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public KycSubmissionDto getStatus(UUID farmerId) {
        return kycRepository.findTopByFarmerIdOrderBySubmittedAtDesc(farmerId)
                .map(KycSubmissionDto::fromEntity)
                .orElseThrow(() -> new ApiException("KYC_NOT_FOUND", "No KYC submission found for farmer", HttpStatus.NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public List<KycSubmissionDto> listAll(String status) {
        List<KycSubmission> list = (status != null && !status.isBlank())
                ? kycRepository.findByStatusOrderBySubmittedAtDesc(status.toUpperCase())
                : kycRepository.findAllByOrderBySubmittedAtDesc();
        return list.stream().map(KycSubmissionDto::fromEntity).collect(Collectors.toList());
    }

    @Transactional
    public KycSubmissionDto reviewKyc(UUID submissionId, UUID adminId, boolean approve, String remarks) {
        KycSubmission sub = kycRepository.findById(submissionId)
                .orElseThrow(() -> new ApiException("KYC_NOT_FOUND", "KYC submission not found", HttpStatus.NOT_FOUND));

        sub.setStatus(approve ? "VERIFIED" : "REJECTED");
        sub.setRemarks(remarks);
        sub.setReviewedBy(adminId);
        sub.setReviewedAt(Instant.now());
        KycSubmission saved = kycRepository.save(sub);

        String routingKey = approve ? "kyc.approved" : "kyc.rejected";
        String eventType = approve ? "com.kisansetu.events.KycApproved" : "com.kisansetu.events.KycRejected";
        eventPublisher.publish(routingKey, eventType, Map.of(
                "submissionId", saved.getId().toString(),
                "farmerId", saved.getFarmer().getId().toString(),
                "status", saved.getStatus(),
                "reviewedBy", adminId.toString()
        ));

        return KycSubmissionDto.fromEntity(saved);
    }
}
