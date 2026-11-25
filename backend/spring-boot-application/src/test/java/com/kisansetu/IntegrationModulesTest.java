package com.kisansetu;

import com.kisansetu.common.events.DomainEventPublisher;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class IntegrationModulesTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private DomainEventPublisher eventPublisher;

    @Test
    @WithMockUser(roles = "ADMIN")
    void adminOrdersFarmersKycSettlementEndpointsAccessible() throws Exception {
        mockMvc.perform(get("/api/v1/admin/orders")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/admin/farmers")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/admin/kyc")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/admin/settlements")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/admin/analytics/dashboard")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/admin/produce")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/demands")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/fpos")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/warehouses")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/inventory")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/collections")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/quality")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/logistics")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/coupons")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/farmer-store/products")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/schemes")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/weather")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/admin/subscriptions")).andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/inventory/movements")).andExpect(status().isOk());
    }

    @Test
    void domainEventPublisherHandlesTestProfileSafely() {
        assertDoesNotThrow(() ->
                eventPublisher.publish("order.created", "com.kisansetu.events.OrderCreated", Map.of("orderId", "test-123"))
        );
    }
}
