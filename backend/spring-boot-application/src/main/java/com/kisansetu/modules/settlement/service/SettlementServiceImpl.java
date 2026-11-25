package com.kisansetu.modules.settlement.service;

import com.kisansetu.common.events.DomainEventPublisher;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.settlement.SettlementService;
import com.kisansetu.modules.settlement.dto.SettlementDto;
import com.kisansetu.modules.settlement.entity.Settlement;
import com.kisansetu.modules.settlement.repository.SettlementRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class SettlementServiceImpl implements SettlementService {

    private final SettlementRepository settlementRepository;
    private final DomainEventPublisher eventPublisher;

    public SettlementServiceImpl(SettlementRepository settlementRepository,
                                 DomainEventPublisher eventPublisher) {
        this.settlementRepository = settlementRepository;
        this.eventPublisher = eventPublisher;
    }

    @Transactional(readOnly = true)
    public List<SettlementDto> getFarmerSettlements(UUID farmerId) {
        return settlementRepository.findByFarmerIdOrderByCreatedAtDesc(farmerId)
                .stream()
                .map(SettlementDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<SettlementDto> getAllSettlements() {
        return settlementRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(SettlementDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public SettlementDto getSettlement(UUID id) {
        Settlement s = settlementRepository.findById(id)
                .orElseThrow(() -> new ApiException("SETTLEMENT_NOT_FOUND", "Settlement not found", HttpStatus.NOT_FOUND));
        return SettlementDto.fromEntity(s);
    }

    @Transactional
    public SettlementDto authorizeSettlement(UUID id, UUID adminId, String remarks) {
        Settlement s = settlementRepository.findById(id)
                .orElseThrow(() -> new ApiException("SETTLEMENT_NOT_FOUND", "Settlement not found", HttpStatus.NOT_FOUND));

        if (!"PENDING".equalsIgnoreCase(s.getStatus())) {
            throw new ApiException("INVALID_SETTLEMENT_STATE", "Settlement is already " + s.getStatus(), HttpStatus.BAD_REQUEST);
        }

        s.setStatus("AUTHORIZED");
        s.setAuthorizedBy(adminId);
        s.setAuthorizedAt(Instant.now());
        s.setTransactionReference("DBT-" + System.currentTimeMillis());
        if (remarks != null) s.setRemarks(remarks);

        Settlement saved = settlementRepository.save(s);

        eventPublisher.publish("settlement.authorized", "com.kisansetu.events.SettlementAuthorized", Map.of(
                "settlementId", saved.getId().toString(),
                "farmerId", saved.getFarmer().getId().toString(),
                "netAmount", saved.getNetAmount().toString(),
                "authorizedBy", adminId.toString()
        ));

        return SettlementDto.fromEntity(saved);
    }
}
