package com.kisansetu.modules.collection;

import com.kisansetu.common.events.DomainEventPublisher;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.audit.AuditService;
import com.kisansetu.modules.farmer.entity.FarmerListing;
import com.kisansetu.modules.farmer.repository.FarmerListingRepository;
import com.kisansetu.modules.hub.entity.Hub;
import com.kisansetu.modules.hub.repository.HubRepository;
import com.kisansetu.modules.location.dto.LocationDtos.NearbyHubResult;
import com.kisansetu.modules.location.spatial.SpatialLocationService;
import com.kisansetu.modules.operations.entity.InventoryItem;
import com.kisansetu.modules.operations.entity.StockMovement;
import com.kisansetu.modules.operations.repository.InventoryItemRepository;
import com.kisansetu.modules.operations.repository.StockMovementRepository;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class FarmerCollectionWorkflowService {

    private final JdbcTemplate jdbcTemplate;
    private final HubRepository hubRepository;
    private final FarmerListingRepository listingRepository;
    private final InventoryItemRepository inventoryRepository;
    private final StockMovementRepository stockMovementRepository;
    private final SpatialLocationService spatialLocationService;
    private final AuditService auditService;
    private final DomainEventPublisher eventPublisher;

    public FarmerCollectionWorkflowService(
            JdbcTemplate jdbcTemplate,
            HubRepository hubRepository,
            FarmerListingRepository listingRepository,
            InventoryItemRepository inventoryRepository,
            StockMovementRepository stockMovementRepository,
            SpatialLocationService spatialLocationService,
            AuditService auditService,
            DomainEventPublisher eventPublisher) {
        this.jdbcTemplate = jdbcTemplate;
        this.hubRepository = hubRepository;
        this.listingRepository = listingRepository;
        this.inventoryRepository = inventoryRepository;
        this.stockMovementRepository = stockMovementRepository;
        this.spatialLocationService = spatialLocationService;
        this.auditService = auditService;
        this.eventPublisher = eventPublisher;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getAssignedCollectionPoint(UUID farmerId) {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList("""
                SELECT a.assignment_id, a.hub_id, a.status AS assignment_status, a.assigned_at,
                       h.code AS hub_code, h.name AS hub_name, h.hub_type, h.address_line,
                       h.village, h.district, h.state, h.pincode,
                       h.latitude, h.longitude, h.contact_name, h.contact_phone, h.status AS hub_status
                FROM farmer_collection_assignments a
                JOIN hubs h ON h.id = a.hub_id
                WHERE a.farmer_id = ? AND a.status = 'ACTIVE'
                ORDER BY a.assigned_at DESC
                LIMIT 1
                """, farmerId);
        return rows.isEmpty() ? null : rows.get(0);
    }

    @Transactional
    public Map<String, Object> assignCollectionPoint(UUID farmerId, UUID requestedHubId, Double lat, Double lon, UUID actorId, String reason) {
        UUID targetHubId = requestedHubId;
        if (targetHubId == null) {
            if (lat == null || lon == null) {
                throw new ApiException("LOCATION_REQUIRED", "Provide hubId or farm coordinates to discover nearest collection point", HttpStatus.BAD_REQUEST);
            }
            List<NearbyHubResult> nearby = spatialLocationService.findNearbyHubs(lat, lon, 150.0, 1, null);
            if (nearby.isEmpty()) {
                throw new ApiException("NO_COLLECTION_POINT_AVAILABLE", "No active collection point is currently available for your location.", HttpStatus.NOT_FOUND);
            }
            targetHubId = UUID.fromString(nearby.get(0).hubId());
        }

        Hub hub = hubRepository.findById(targetHubId)
                .orElseThrow(() -> new ApiException("HUB_NOT_FOUND", "Collection point not found", HttpStatus.NOT_FOUND));
        if (!"ACTIVE".equalsIgnoreCase(hub.getStatus())) {
            throw new ApiException("HUB_INACTIVE", "Cannot assign an inactive collection point", HttpStatus.BAD_REQUEST);
        }

        jdbcTemplate.update("""
                UPDATE farmer_collection_assignments
                SET status = 'REASSIGNED', ended_at = NOW()
                WHERE farmer_id = ? AND status = 'ACTIVE'
                """, farmerId);

        UUID assignmentId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO farmer_collection_assignments (assignment_id, farmer_id, hub_id, status, assigned_by, reason)
                VALUES (?, ?, ?, 'ACTIVE', ?, ?)
                """, assignmentId, farmerId, hub.getId(), actorId, reason != null ? reason : "Farmer collection point assignment");

        auditService.logEvent(actorId, "COLLECTION_POINT_ASSIGNED", "FARMER_ASSIGNMENT", assignmentId.toString(),
                "Assigned farmer " + farmerId + " to hub " + hub.getCode(), null);

        return getAssignedCollectionPoint(farmerId);
    }

    @Transactional
    public Map<String, Object> createCollectionRequest(UUID farmerId, UUID listingId, UUID productId, UUID hubId, BigDecimal quantityKg, LocalDate scheduledDate) {
        if (quantityKg == null || quantityKg.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApiException("INVALID_QUANTITY", "Quantity must be greater than zero", HttpStatus.BAD_REQUEST);
        }
        UUID resolvedProductId = productId;
        if (listingId != null) {
            FarmerListing listing = listingRepository.findByIdAndFarmerId(listingId, farmerId)
                    .orElseThrow(() -> new ApiException("LISTING_NOT_FOUND", "Listing not found or unauthorized", HttpStatus.NOT_FOUND));
            if (!Boolean.TRUE.equals(listing.getIsAvailable()) || !"ACTIVE".equalsIgnoreCase(listing.getStatus())) {
                throw new ApiException("LISTING_INACTIVE", "Produce listing must be active before creating a collection request", HttpStatus.BAD_REQUEST);
            }
            if (listing.getQuantityAvailable() == null || listing.getQuantityAvailable().compareTo(quantityKg) < 0) {
                throw new ApiException("INSUFFICIENT_LISTING_STOCK", "Requested quantity exceeds available listing stock", HttpStatus.BAD_REQUEST);
            }
            resolvedProductId = listing.getProduct().getId();
        }
        if (resolvedProductId == null) {
            throw new ApiException("PRODUCT_REQUIRED", "productId or listingId is required", HttpStatus.BAD_REQUEST);
        }

        Hub hub = hubRepository.findById(hubId)
                .orElseThrow(() -> new ApiException("HUB_NOT_FOUND", "Collection point not found", HttpStatus.NOT_FOUND));
        if (!"ACTIVE".equalsIgnoreCase(hub.getStatus())) {
            throw new ApiException("HUB_INACTIVE", "Selected collection point is not active", HttpStatus.BAD_REQUEST);
        }

        UUID collectionId = UUID.randomUUID();
        String gatePass = "GP-" + (10000 + Math.abs(collectionId.hashCode() % 90000));
        LocalDate date = scheduledDate != null ? scheduledDate : LocalDate.now().plusDays(1);

        jdbcTemplate.update("""
                INSERT INTO collections (id, farmer_id, product_id, hub_id, listing_id, collection_point, scheduled_date, quantity_kg, status, gate_pass_code)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'REQUESTED', ?)
                """, collectionId, farmerId, resolvedProductId, hub.getId(), listingId, hub.getName(), date, quantityKg, gatePass);

        eventPublisher.publish("collection.requested", "com.kisansetu.events.CollectionRequested",
                Map.of("collectionId", collectionId.toString(), "farmerId", farmerId.toString(), "hubId", hub.getId().toString()));

        return jdbcTemplate.queryForMap("SELECT * FROM collections WHERE id = ?", collectionId);
    }

    @Transactional
    public Map<String, Object> recordInspection(UUID operatorId, UUID collectionId, BigDecimal receivedKg, BigDecimal acceptedKg, BigDecimal rejectedKg, String grade, String remarks, String rejectionReason) {
        Map<String, Object> col = jdbcTemplate.queryForMap("SELECT * FROM collections WHERE id = ?", collectionId);
        if (receivedKg == null || acceptedKg == null || acceptedKg.compareTo(BigDecimal.ZERO) < 0) {
            throw new ApiException("INVALID_INSPECTION_QTY", "Received and accepted quantities must be valid", HttpStatus.BAD_REQUEST);
        }
        BigDecimal rejected = rejectedKg != null ? rejectedKg : receivedKg.subtract(acceptedKg).max(BigDecimal.ZERO);

        UUID inspectionId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO quality_inspections (id, collection_id, farmer_id, product_id, grade, accepted_kg, rejected_kg, notes, inspector_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                inspectionId,
                collectionId,
                UUID.fromString(col.get("farmer_id").toString()),
                UUID.fromString(col.get("product_id").toString()),
                grade != null ? grade : "A",
                acceptedKg,
                rejected,
                remarks,
                operatorId
        );

        jdbcTemplate.update("""
                UPDATE collections
                SET received_kg = ?, accepted_kg = ?, rejected_kg = ?, rejection_reason = ?, status = 'INSPECTED'
                WHERE id = ?
                """, receivedKg, acceptedKg, rejected, rejectionReason, collectionId);

        auditService.logEvent(operatorId, "COLLECTION_INSPECTED", "COLLECTION", collectionId.toString(),
                "Accepted: " + acceptedKg + " kg, Rejected: " + rejected + " kg, Grade: " + grade, null);

        return Map.of("inspectionId", inspectionId, "collectionId", collectionId, "acceptedKg", acceptedKg, "rejectedKg", rejected, "status", "INSPECTED");
    }

    @Transactional
    public Map<String, Object> createStockTransfer(UUID operatorId, UUID collectionId, UUID destinationWarehouseId) {
        Map<String, Object> col = jdbcTemplate.queryForMap("SELECT * FROM collections WHERE id = ?", collectionId);
        if (!"INSPECTED".equalsIgnoreCase(String.valueOf(col.get("status")))) {
            throw new ApiException("COLLECTION_NOT_INSPECTED", "Collection must complete quality inspection before stock transfer", HttpStatus.BAD_REQUEST);
        }
        BigDecimal acceptedKg = (BigDecimal) col.get("accepted_kg");
        if (acceptedKg == null || acceptedKg.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApiException("NO_ACCEPTED_STOCK", "Cannot transfer zero accepted quantity", HttpStatus.BAD_REQUEST);
        }

        UUID transferId = UUID.randomUUID();
        UUID sourceHubId = col.get("hub_id") != null ? UUID.fromString(col.get("hub_id").toString()) : null;
        UUID productId = UUID.fromString(col.get("product_id").toString());
        UUID farmerId = UUID.fromString(col.get("farmer_id").toString());

        jdbcTemplate.update("""
                INSERT INTO stock_transfers (
                    transfer_id, collection_id, source_hub_id, destination_warehouse_id,
                    product_id, farmer_id, dispatched_kg, status, dispatched_by, dispatched_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, 'IN_TRANSIT', ?, NOW())
                """, transferId, collectionId, sourceHubId, destinationWarehouseId, productId, farmerId, acceptedKg, operatorId);

        jdbcTemplate.update("UPDATE collections SET status = 'TRANSFERRED' WHERE id = ?", collectionId);

        return jdbcTemplate.queryForMap("SELECT * FROM stock_transfers WHERE transfer_id = ?", transferId);
    }

    @Transactional
    public Map<String, Object> confirmWarehouseReceipt(UUID warehouseOperatorId, UUID transferId, BigDecimal receivedKg) {
        Map<String, Object> transfer = jdbcTemplate.queryForMap(
                "SELECT * FROM stock_transfers WHERE transfer_id = ? FOR UPDATE", transferId);
        String currentStatus = String.valueOf(transfer.get("status"));
        if ("COMPLETED".equalsIgnoreCase(currentStatus)) {
            throw new ApiException("TRANSFER_ALREADY_COMPLETED", "Stock transfer has already been received", HttpStatus.CONFLICT);
        }
        if (receivedKg == null || receivedKg.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApiException("INVALID_RECEIVED_QTY", "Received quantity must be greater than zero", HttpStatus.BAD_REQUEST);
        }

        UUID productId = UUID.fromString(transfer.get("product_id").toString());
        UUID warehouseId = UUID.fromString(transfer.get("destination_warehouse_id").toString());

        jdbcTemplate.update("""
                UPDATE stock_transfers
                SET received_kg = ?, status = 'COMPLETED', received_by = ?, received_at = NOW()
                WHERE transfer_id = ?
                """, receivedKg, warehouseOperatorId, transferId);

        InventoryItem item = inventoryRepository.findByProductId(productId).orElseGet(() -> {
            InventoryItem n = new InventoryItem();
            n.setProductId(productId);
            n.setWarehouseId(warehouseId);
            n.setAvailableKg(BigDecimal.ZERO);
            n.setReservedKg(BigDecimal.ZERO);
            return n;
        });
        item.setAvailableKg(item.getAvailableKg().add(receivedKg));
        item.setUpdatedAt(Instant.now());
        inventoryRepository.save(item);

        StockMovement mv = new StockMovement(
                productId,
                warehouseId,
                "WAREHOUSE_RECEIPT",
                receivedKg,
                transferId,
                "Confirmed warehouse receipt for transfer " + transferId
        );
        stockMovementRepository.save(mv);

        eventPublisher.publish("warehouse.stock_received", "com.kisansetu.events.WarehouseStockReceived",
                Map.of("transferId", transferId.toString(), "productId", productId.toString(), "receivedKg", receivedKg.toString()));

        return jdbcTemplate.queryForMap("SELECT * FROM stock_transfers WHERE transfer_id = ?", transferId);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> listFarmerTransfers(UUID farmerId) {
        return jdbcTemplate.queryForList(
                "SELECT * FROM stock_transfers WHERE farmer_id = ? ORDER BY created_at DESC",
                farmerId
        );
    }
}
