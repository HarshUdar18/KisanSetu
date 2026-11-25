package com.kisansetu.modules.operations.controller;

import com.kisansetu.common.events.DomainEventPublisher;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.farmer.FarmerListingService;
import com.kisansetu.modules.farmer.dto.FarmerListingDto;
import com.kisansetu.modules.farmer.repository.FarmerListingRepository;
import com.kisansetu.modules.operations.entity.*;
import com.kisansetu.modules.operations.repository.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Supply Chain & Platform Operations", description = "FPOs, Warehouses, Inventory, Collections, Quality, Logistics, Notifications, Support, Coupons")
public class OperationsController {

    private final FpoOrganizationRepository fpoRepo;
    private final WarehouseRepository warehouseRepo;
    private final InventoryItemRepository inventoryRepo;
    private final CollectionRecordRepository collectionRepo;
    private final QualityInspectionRepository qualityRepo;
    private final ShipmentRepository shipmentRepo;
    private final NotificationRecordRepository notificationRepo;
    private final SupportTicketRepository ticketRepo;
    private final CouponRepository couponRepo;
    private final FarmerListingRepository farmerListingRepo;
    private final DomainEventPublisher eventPublisher;

    public OperationsController(FpoOrganizationRepository fpoRepo,
                                WarehouseRepository warehouseRepo,
                                InventoryItemRepository inventoryRepo,
                                CollectionRecordRepository collectionRepo,
                                QualityInspectionRepository qualityRepo,
                                ShipmentRepository shipmentRepo,
                                NotificationRecordRepository notificationRepo,
                                SupportTicketRepository ticketRepo,
                                CouponRepository couponRepo,
                                FarmerListingRepository farmerListingRepo,
                                DomainEventPublisher eventPublisher) {
        this.fpoRepo = fpoRepo;
        this.warehouseRepo = warehouseRepo;
        this.inventoryRepo = inventoryRepo;
        this.collectionRepo = collectionRepo;
        this.qualityRepo = qualityRepo;
        this.shipmentRepo = shipmentRepo;
        this.notificationRepo = notificationRepo;
        this.ticketRepo = ticketRepo;
        this.couponRepo = couponRepo;
        this.farmerListingRepo = farmerListingRepo;
        this.eventPublisher = eventPublisher;
    }

    // --- FPOs ---
    @GetMapping("/fpos")
    @Operation(summary = "List active FPO organizations")
    public ResponseEntity<ApiResponse<List<FpoOrganization>>> listFpos() {
        return ResponseEntity.ok(ApiResponse.ok("FPOs retrieved", fpoRepo.findAll()));
    }

