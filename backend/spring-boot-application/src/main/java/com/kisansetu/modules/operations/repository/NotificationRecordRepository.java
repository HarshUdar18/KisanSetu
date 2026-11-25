package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.NotificationRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface NotificationRecordRepository extends JpaRepository<NotificationRecord, UUID> {
    List<NotificationRecord> findByUserIdOrUserIdIsNullOrderByCreatedAtDesc(UUID userId);
}
