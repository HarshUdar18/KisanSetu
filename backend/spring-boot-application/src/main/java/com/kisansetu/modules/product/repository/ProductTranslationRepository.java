package com.kisansetu.modules.product.repository;

import com.kisansetu.modules.product.entity.ProductTranslation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductTranslationRepository extends JpaRepository<ProductTranslation, UUID> {
    List<ProductTranslation> findByProductId(UUID productId);
    Optional<ProductTranslation> findByProductIdAndLanguageCode(UUID productId, String languageCode);
}
