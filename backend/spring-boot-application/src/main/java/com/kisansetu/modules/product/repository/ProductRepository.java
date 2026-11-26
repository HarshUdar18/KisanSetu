package com.kisansetu.modules.product.repository;

import com.kisansetu.modules.product.entity.Product;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductRepository extends JpaRepository<Product, UUID> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT p FROM Product p WHERE p.id = :id")
    Optional<Product> findByIdForUpdate(@Param("id") UUID id);

    List<Product> findByCategoryIdAndIsAvailableTrue(UUID categoryId);
    List<Product> findByCategoryId(UUID categoryId);
    List<Product> findByIsAvailableTrue();
    Optional<Product> findByProductCodeIgnoreCase(String productCode);
    boolean existsByCategoryIdAndProductCodeIgnoreCase(UUID categoryId, String productCode);
    boolean existsByCanonicalNameIgnoreCase(String canonicalName);

    @Query("SELECT p FROM Product p WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(p.canonicalName) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(p.marathiName) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(p.productCode) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Product> searchProducts(@Param("query") String query);
}
