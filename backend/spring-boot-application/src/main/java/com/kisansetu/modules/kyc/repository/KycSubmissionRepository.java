package com.kisansetu.modules.kyc.repository;

import com.kisansetu.modules.kyc.entity.KycSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface KycSubmissionRepository extends JpaRepository<KycSubmission, UUID> {
    Optional<KycSubmission> findTopByFarmerIdOrderBySubmittedAtDesc(UUID farmerId);
    List<KycSubmission> findByStatusOrderBySubmittedAtDesc(String status);
    List<KycSubmission> findAllByOrderBySubmittedAtDesc();
}
