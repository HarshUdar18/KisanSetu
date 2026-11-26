package com.kisansetu.product.repository;

import com.kisansetu.product.entity.MarketPriceEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface MarketPriceRepo extends JpaRepository<MarketPriceEntity, UUID> {
    Optional<MarketPriceEntity> findByProductId(UUID productId);
}
