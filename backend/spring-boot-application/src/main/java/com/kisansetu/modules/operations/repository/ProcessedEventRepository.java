package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.ProcessedEvent;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProcessedEventRepository extends JpaRepository<ProcessedEvent, String> {
}
