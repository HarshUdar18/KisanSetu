package com.kisansetu.modules.product.repository;

import com.kisansetu.modules.product.entity.ProductVariant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductVariantRepository extends JpaRepository<ProductVariant, UUID> {
    List<ProductVariant> findByProductIdAndIsActiveTrue(UUID productId);
    Optional<ProductVariant> findBySkuIgnoreCase(String sku);
    boolean existsBySkuIgnoreCase(String sku);
}
