package com.kisansetu.modules.cart.repository;

import com.kisansetu.modules.cart.entity.WeeklyCart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface WeeklyCartRepository extends JpaRepository<WeeklyCart, UUID> {
    List<WeeklyCart> findByUserIdOrderByCreatedAtDesc(UUID userId);
    Optional<WeeklyCart> findByIdAndUserId(UUID id, UUID userId);
    Optional<WeeklyCart> findByUserIdAndStatus(UUID userId, String status);
}
