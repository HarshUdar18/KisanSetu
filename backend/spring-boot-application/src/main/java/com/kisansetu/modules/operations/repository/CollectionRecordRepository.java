package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.CollectionRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface CollectionRecordRepository extends JpaRepository<CollectionRecord, UUID> {
    List<CollectionRecord> findByFarmerIdOrderByScheduledDateDesc(UUID farmerId);
}
