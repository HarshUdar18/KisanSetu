package com.kisansetu.operations;

import com.kisansetu.common.events.DomainEventConsumer;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.operations.entity.InventoryItem;
import com.kisansetu.modules.operations.entity.ProcessedEvent;
import com.kisansetu.modules.operations.repository.InventoryItemRepository;
import com.kisansetu.modules.operations.repository.NotificationRecordRepository;
import com.kisansetu.modules.operations.repository.ProcessedEventRepository;
import com.kisansetu.modules.operations.repository.StockMovementRepository;
import com.kisansetu.modules.operations.service.StockConservationService;
import com.kisansetu.modules.order.entity.OrderItem;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.product.repository.ProductRepository;
import com.kisansetu.modules.settlement.repository.SettlementRepository;
import com.kisansetu.modules.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class StockConservationServiceTest {

    @Test
    void reservesAndReleasesStockAtomicallyAndPreventsOverselling() {
        ProductRepository productRepo = Mockito.mock(ProductRepository.class);
        InventoryItemRepository invRepo = Mockito.mock(InventoryItemRepository.class);
        StockMovementRepository moveRepo = Mockito.mock(StockMovementRepository.class);

        StockConservationService service = new StockConservationService(productRepo, invRepo, moveRepo);

        UUID productId = UUID.randomUUID();
        UUID orderId = UUID.randomUUID();
        Product p = new Product();
        p.setId(productId);
        p.setName("Desi Tomatoes");
        p.setStockQuantity(BigDecimal.valueOf(10));
        p.setAvailable(true);

        InventoryItem inv = new InventoryItem();
        inv.setProductId(productId);
        inv.setAvailableKg(BigDecimal.valueOf(10));
        inv.setReservedKg(BigDecimal.ZERO);

        when(productRepo.findByIdForUpdate(productId)).thenReturn(Optional.of(p));
        when(invRepo.findByProductIdForUpdate(productId)).thenReturn(Optional.of(inv));

        OrderItem item = new OrderItem();
        item.setProduct(p);
        item.setQuantity(BigDecimal.valueOf(6));

        service.reserveStockForOrder(orderId, List.of(item));
        assertEquals(BigDecimal.valueOf(4), p.getStockQuantity());
        assertEquals(BigDecimal.valueOf(6), inv.getReservedKg());
        verify(moveRepo, times(1)).save(any());

        // Attempting to reserve 5 more when only 4 left must throw INSUFFICIENT_STOCK
        OrderItem overItem = new OrderItem();
        overItem.setProduct(p);
        overItem.setQuantity(BigDecimal.valueOf(5));
        assertThrows(ApiException.class, () -> service.reserveStockForOrder(UUID.randomUUID(), List.of(overItem)));

        // Releasing original 6 restores stock
        service.releaseStockForOrder(orderId, List.of(item));
        assertEquals(BigDecimal.valueOf(10), p.getStockQuantity());
        assertEquals(BigDecimal.ZERO, inv.getReservedKg());
    }

    @Test
    void domainEventConsumerIsIdempotentAndPersistsNotifications() {
        ProcessedEventRepository processedRepo = Mockito.mock(ProcessedEventRepository.class);
        NotificationRecordRepository notifRepo = Mockito.mock(NotificationRecordRepository.class);
        StockConservationService stockService = Mockito.mock(StockConservationService.class);
        SettlementRepository settlementRepo = Mockito.mock(SettlementRepository.class);
        UserRepository userRepo = Mockito.mock(UserRepository.class);

        DomainEventConsumer consumer = new DomainEventConsumer(
                processedRepo, notifRepo, stockService, settlementRepo, userRepo);

        String eventId = UUID.randomUUID().toString();
        String farmerId = UUID.randomUUID().toString();
        Map<String, Object> envelope = Map.of(
                "eventId", eventId,
                "routingKey", "kyc.approved",
                "eventType", "com.kisansetu.events.KycApproved",
                "payload", Map.of("farmerId", farmerId)
        );

        when(processedRepo.existsById(eventId)).thenReturn(false).thenReturn(true);

        consumer.handleDomainEvent(envelope);
        consumer.handleDomainEvent(envelope); // duplicate delivery

        verify(notifRepo, times(1)).save(any());
        verify(processedRepo, times(1)).save(any(ProcessedEvent.class));
    }
}
