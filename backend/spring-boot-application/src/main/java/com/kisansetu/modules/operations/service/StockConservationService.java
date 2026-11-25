package com.kisansetu.modules.operations.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.operations.entity.InventoryItem;
import com.kisansetu.modules.operations.entity.StockMovement;
import com.kisansetu.modules.operations.repository.InventoryItemRepository;
import com.kisansetu.modules.operations.repository.StockMovementRepository;
import com.kisansetu.modules.order.entity.OrderItem;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.product.repository.ProductRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class StockConservationService {

    private final ProductRepository productRepository;
    private final InventoryItemRepository inventoryRepository;
    private final StockMovementRepository movementRepository;

    public StockConservationService(ProductRepository productRepository,
                                    InventoryItemRepository inventoryRepository,
                                    StockMovementRepository movementRepository) {
        this.productRepository = productRepository;
        this.inventoryRepository = inventoryRepository;
        this.movementRepository = movementRepository;
    }

    @Transactional
    public void reserveStockForOrder(UUID orderId, List<OrderItem> items) {
        for (OrderItem item : items) {
            UUID productId = item.getProduct().getId();
            BigDecimal qty = item.getQuantity();

            Product product = productRepository.findByIdForUpdate(productId)
                    .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found", HttpStatus.NOT_FOUND));

            if (product.getStockQuantity().compareTo(qty) < 0) {
                throw new ApiException("INSUFFICIENT_STOCK",
                        "Insufficient stock for " + product.getName() + ". Available: " + product.getStockQuantity(),
                        HttpStatus.CONFLICT);
            }

            product.setStockQuantity(product.getStockQuantity().subtract(qty));
            if (product.getStockQuantity().compareTo(BigDecimal.ZERO) <= 0) {
                product.setAvailable(false);
            }
            productRepository.save(product);

            inventoryRepository.findByProductIdForUpdate(productId).ifPresent(inv -> {
                inv.setAvailableKg(inv.getAvailableKg().subtract(qty).max(BigDecimal.ZERO));
                inv.setReservedKg(inv.getReservedKg().add(qty));
                inv.setUpdatedAt(Instant.now());
                inventoryRepository.save(inv);
            });

            movementRepository.save(new StockMovement(
                    productId, null, "RESERVED", qty, orderId,
                    "Stock reserved for order " + orderId
            ));
        }
    }

    @Transactional
    public void releaseStockForOrder(UUID orderId, List<OrderItem> items) {
        for (OrderItem item : items) {
            UUID productId = item.getProduct().getId();
            BigDecimal qty = item.getQuantity();

            productRepository.findByIdForUpdate(productId).ifPresent(product -> {
                product.setStockQuantity(product.getStockQuantity().add(qty));
                product.setAvailable(true);
                productRepository.save(product);
            });

            inventoryRepository.findByProductIdForUpdate(productId).ifPresent(inv -> {
                inv.setAvailableKg(inv.getAvailableKg().add(qty));
                inv.setReservedKg(inv.getReservedKg().subtract(qty).max(BigDecimal.ZERO));
                inv.setUpdatedAt(Instant.now());
                inventoryRepository.save(inv);
            });

            movementRepository.save(new StockMovement(
                    productId, null, "RELEASED", qty, orderId,
                    "Stock released on order cancellation " + orderId
            ));
        }
    }

    @Transactional
    public void recordQualityInbound(UUID inspectionId, UUID productId, BigDecimal acceptedKg) {
        if (acceptedKg == null || acceptedKg.compareTo(BigDecimal.ZERO) <= 0) return;

        productRepository.findByIdForUpdate(productId).ifPresent(product -> {
            product.setStockQuantity(product.getStockQuantity().add(acceptedKg));
            product.setAvailable(true);
            productRepository.save(product);
        });

        InventoryItem inv = inventoryRepository.findByProductIdForUpdate(productId).orElseGet(() -> {
            InventoryItem n = new InventoryItem();
            n.setProductId(productId);
            return n;
        });
        inv.setAvailableKg(inv.getAvailableKg().add(acceptedKg));
        inv.setUpdatedAt(Instant.now());
        inventoryRepository.save(inv);

        movementRepository.save(new StockMovement(
                productId, inv.getWarehouseId(), "QUALITY_INBOUND", acceptedKg, inspectionId,
                "Quality-approved produce added to warehouse inventory"
        ));
    }

    @Transactional
    public void recordShipmentOutbound(UUID shipmentId, UUID productId, BigDecimal qtyKg) {
        if (qtyKg == null || qtyKg.compareTo(BigDecimal.ZERO) <= 0) return;

        inventoryRepository.findByProductIdForUpdate(productId).ifPresent(inv -> {
            inv.setReservedKg(inv.getReservedKg().subtract(qtyKg).max(BigDecimal.ZERO));
            inv.setUpdatedAt(Instant.now());
            inventoryRepository.save(inv);

            movementRepository.save(new StockMovement(
                    productId, inv.getWarehouseId(), "SHIPMENT_OUTBOUND", qtyKg, shipmentId,
                    "Dispatched on shipment " + shipmentId
            ));
        });
    }
}
