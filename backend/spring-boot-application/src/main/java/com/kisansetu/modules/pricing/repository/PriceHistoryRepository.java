package com.kisansetu.modules.pricing.repository;

import com.kisansetu.modules.pricing.entity.PriceHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PriceHistoryRepository extends JpaRepository<PriceHistory, UUID> {
    List<PriceHistory> findByProductIdOrderByEffectiveDateDesc(UUID productId);
}
