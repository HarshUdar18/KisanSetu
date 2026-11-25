package com.kisansetu.modules.payment.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.payment.dto.MockPaymentRequest;
import com.kisansetu.modules.payment.dto.PaymentDto;
import com.kisansetu.modules.payment.service.PaymentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/payments")
@Tag(name = "Payments", description = "Mock payment execution with success/failure simulation and price verification")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping
    @Operation(summary = "Process mock payment (supports simulateSuccess=true/false and retry)")
    public ResponseEntity<ApiResponse<PaymentDto>> processPayment(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody MockPaymentRequest request) {
        PaymentDto payment = paymentService.processMockPayment(principal.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok("Payment processed", payment));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get payment transaction details by ID")
    public ResponseEntity<ApiResponse<PaymentDto>> getPayment(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        PaymentDto payment = paymentService.getPayment(principal.getId(), id);
        return ResponseEntity.ok(ApiResponse.ok("Payment details retrieved", payment));
    }
}
