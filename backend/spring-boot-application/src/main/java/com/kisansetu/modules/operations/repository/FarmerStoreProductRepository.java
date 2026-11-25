package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.FarmerStoreProduct;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface FarmerStoreProductRepository extends JpaRepository<FarmerStoreProduct, UUID> {
    List<FarmerStoreProduct> findByIsAvailableTrue();
}
