package com.kisansetu.modules.analytics.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.demand.repository.DemandRequestRepository;
import com.kisansetu.modules.farmer.repository.FarmerListingRepository;
import com.kisansetu.modules.farmer.repository.FarmerProfileRepository;
import com.kisansetu.modules.kyc.repository.KycSubmissionRepository;
import com.kisansetu.modules.operations.repository.FpoOrganizationRepository;
import com.kisansetu.modules.operations.repository.SupportTicketRepository;
import com.kisansetu.modules.order.entity.Order;
import com.kisansetu.modules.order.repository.OrderRepository;
import com.kisansetu.modules.product.repository.ProductRepository;
import com.kisansetu.modules.settlement.entity.Settlement;
import com.kisansetu.modules.settlement.repository.SettlementRepository;
import com.kisansetu.modules.user.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/analytics")
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "Admin Analytics", description = "Real-time database aggregations for Admin Dashboard")
public class AnalyticsController {

    private final UserRepository userRepository;
    private final FarmerProfileRepository farmerRepo;
    private final ProductRepository productRepo;
    private final FarmerListingRepository listingRepo;
    private final OrderRepository orderRepo;
    private final KycSubmissionRepository kycRepo;
    private final DemandRequestRepository demandRepo;
    private final SettlementRepository settlementRepo;
    private final FpoOrganizationRepository fpoRepo;
    private final SupportTicketRepository ticketRepo;

    public AnalyticsController(UserRepository userRepository,
                               FarmerProfileRepository farmerRepo,
                               ProductRepository productRepo,
                               FarmerListingRepository listingRepo,
                               OrderRepository orderRepo,
                               KycSubmissionRepository kycRepo,
                               DemandRequestRepository demandRepo,
                               SettlementRepository settlementRepo,
                               FpoOrganizationRepository fpoRepo,
                               SupportTicketRepository ticketRepo) {
        this.userRepository = userRepository;
        this.farmerRepo = farmerRepo;
        this.productRepo = productRepo;
        this.listingRepo = listingRepo;
        this.orderRepo = orderRepo;
        this.kycRepo = kycRepo;
        this.demandRepo = demandRepo;
        this.settlementRepo = settlementRepo;
        this.fpoRepo = fpoRepo;
        this.ticketRepo = ticketRepo;
    }

    @GetMapping("/dashboard")
    @Operation(summary = "Compute live platform KPIs from PostgreSQL")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDashboardKpis() {
        List<Order> orders = orderRepo.findAll();
        BigDecimal totalRevenue = orders.stream()
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        List<Settlement> settlements = settlementRepo.findAll();
        BigDecimal pendingSettlementAmount = settlements.stream()
                .filter(s -> "PENDING".equalsIgnoreCase(s.getStatus()))
                .map(Settlement::getNetAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        long pendingKyc = kycRepo.findByStatusOrderBySubmittedAtDesc("UNDER_REVIEW").size();
        long openDemands = demandRepo.findByStatusOrderByCreatedAtDesc("OPEN").size();
        long openTickets = ticketRepo.findAll().stream().filter(t -> "OPEN".equalsIgnoreCase(t.getStatus())).count();

        Map<String, Object> kpis = new HashMap<>();
        kpis.put("totalUsers", userRepository.count());
        kpis.put("totalFarmers", farmerRepo.count());
        kpis.put("totalProducts", productRepo.count());
        kpis.put("activeProduceListings", listingRepo.findByIsAvailableTrueOrderByCreatedAtDesc().size());
        kpis.put("totalOrders", orders.size());
        kpis.put("totalRevenue", totalRevenue);
        kpis.put("pendingKycCount", pendingKyc);
        kpis.put("openDemandCount", openDemands);
        kpis.put("pendingSettlementAmount", pendingSettlementAmount);
        kpis.put("activeFpoCount", fpoRepo.count());
        kpis.put("openSupportTickets", openTickets);

        return ResponseEntity.ok(ApiResponse.ok("Dashboard analytics computed", kpis));
    }
}
