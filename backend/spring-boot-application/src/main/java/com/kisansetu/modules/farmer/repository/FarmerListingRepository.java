package com.kisansetu.modules.farmer.repository;

import com.kisansetu.modules.farmer.entity.FarmerListing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface FarmerListingRepository extends JpaRepository<FarmerListing, UUID> {

    List<FarmerListing> findByFarmerIdOrderByCreatedAtDesc(UUID farmerId);

    List<FarmerListing> findByProductIdAndIsAvailableTrue(UUID productId);

    Optional<FarmerListing> findByIdAndFarmerId(UUID id, UUID farmerId);

    List<FarmerListing> findByIsAvailableTrueOrderByCreatedAtDesc();
}
