package com.kisansetu.auth.repository;

import com.kisansetu.auth.entity.AuthRefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface AuthRefreshTokenRepository extends JpaRepository<AuthRefreshToken, UUID> {
    Optional<AuthRefreshToken> findByToken(String token);
    Optional<AuthRefreshToken> findByUserIdAndRevokedFalse(UUID userId);
}
