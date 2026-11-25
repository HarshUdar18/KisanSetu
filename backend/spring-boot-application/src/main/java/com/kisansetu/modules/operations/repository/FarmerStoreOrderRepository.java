package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.FarmerStoreOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface FarmerStoreOrderRepository extends JpaRepository<FarmerStoreOrder, UUID> {
    List<FarmerStoreOrder> findByFarmerIdOrderByCreatedAtDesc(UUID farmerId);
}
