package com.kisansetu.modules.cart.service;

import com.kisansetu.modules.customer.entity.Address;
import com.kisansetu.modules.customer.repository.AddressRepository;
import com.kisansetu.modules.farmer.entity.FarmerListing;
import com.kisansetu.modules.farmer.repository.FarmerListingRepository;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.GeofenceValidationResult;
import com.kisansetu.modules.servicearea.service.GeofenceService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

@Service
public class WeeklyCartOptimizationService {

    private final FarmerListingRepository listingRepository;
    private final AddressRepository addressRepository;
    private final GeofenceService geofenceService;

    public WeeklyCartOptimizationService(
            FarmerListingRepository listingRepository,
            AddressRepository addressRepository,
            GeofenceService geofenceService) {
        this.listingRepository = listingRepository;
        this.addressRepository = addressRepository;
        this.geofenceService = geofenceService;
    }

    public record OptimizeItemInput(UUID productId, UUID preferredListingId, BigDecimal quantity) {}
    public record OptimizeRequest(UUID addressId, List<OptimizeItemInput> items) {}

    public record OptimizedItemResult(
            UUID productId,
            UUID selectedListingId,
            String status,
            BigDecimal requestedQuantity,
            BigDecimal unitPrice,
            BigDecimal priceDifference,
            boolean requiresCustomerApproval,
            String message
    ) {}

    public record OptimizeResponse(
            boolean feasible,
            boolean serviceable,
            String serviceabilityMessage,
            BigDecimal estimatedSubtotal,
            boolean requiresCustomerApproval,
            List<OptimizedItemResult> items
    ) {}

    @Transactional(readOnly = true)
    public OptimizeResponse optimize(UUID userId, OptimizeRequest request) {
        boolean serviceable = true;
        String serviceabilityMsg = "Address verified";
        if (request.addressId() != null && geofenceService.hasAnyActiveGeofence()) {
            Address addr = addressRepository.findByIdAndUserId(request.addressId(), userId).orElse(null);
            if (addr != null && addr.getLatitude() != null && addr.getLongitude() != null) {
                GeofenceValidationResult geo = geofenceService.validatePoint(
                        addr.getLatitude().doubleValue(), addr.getLongitude().doubleValue(), "CUSTOMER_DELIVERY");
                serviceable = geo.serviceable();
                serviceabilityMsg = geo.message();
            }
        }

        List<OptimizedItemResult> results = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        boolean allFeasible = serviceable;
        boolean anyApprovalNeeded = false;

        List<OptimizeItemInput> inputs = request.items() != null ? request.items() : List.of();
        for (OptimizeItemInput input : inputs) {
            BigDecimal qty = input.quantity() != null ? input.quantity() : BigDecimal.ONE;
            List<FarmerListing> candidates = listingRepository.findByProductIdAndIsAvailableTrue(input.productId())
                    .stream()
                    .filter(l -> "ACTIVE".equalsIgnoreCase(l.getStatus())
                            && l.getQuantityAvailable() != null
                            && l.getQuantityAvailable().compareTo(qty) >= 0)
                    .sorted(Comparator.comparing(FarmerListing::getPricePerUnit))
                    .toList();

            if (candidates.isEmpty()) {
                allFeasible = false;
                results.add(new OptimizedItemResult(
                        input.productId(), input.preferredListingId(), "UNAVAILABLE",
                        qty, BigDecimal.ZERO, BigDecimal.ZERO, false,
                        "No active farmer listing has sufficient stock; original basket preserved."
                ));
                continue;
            }

            FarmerListing preferred = input.preferredListingId() != null
                    ? candidates.stream().filter(c -> c.getId().equals(input.preferredListingId())).findFirst().orElse(null)
                    : null;

            if (preferred != null) {
                subtotal = subtotal.add(preferred.getPricePerUnit().multiply(qty));
                results.add(new OptimizedItemResult(
                        input.productId(), preferred.getId(), "AVAILABLE",
                        qty, preferred.getPricePerUnit(), BigDecimal.ZERO, false,
                        "Preferred farmer listing available."
                ));
            } else {
                FarmerListing best = candidates.get(0);
                boolean substituted = input.preferredListingId() != null;
                BigDecimal diff = BigDecimal.ZERO;
                if (substituted) {
                    FarmerListing orig = listingRepository.findById(input.preferredListingId()).orElse(null);
                    if (orig != null && orig.getPricePerUnit() != null) {
                        diff = best.getPricePerUnit().subtract(orig.getPricePerUnit());
                    }
                    anyApprovalNeeded = true;
                }
                subtotal = subtotal.add(best.getPricePerUnit().multiply(qty));
                results.add(new OptimizedItemResult(
                        input.productId(), best.getId(),
                        substituted ? "ALTERNATIVE_PROPOSED" : "AVAILABLE",
                        qty, best.getPricePerUnit(), diff, substituted,
                        substituted ? "Preferred listing unavailable; alternative farmer listing proposed for your approval."
                                : "Best eligible farmer listing selected."
                ));
            }
        }

        return new OptimizeResponse(allFeasible, serviceable, serviceabilityMsg, subtotal, anyApprovalNeeded, results);
    }
}
