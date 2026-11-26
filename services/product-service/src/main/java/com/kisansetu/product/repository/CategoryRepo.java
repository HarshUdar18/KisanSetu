package com.kisansetu.product.repository;

import com.kisansetu.product.entity.CategoryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CategoryRepo extends JpaRepository<CategoryEntity, UUID> {
    List<CategoryEntity> findByIsActiveTrueOrderByDisplayOrderAsc();
    Optional<CategoryEntity> findByCode(String code);
}
