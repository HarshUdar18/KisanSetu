package com.kisansetu.modules.farmer.repository;

import com.kisansetu.modules.farmer.entity.FarmerFarm;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FarmerFarmRepository extends JpaRepository<FarmerFarm, UUID> {
    List<FarmerFarm> findByFarmerIdOrderByCreatedAtDesc(UUID farmerId);
    Optional<FarmerFarm> findByIdAndFarmerId(UUID id, UUID farmerId);
}
