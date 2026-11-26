package com.kisansetu.modules.hub.repository;

import com.kisansetu.modules.hub.entity.HubAdminAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface HubAdminAssignmentRepository extends JpaRepository<HubAdminAssignment, UUID> {
    List<HubAdminAssignment> findByAdminUserIdAndActiveTrue(UUID adminUserId);
    List<HubAdminAssignment> findByHubIdAndActiveTrue(UUID hubId);
    Optional<HubAdminAssignment> findByHubIdAndAdminUserId(UUID hubId, UUID adminUserId);
    boolean existsByHubIdAndAdminUserIdAndActiveTrue(UUID hubId, UUID adminUserId);
}
