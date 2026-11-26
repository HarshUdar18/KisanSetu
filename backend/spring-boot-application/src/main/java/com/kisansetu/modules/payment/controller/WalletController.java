package com.kisansetu.modules.payment.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.payment.service.WalletService;
import com.kisansetu.modules.payment.service.WalletService.WalletSummaryDto;
import com.kisansetu.modules.payment.service.WalletService.WalletTransactionDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "Customer Wallet & Ledger", description = "Customer wallet balance, atomic transaction ledger, and admin adjustments")
public class WalletController {

    private final WalletService walletService;

    public WalletController(WalletService walletService) {
        this.walletService = walletService;
    }

    public record AdminWalletAdjustRequest(
            String transactionType,
            BigDecimal amount,
            String idempotencyKey,
            String description
    ) {}

    @GetMapping("/wallet")
    @Operation(summary = "Get authenticated customer wallet balance and recent transactions")
    public ResponseEntity<ApiResponse<WalletSummaryDto>> getWallet(@AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.ok("Wallet retrieved", walletService.getWalletSummary(principal.getId())));
    }

    @GetMapping("/wallet/transactions")
    @Operation(summary = "Get paginated wallet transaction history")
    public ResponseEntity<ApiResponse<List<WalletTransactionDto>>> getTransactions(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.ok("Wallet transactions retrieved",
                walletService.getTransactions(principal.getId(), page, size)));
    }

    @GetMapping("/wallet/transactions/{transactionId}")
    @Operation(summary = "Get single wallet transaction detail")
    public ResponseEntity<ApiResponse<WalletTransactionDto>> getTransaction(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID transactionId) {
        return ResponseEntity.ok(ApiResponse.ok("Wallet transaction retrieved",
                walletService.getTransaction(principal.getId(), transactionId)));
    }

    @PostMapping("/admin/wallet/{userId}/adjust")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Administrative wallet credit/debit adjustment with audit log")
    public ResponseEntity<ApiResponse<WalletTransactionDto>> adminAdjust(
            @AuthenticationPrincipal UserPrincipal admin,
            @PathVariable UUID userId,
            @RequestBody AdminWalletAdjustRequest req) {
        String type = req.transactionType() != null && req.transactionType().equalsIgnoreCase("DEBIT")
                ? "DEBIT" : "ADJUSTMENT";
        WalletTransactionDto txn = walletService.applyLedgerEntry(
                userId,
                type,
                req.amount(),
                "ADMIN_ADJUSTMENT",
                null,
                req.idempotencyKey(),
                req.description() != null ? req.description() : "Administrative adjustment",
                admin.getId()
        );
        return ResponseEntity.ok(ApiResponse.ok("Wallet adjustment recorded", txn));
    }
}
