package com.kisansetu.modules.collection;

import com.kisansetu.common.events.DomainEventPublisher;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.audit.AuditService;
import com.kisansetu.modules.farmer.repository.FarmerListingRepository;
import com.kisansetu.modules.hub.entity.Hub;
import com.kisansetu.modules.hub.repository.HubRepository;
import com.kisansetu.modules.location.spatial.SpatialLocationService;
import com.kisansetu.modules.operations.repository.InventoryItemRepository;
import com.kisansetu.modules.operations.repository.StockMovementRepository;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class FarmerCollectionWorkflowTest {

    @Test
    void assignCollectionPoint_rejectsInactiveHub() {
        HubRepository hubRepo = mock(HubRepository.class);
        Hub inactiveHub = new Hub();
        inactiveHub.setId(UUID.randomUUID());
        inactiveHub.setStatus("INACTIVE");
        when(hubRepo.findById(inactiveHub.getId())).thenReturn(Optional.of(inactiveHub));

        FarmerCollectionWorkflowService service = new FarmerCollectionWorkflowService(
                mock(JdbcTemplate.class),
                hubRepo,
                mock(FarmerListingRepository.class),
                mock(InventoryItemRepository.class),
                mock(StockMovementRepository.class),
                mock(SpatialLocationService.class),
                mock(AuditService.class),
                mock(DomainEventPublisher.class)
        );

        ApiException ex = assertThrows(ApiException.class, () ->
                service.assignCollectionPoint(UUID.randomUUID(), inactiveHub.getId(), null, null, UUID.randomUUID(), "test"));
        assertEquals("HUB_INACTIVE", ex.getCode());
    }

    @Test
    void createCollectionRequest_rejectsNonPositiveQuantity() {
        FarmerCollectionWorkflowService service = new FarmerCollectionWorkflowService(
                mock(JdbcTemplate.class),
                mock(HubRepository.class),
                mock(FarmerListingRepository.class),
                mock(InventoryItemRepository.class),
                mock(StockMovementRepository.class),
                mock(SpatialLocationService.class),
                mock(AuditService.class),
                mock(DomainEventPublisher.class)
        );

        ApiException ex = assertThrows(ApiException.class, () ->
                service.createCollectionRequest(UUID.randomUUID(), null, UUID.randomUUID(), UUID.randomUUID(), BigDecimal.ZERO, null));
        assertEquals("INVALID_QUANTITY", ex.getCode());
    }
}
