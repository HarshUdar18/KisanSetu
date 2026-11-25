package com.kisansetu.modules.audit;

import com.kisansetu.modules.audit.entity.AuditLog;
import com.kisansetu.modules.audit.repository.AuditLogRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class AuditService {

    private static final Logger log = LoggerFactory.getLogger(AuditService.class);
    private final AuditLogRepository auditLogRepository;

    public AuditService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    public void logEvent(UUID userId, String action, String entityType, String entityId, String metadata, String ipAddress) {
        try {
            AuditLog auditLog = new AuditLog(userId, action, entityType, entityId, metadata, ipAddress);
            auditLogRepository.save(auditLog);
            log.info("AUDIT EVENT: action='{}' user='{}' entity='{}:{}'", action, userId, entityType, entityId);
        } catch (Exception e) {
            log.error("Failed to persist audit log: {}", e.getMessage());
        }
    }
}
