package com.kisansetu.modules.settlement.repository;

import com.kisansetu.modules.settlement.entity.Settlement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SettlementRepository extends JpaRepository<Settlement, UUID> {
    List<Settlement> findByFarmerIdOrderByCreatedAtDesc(UUID farmerId);
    List<Settlement> findAllByOrderByCreatedAtDesc();
}
