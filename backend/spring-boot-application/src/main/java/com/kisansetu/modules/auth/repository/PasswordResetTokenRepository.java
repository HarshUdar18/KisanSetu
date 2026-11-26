package com.kisansetu.modules.auth.repository;

import com.kisansetu.modules.auth.entity.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, UUID> {
    List<PasswordResetToken> findByUserIdAndUsedFalse(UUID userId);
    Optional<PasswordResetToken> findTopByUserIdAndUsedFalseOrderByCreatedAtDesc(UUID userId);
}
