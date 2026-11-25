package com.kisansetu.modules.order.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.order.dto.CheckoutSummaryDto;
import com.kisansetu.modules.order.dto.CreateOrderRequest;
import com.kisansetu.modules.order.dto.OrderDto;
import com.kisansetu.modules.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/orders")
@Tag(name = "Customer Orders", description = "Order placement, checkout summary calculation, and historical orders")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping
    @Operation(summary = "Get user order history")
    public ResponseEntity<ApiResponse<List<OrderDto>>> getOrders(@AuthenticationPrincipal UserPrincipal principal) {
        List<OrderDto> orders = orderService.getOrders(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Orders retrieved", orders));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get single order details by ID")
    public ResponseEntity<ApiResponse<OrderDto>> getOrder(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        OrderDto order = orderService.getOrder(principal.getId(), id);
        return ResponseEntity.ok(ApiResponse.ok("Order retrieved", order));
    }

    @GetMapping("/checkout/summary")
    @Operation(summary = "Calculate checkout summary with authoritative prices and serviceability")
    public ResponseEntity<ApiResponse<CheckoutSummaryDto>> getCheckoutSummary(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(required = false) UUID addressId) {
        CheckoutSummaryDto summary = orderService.getCheckoutSummary(principal.getId(), addressId);
        return ResponseEntity.ok(ApiResponse.ok("Checkout summary calculated", summary));
    }

    @PostMapping({ "", "/checkout" })
    @Operation(summary = "Create order from current cart (locks unit prices)")
    public ResponseEntity<ApiResponse<OrderDto>> createOrder(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateOrderRequest request) {
        OrderDto order = orderService.createOrderFromCart(principal.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Order placed in PENDING_PAYMENT status", order));
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "Cancel an order in PENDING_PAYMENT or CONFIRMED status")
    public ResponseEntity<ApiResponse<OrderDto>> cancelOrder(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) java.util.Map<String, String> body) {
        String reason = body != null ? body.get("reason") : null;
        OrderDto cancelled = orderService.cancelOrder(principal.getId(), id, reason);
        return ResponseEntity.ok(ApiResponse.ok("Order cancelled successfully", cancelled));
    }
}
