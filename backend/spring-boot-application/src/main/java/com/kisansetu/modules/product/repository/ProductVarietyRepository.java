package com.kisansetu.modules.product.repository;

import com.kisansetu.modules.product.entity.ProductVariety;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductVarietyRepository extends JpaRepository<ProductVariety, UUID> {
    List<ProductVariety> findByProductIdAndIsActiveTrueOrderByVarietyNameAsc(UUID productId);
    boolean existsByProductIdAndVarietyCodeIgnoreCase(UUID productId, String varietyCode);
}
