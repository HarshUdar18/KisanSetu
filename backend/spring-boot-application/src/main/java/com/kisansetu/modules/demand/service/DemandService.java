package com.kisansetu.modules.demand.service;

import com.kisansetu.common.events.DomainEventPublisher;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.demand.dto.DemandDto;
import com.kisansetu.modules.demand.entity.DemandRequest;
import com.kisansetu.modules.demand.repository.DemandRequestRepository;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.product.repository.ProductRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class DemandService {

    private final DemandRequestRepository demandRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final DomainEventPublisher eventPublisher;

    public DemandService(DemandRequestRepository demandRepository,
                         UserRepository userRepository,
                         ProductRepository productRepository,
                         DomainEventPublisher eventPublisher) {
        this.demandRepository = demandRepository;
        this.userRepository = userRepository;
        this.productRepository = productRepository;
        this.eventPublisher = eventPublisher;
    }

    @Transactional(readOnly = true)
    public List<DemandDto> listDemands(String status) {
        List<DemandRequest> list = (status != null && !status.isBlank())
                ? demandRepository.findByStatusOrderByCreatedAtDesc(status.toUpperCase())
                : demandRepository.findAllByOrderByCreatedAtDesc();
        return list.stream().map(DemandDto::fromEntity).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public DemandDto getDemand(UUID id) {
        DemandRequest demand = demandRepository.findById(id)
                .orElseThrow(() -> new ApiException("DEMAND_NOT_FOUND", "Demand request not found", HttpStatus.NOT_FOUND));
        return DemandDto.fromEntity(demand);
    }

    @Transactional
    public DemandDto createDemand(UUID requesterId, UUID productId, BigDecimal quantityKg,
                                  BigDecimal targetPricePerKg, LocalDate requiredByDate, String notes) {
        User requester = userRepository.findById(requesterId)
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "User not found", HttpStatus.NOT_FOUND));
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found", HttpStatus.NOT_FOUND));

        DemandRequest demand = new DemandRequest();
        demand.setRequester(requester);
        demand.setProduct(product);
        demand.setQuantityKg(quantityKg);
        demand.setTargetPricePerKg(targetPricePerKg);
        demand.setRequiredByDate(requiredByDate != null ? requiredByDate : LocalDate.now().plusDays(3));
        demand.setNotes(notes);
        demand.setStatus("OPEN");

        DemandRequest saved = demandRepository.save(demand);

        eventPublisher.publish("demand.created", "com.kisansetu.events.DemandCreated", Map.of(
                "demandId", saved.getId().toString(),
                "productId", product.getId().toString(),
                "productName", product.getName(),
                "quantityKg", quantityKg.toString()
        ));

        return DemandDto.fromEntity(saved);
    }

    @Transactional
    public DemandDto acceptDemand(UUID demandId, UUID farmerId, BigDecimal offeredPricePerKg, BigDecimal confirmedQuantityKg) {
        DemandRequest demand = demandRepository.findById(demandId)
                .orElseThrow(() -> new ApiException("DEMAND_NOT_FOUND", "Demand request not found", HttpStatus.NOT_FOUND));
        if (!"OPEN".equalsIgnoreCase(demand.getStatus())) {
            throw new ApiException("DEMAND_NOT_OPEN", "Demand is no longer open", HttpStatus.BAD_REQUEST);
        }

        demand.setStatus("ACCEPTED");
        demand.setAcceptedByFarmerId(farmerId);
        demand.setOfferedPricePerKg(offeredPricePerKg != null ? offeredPricePerKg : demand.getTargetPricePerKg());
        demand.setConfirmedQuantityKg(confirmedQuantityKg != null ? confirmedQuantityKg : demand.getQuantityKg());
        demand.setAcceptedAt(Instant.now());

        DemandRequest saved = demandRepository.save(demand);

        eventPublisher.publish("demand.accepted", "com.kisansetu.events.DemandAccepted", Map.of(
                "demandId", saved.getId().toString(),
                "farmerId", farmerId.toString(),
                "confirmedQuantityKg", saved.getConfirmedQuantityKg().toString()
        ));

        return DemandDto.fromEntity(saved);
    }
}
