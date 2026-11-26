package com.kisansetu.product.repository;

import com.kisansetu.product.entity.ProductEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ProductRepo extends JpaRepository<ProductEntity, UUID> {
    List<ProductEntity> findByIsAvailableTrue();
    List<ProductEntity> findByCategoryIdAndIsAvailableTrue(UUID categoryId);
}
