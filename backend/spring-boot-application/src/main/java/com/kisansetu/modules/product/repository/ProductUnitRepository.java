package com.kisansetu.modules.product.repository;

import com.kisansetu.modules.product.entity.ProductUnit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductUnitRepository extends JpaRepository<ProductUnit, UUID> {
    List<ProductUnit> findByIsActiveTrueOrderByCategoryAscCodeAsc();
    Optional<ProductUnit> findByCodeIgnoreCase(String code);
}
