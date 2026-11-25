package com.kisansetu.modules.pricing.repository;

import com.kisansetu.modules.pricing.entity.MarketPrice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface MarketPriceRepository extends JpaRepository<MarketPrice, UUID> {
    Optional<MarketPrice> findByProductId(UUID productId);
}
