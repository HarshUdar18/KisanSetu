package com.kisansetu.modules.hub.repository;

import com.kisansetu.modules.hub.entity.Hub;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface HubRepository extends JpaRepository<Hub, UUID> {
    List<Hub> findByStatus(String status);
    Optional<Hub> findByCode(String code);
    boolean existsByCode(String code);
}
