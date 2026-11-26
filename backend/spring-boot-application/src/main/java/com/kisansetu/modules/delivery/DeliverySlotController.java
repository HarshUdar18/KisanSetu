package com.kisansetu.modules.delivery;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.delivery.DeliverySlotService.DeliverySlotDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/delivery-slots")
@Tag(name = "Centralized Delivery Slots", description = "Single source of truth for subscription and fastest-delivery slots")
public class DeliverySlotController {

    private final DeliverySlotService deliverySlotService;

    public DeliverySlotController(DeliverySlotService deliverySlotService) {
        this.deliverySlotService = deliverySlotService;
    }

    @GetMapping
    @Operation(summary = "List active delivery slots by type (SUBSCRIPTION or FASTEST_DELIVERY) and locality")
    public ResponseEntity<ApiResponse<List<DeliverySlotDto>>> listSlots(
            @RequestParam(required = false) String slotType,
            @RequestParam(required = false) UUID localityId) {
        return ResponseEntity.ok(ApiResponse.ok("Delivery slots retrieved",
                deliverySlotService.listSlots(slotType, localityId)));
    }

    @PostMapping("/{slotId}/reserve")
    @Operation(summary = "Atomically reserve capacity in a delivery slot")
    public ResponseEntity<ApiResponse<Map<String, Object>>> reserveSlot(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID slotId,
            @RequestBody(required = false) Map<String, String> body) {
        UUID orderId = body != null && body.get("orderId") != null ? UUID.fromString(body.get("orderId")) : null;
        UUID subId = body != null && body.get("subscriptionId") != null ? UUID.fromString(body.get("subscriptionId")) : null;
        UUID reservationId = deliverySlotService.reserveSlot(slotId, principal.getId(), orderId, subId);
        return ResponseEntity.ok(ApiResponse.ok("Slot reserved", Map.of("reservationId", reservationId, "slotId", slotId)));
    }
}
