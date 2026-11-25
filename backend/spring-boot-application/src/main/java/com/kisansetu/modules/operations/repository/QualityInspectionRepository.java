package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.QualityInspection;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface QualityInspectionRepository extends JpaRepository<QualityInspection, UUID> {
    List<QualityInspection> findByFarmerIdOrderByInspectedAtDesc(UUID farmerId);
}