    @PostMapping("/admin/fpos")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<FpoOrganization>> createFpo(@RequestBody FpoOrganization fpo) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("FPO created", fpoRepo.save(fpo)));
    }

    // --- Public / Admin Produce Marketplace ---
    @GetMapping("/produce")
    @Operation(summary = "List all active farmer produce listings")
    public ResponseEntity<ApiResponse<List<FarmerListingDto>>> listActiveProduce() {
        List<FarmerListingDto> list = farmerListingRepo.findByIsAvailableTrueOrderByCreatedAtDesc()
                .stream().map(l -> FarmerListingDto.fromEntity(l, l.getFarmer().getPhone())).toList();
        return ResponseEntity.ok(ApiResponse.ok("Active produce retrieved", list));
    }

    @GetMapping("/admin/produce")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<FarmerListingDto>>> adminListAllProduce() {
        List<FarmerListingDto> list = farmerListingRepo.findAll()
                .stream().map(l -> FarmerListingDto.fromEntity(l, l.getFarmer().getPhone())).toList();
        return ResponseEntity.ok(ApiResponse.ok("All produce listings retrieved", list));
    }

    // --- Warehouses & Inventory ---
    @GetMapping("/warehouses")
    public ResponseEntity<ApiResponse<List<Warehouse>>> listWarehouses() {
        return ResponseEntity.ok(ApiResponse.ok("Warehouses retrieved", warehouseRepo.findAll()));
    }

    @GetMapping("/inventory")
    public ResponseEntity<ApiResponse<List<InventoryItem>>> listInventory() {
        return ResponseEntity.ok(ApiResponse.ok("Inventory retrieved", inventoryRepo.findAll()));
    }

    @PutMapping("/admin/inventory/{productId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<InventoryItem>> upsertInventory(
            @PathVariable UUID productId,
            @RequestBody Map<String, Object> body) {
        InventoryItem item = inventoryRepo.findByProductId(productId).orElseGet(() -> {
            InventoryItem n = new InventoryItem();
            n.setProductId(productId);
            return n;
        });
        if (body.get("availableKg") != null) item.setAvailableKg(new BigDecimal(body.get("availableKg").toString()));
        if (body.get("reservedKg") != null) item.setReservedKg(new BigDecimal(body.get("reservedKg").toString()));
        item.setUpdatedAt(Instant.now());
        InventoryItem saved = inventoryRepo.save(item);
        eventPublisher.publish("inventory.updated", "com.kisansetu.events.InventoryUpdated",
                Map.of("productId", productId.toString(), "availableKg", saved.getAvailableKg().toString()));
        return ResponseEntity.ok(ApiResponse.ok("Inventory updated", saved));
    }

    // --- Collections ---
    @GetMapping("/collections")
    public ResponseEntity<ApiResponse<List<CollectionRecord>>> listCollections(@AuthenticationPrincipal UserPrincipal principal) {
        boolean isAdmin = principal == null || principal.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        List<CollectionRecord> list = isAdmin
                ? collectionRepo.findAll()
                : collectionRepo.findByFarmerIdOrderByScheduledDateDesc(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Collections retrieved", list));
    }

    @PostMapping("/collections")
    public ResponseEntity<ApiResponse<CollectionRecord>> scheduleCollection(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody Map<String, Object> body) {
        CollectionRecord c = new CollectionRecord();
        c.setFarmerId(body.get("farmerId") != null ? UUID.fromString(body.get("farmerId").toString()) : principal.getId());
        c.setProductId(UUID.fromString(body.get("productId").toString()));
        c.setCollectionPoint(body.getOrDefault("collectionPoint", "Pune Central Hub").toString());
        c.setScheduledDate(body.get("scheduledDate") != null ? LocalDate.parse(body.get("scheduledDate").toString()) : LocalDate.now().plusDays(1));
        c.setQuantityKg(new BigDecimal(body.get("quantityKg").toString()));
        c.setGatePassCode("GP-" + System.currentTimeMillis() % 100000);
        CollectionRecord saved = collectionRepo.save(c);
        eventPublisher.publish("collection.scheduled", "com.kisansetu.events.CollectionScheduled",
                Map.of("collectionId", saved.getId().toString(), "farmerId", saved.getFarmerId().toString()));
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Collection scheduled", saved));
    }

    // --- Quality Inspections ---
    @GetMapping("/quality")
    public ResponseEntity<ApiResponse<List<QualityInspection>>> listQuality(@AuthenticationPrincipal UserPrincipal principal) {
        boolean isAdmin = principal == null || principal.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        List<QualityInspection> list = isAdmin
                ? qualityRepo.findAll()
                : qualityRepo.findByFarmerIdOrderByInspectedAtDesc(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Quality inspections retrieved", list));
    }

    @PostMapping("/admin/quality")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<QualityInspection>> recordQuality(@RequestBody QualityInspection qi) {
        QualityInspection saved = qualityRepo.save(qi);
        eventPublisher.publish("quality.completed", "com.kisansetu.events.QualityInspectionCompleted",
                Map.of("inspectionId", saved.getId().toString(), "grade", saved.getGrade(), "acceptedKg", saved.getAcceptedKg().toString()));
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Quality inspection recorded", saved));
    }

    // --- Logistics / Shipments ---
    @GetMapping("/logistics")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<Shipment>>> listShipments() {
        return ResponseEntity.ok(ApiResponse.ok("Shipments retrieved", shipmentRepo.findAll()));
    }

    @PostMapping("/admin/logistics")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Shipment>> assignShipment(@RequestBody Shipment s) {
        Shipment saved = shipmentRepo.save(s);
        eventPublisher.publish("shipment.created", "com.kisansetu.events.ShipmentCreated",
                Map.of("shipmentId", saved.getId().toString(), "status", saved.getStatus()));
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Shipment assigned", saved));
    }

    // --- Notifications ---
    @GetMapping("/notifications")
    public ResponseEntity<ApiResponse<List<NotificationRecord>>> listNotifications(@AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.ok("Notifications retrieved",
                notificationRepo.findByUserIdOrUserIdIsNullOrderByCreatedAtDesc(principal.getId())));
    }

    @PutMapping("/notifications/{id}/read")
    public ResponseEntity<ApiResponse<NotificationRecord>> markRead(@PathVariable UUID id) {
        NotificationRecord n = notificationRepo.findById(id)
                .orElseThrow(() -> new ApiException("NOT_FOUND", "Notification not found", HttpStatus.NOT_FOUND));
        n.setRead(true);
        return ResponseEntity.ok(ApiResponse.ok("Notification marked read", notificationRepo.save(n)));
    }

    @PostMapping("/admin/notifications")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<NotificationRecord>> broadcastNotification(@RequestBody NotificationRecord n) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Notification sent", notificationRepo.save(n)));
    }

    // --- Support Tickets ---
    @GetMapping("/support/tickets")
    public ResponseEntity<ApiResponse<List<SupportTicket>>> listTickets(@AuthenticationPrincipal UserPrincipal principal) {
        boolean isAdmin = principal.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        List<SupportTicket> list = isAdmin
                ? ticketRepo.findAllByOrderByCreatedAtDesc()
                : ticketRepo.findByUserIdOrderByCreatedAtDesc(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Support tickets retrieved", list));
    }

    @PostMapping("/support/tickets")
    public ResponseEntity<ApiResponse<SupportTicket>> createTicket(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody Map<String, String> body) {
        SupportTicket t = new SupportTicket();
        t.setUserId(principal.getId());
        t.setSubject(body.getOrDefault("subject", "General Inquiry"));
        t.setCategory(body.getOrDefault("category", "ORDER"));
        t.setDescription(body.getOrDefault("description", ""));
        t.setStatus("OPEN");
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Support ticket created", ticketRepo.save(t)));
    }

    @PutMapping("/admin/support/tickets/{id}/resolve")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<SupportTicket>> resolveTicket(
            @PathVariable UUID id,
            @RequestBody(required = false) Map<String, String> body) {
        SupportTicket t = ticketRepo.findById(id)
                .orElseThrow(() -> new ApiException("NOT_FOUND", "Ticket not found", HttpStatus.NOT_FOUND));
        t.setStatus("RESOLVED");
        if (body != null && body.get("resolutionNotes") != null) {
            t.setResolutionNotes(body.get("resolutionNotes"));
        }
        t.setUpdatedAt(Instant.now());
        return ResponseEntity.ok(ApiResponse.ok("Ticket resolved", ticketRepo.save(t)));
    }

    // --- Coupons ---
    @GetMapping("/coupons")
    public ResponseEntity<ApiResponse<List<Coupon>>> listCoupons() {
        return ResponseEntity.ok(ApiResponse.ok("Coupons retrieved", couponRepo.findAll()));
    }

    @GetMapping("/coupons/validate")
    public ResponseEntity<ApiResponse<Coupon>> validateCoupon(@RequestParam String code) {
        Coupon c = couponRepo.findByCodeIgnoreCaseAndIsActiveTrue(code.trim())
                .orElseThrow(() -> new ApiException("INVALID_COUPON", "Coupon code is invalid or expired", HttpStatus.BAD_REQUEST));
        return ResponseEntity.ok(ApiResponse.ok("Coupon valid", c));
    }
}
