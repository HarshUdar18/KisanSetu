package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.SupportTicket;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface SupportTicketRepository extends JpaRepository<SupportTicket, UUID> {
    List<SupportTicket> findByUserIdOrderByCreatedAtDesc(UUID userId);
    List<SupportTicket> findAllByOrderByCreatedAtDesc();
}
