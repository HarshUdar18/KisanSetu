package com.kisansetu.modules.payment.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.payment.dto.MockPaymentRequest;
import com.kisansetu.modules.payment.dto.PaymentDto;
import com.kisansetu.modules.payment.service.PaymentService;
import com.kisansetu.modules.payment.service.WalletService;
import com.kisansetu.modules.payment.service.WalletService.WalletTransactionDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/payments")
@Tag(name = "Payments", description = "Payment processing, gateway capability status, and wallet refunds")
public class PaymentController {

    private final PaymentService paymentService;
    private final WalletService walletService;

    public PaymentController(PaymentService paymentService, WalletService walletService) {
        this.paymentService = paymentService;
        this.walletService = walletService;
    }

    @GetMapping("/methods")
    @Operation(summary = "List configured payment methods and gateway status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMethods() {
        return ResponseEntity.ok(ApiResponse.ok("Payment methods retrieved", Map.of(
                "supportedMethods", List.of("UPI", "CARD", "NET_BANKING", "WALLET"),
                "sandboxEnabled", true,
                "liveGatewayConfigured", false,
                "recurringAutoDebitConfigured", false)));
    }

    @PostMapping("/refund")
    @Operation(summary = "Refund a payment to customer wallet atomically")
    public ResponseEntity<ApiResponse<WalletTransactionDto>> refundToWallet(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody Map<String, Object> body) {
        BigDecimal amount = new BigDecimal(String.valueOf(body.get("amount")));
        String orderIdRaw = body.get("orderId") != null ? String.valueOf(body.get("orderId")) : null;
        UUID orderId = orderIdRaw != null ? UUID.fromString(orderIdRaw) : null;
        String idempotencyKey = body.get("idempotencyKey") != null ? String.valueOf(body.get("idempotencyKey")) : null;
        String reason = body.get("reason") != null ? String.valueOf(body.get("reason")) : "Order refund";
        WalletTransactionDto txn = walletService.applyLedgerEntry(
                principal.getId(), "REFUND", amount, "ORDER_REFUND", orderId, idempotencyKey, reason,
                principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Refund credited to wallet", txn));
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
