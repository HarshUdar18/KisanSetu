package com.kisansetu.modules.tracking.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.tracking.dto.OrderTrackingTimelineDto;
import com.kisansetu.modules.tracking.service.TrackingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/orders/{orderId}/tracking")
@Tag(name = "Order Tracking", description = "End-to-end supply chain milestones from farm collection to customer delivery")
public class TrackingController {

    private final TrackingService trackingService;

    public TrackingController(TrackingService trackingService) {
        this.trackingService = trackingService;
    }

    @GetMapping
    @Operation(summary = "Get full supply chain tracking timeline for an order")
    public ResponseEntity<ApiResponse<OrderTrackingTimelineDto>> getTracking(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID orderId) {
        OrderTrackingTimelineDto tracking = trackingService.getOrderTracking(principal.getId(), orderId);
        return ResponseEntity.ok(ApiResponse.ok("Tracking timeline retrieved", tracking));
    }

    @PostMapping("/dev-advance")
    @Operation(summary = "DEVELOPMENT ONLY: Advance order tracking stage (1 to 9)",
               description = "Simulates physical transit stages: 1=Confirmed, 2=Farmer Harvesting, 3=Collection Point, 4=QC, 5=Warehouse, 6=Hub, 7=Delivery Station, 8=Out for Delivery, 9=Delivered")
    public ResponseEntity<ApiResponse<OrderTrackingTimelineDto>> advanceStageDev(
            @PathVariable UUID orderId,
            @RequestParam int stage) {
        OrderTrackingTimelineDto tracking = trackingService.advanceTrackingStageDev(orderId, stage);
        return ResponseEntity.ok(ApiResponse.ok("Development tracking stage advanced", tracking));
    }
}
