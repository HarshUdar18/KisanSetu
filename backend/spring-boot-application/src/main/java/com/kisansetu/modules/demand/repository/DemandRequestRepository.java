package com.kisansetu.modules.demand.repository;

import com.kisansetu.modules.demand.entity.DemandRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DemandRequestRepository extends JpaRepository<DemandRequest, UUID> {
    List<DemandRequest> findByStatusOrderByCreatedAtDesc(String status);
    List<DemandRequest> findAllByOrderByCreatedAtDesc();
    List<DemandRequest> findByAcceptedByFarmerIdOrderByAcceptedAtDesc(UUID farmerId);
}
