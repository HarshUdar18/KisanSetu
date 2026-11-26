package com.kisansetu.modules.payment.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.audit.AuditService;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class WalletService {

    private final JdbcTemplate jdbcTemplate;
    private final AuditService auditService;

    public WalletService(JdbcTemplate jdbcTemplate, AuditService auditService) {
        this.jdbcTemplate = jdbcTemplate;
        this.auditService = auditService;
    }

    public record WalletSummaryDto(
            UUID walletId,
            UUID userId,
            BigDecimal balance,
            String currency,
            String status,
            List<WalletTransactionDto> transactions
    ) {}

    public record WalletTransactionDto(
            UUID transactionId,
            UUID walletId,
            String transactionType,
            BigDecimal amount,
            String referenceType,
            UUID referenceId,
            String status,
            String description,
            String createdAt
    ) {}

    @Transactional
    public WalletSummaryDto getWalletSummary(UUID userId) {
        UUID walletId = ensureWalletExists(userId);
        Map<String, Object> walletRow = jdbcTemplate.queryForMap(
                "SELECT wallet_id, user_id, balance, currency, status FROM wallets WHERE wallet_id = ?",
                walletId
        );
        List<WalletTransactionDto> txns = getTransactions(userId, 0, 50);
        return new WalletSummaryDto(
                UUID.fromString(walletRow.get("wallet_id").toString()),
                UUID.fromString(walletRow.get("user_id").toString()),
                ((BigDecimal) walletRow.get("balance")).setScale(2, RoundingMode.HALF_UP),
                String.valueOf(walletRow.get("currency")),
                String.valueOf(walletRow.get("status")),
                txns
        );
    }

    @Transactional(readOnly = true)
    public List<WalletTransactionDto> getTransactions(UUID userId, int page, int size) {
        int clampedSize = Math.max(1, Math.min(size, 100));
        int offset = Math.max(0, page) * clampedSize;
        return jdbcTemplate.query("""
                SELECT t.transaction_id, t.wallet_id, t.transaction_type, t.amount,
                       t.reference_type, t.reference_id, t.status, t.description, t.created_at
                FROM wallet_transactions t
                JOIN wallets w ON w.wallet_id = t.wallet_id
                WHERE w.user_id = ?
                ORDER BY t.created_at DESC
                LIMIT ? OFFSET ?
                """, (rs, rowNum) -> {
            String refId = rs.getString("reference_id");
            Timestamp ts = rs.getTimestamp("created_at");
            return new WalletTransactionDto(
                    UUID.fromString(rs.getString("transaction_id")),
                    UUID.fromString(rs.getString("wallet_id")),
                    rs.getString("transaction_type"),
                    rs.getBigDecimal("amount").setScale(2, RoundingMode.HALF_UP),
                    rs.getString("reference_type"),
                    refId != null ? UUID.fromString(refId) : null,
                    rs.getString("status"),
                    rs.getString("description"),
                    ts != null ? ts.toInstant().toString() : null
            );
        }, userId, clampedSize, offset);
    }

    @Transactional(readOnly = true)
    public WalletTransactionDto getTransaction(UUID userId, UUID transactionId) {
        List<WalletTransactionDto> rows = jdbcTemplate.query("""
                SELECT t.transaction_id, t.wallet_id, t.transaction_type, t.amount,
                       t.reference_type, t.reference_id, t.status, t.description, t.created_at
                FROM wallet_transactions t
                JOIN wallets w ON w.wallet_id = t.wallet_id
                WHERE t.transaction_id = ? AND w.user_id = ?
                """, (rs, rowNum) -> {
            String refId = rs.getString("reference_id");
            Timestamp ts = rs.getTimestamp("created_at");
            return new WalletTransactionDto(
                    UUID.fromString(rs.getString("transaction_id")),
                    UUID.fromString(rs.getString("wallet_id")),
                    rs.getString("transaction_type"),
                    rs.getBigDecimal("amount").setScale(2, RoundingMode.HALF_UP),
                    rs.getString("reference_type"),
                    refId != null ? UUID.fromString(refId) : null,
                    rs.getString("status"),
                    rs.getString("description"),
                    ts != null ? ts.toInstant().toString() : null
            );
        }, transactionId, userId);

        if (rows.isEmpty()) {
            throw new ApiException("WALLET_TXN_NOT_FOUND", "Wallet transaction not found or unauthorized", HttpStatus.NOT_FOUND);
        }
        return rows.get(0);
    }

    @Transactional
    public WalletTransactionDto applyLedgerEntry(
            UUID userId,
            String transactionType,
            BigDecimal rawAmount,
            String referenceType,
            UUID referenceId,
            String idempotencyKey,
            String description,
            UUID actorId) {
        if (rawAmount == null || rawAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApiException("INVALID_AMOUNT", "Amount must be greater than zero", HttpStatus.BAD_REQUEST);
        }
        BigDecimal amount = rawAmount.setScale(2, RoundingMode.HALF_UP);

        if (idempotencyKey != null && !idempotencyKey.isBlank()) {
            List<WalletTransactionDto> existing = jdbcTemplate.query("""
                    SELECT t.transaction_id, t.wallet_id, t.transaction_type, t.amount,
                           t.reference_type, t.reference_id, t.status, t.description, t.created_at
                    FROM wallet_transactions t
                    WHERE t.idempotency_key = ?
                    """, (rs, rowNum) -> {
                String refId = rs.getString("reference_id");
                Timestamp ts = rs.getTimestamp("created_at");
                return new WalletTransactionDto(
                        UUID.fromString(rs.getString("transaction_id")),
                        UUID.fromString(rs.getString("wallet_id")),
                        rs.getString("transaction_type"),
                        rs.getBigDecimal("amount").setScale(2, RoundingMode.HALF_UP),
                        rs.getString("reference_type"),
                        refId != null ? UUID.fromString(refId) : null,
                        rs.getString("status"),
                        rs.getString("description"),
                        ts != null ? ts.toInstant().toString() : null
                );
            }, idempotencyKey.trim());
            if (!existing.isEmpty()) {
                return existing.get(0);
            }
        }

        UUID walletId = ensureWalletExists(userId);
        BigDecimal currentBalance = jdbcTemplate.queryForObject(
                "SELECT balance FROM wallets WHERE wallet_id = ? FOR UPDATE",
                BigDecimal.class, walletId
        );
        if (currentBalance == null) currentBalance = BigDecimal.ZERO;

        boolean isDebit = "DEBIT".equalsIgnoreCase(transactionType);
        if (isDebit && currentBalance.compareTo(amount) < 0) {
            throw new ApiException("INSUFFICIENT_WALLET_BALANCE", "Insufficient wallet balance", HttpStatus.BAD_REQUEST);
        }

        BigDecimal nextBalance = isDebit ? currentBalance.subtract(amount) : currentBalance.add(amount);
        jdbcTemplate.update(
                "UPDATE wallets SET balance = ?, updated_at = NOW() WHERE wallet_id = ?",
                nextBalance, walletId
        );

        UUID txnId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO wallet_transactions (
                    transaction_id, wallet_id, transaction_type, amount,
                    reference_type, reference_id, idempotency_key, status, description
                ) VALUES (?, ?, ?, ?, ?, ?, ?, 'COMPLETED', ?)
                """, txnId, walletId, transactionType.toUpperCase(), amount,
                referenceType, referenceId,
                idempotencyKey != null && !idempotencyKey.isBlank() ? idempotencyKey.trim() : null,
                description);

        if (actorId != null) {
            auditService.logEvent(actorId, "WALLET_" + transactionType.toUpperCase(), "WALLET", walletId.toString(),
                    "Amount: " + amount + ", Reason: " + description, null);
        }

        return getTransaction(userId, txnId);
    }

    private UUID ensureWalletExists(UUID userId) {
        List<UUID> ids = jdbcTemplate.query(
                "SELECT wallet_id FROM wallets WHERE user_id = ?",
                (rs, rowNum) -> UUID.fromString(rs.getString("wallet_id")),
                userId
        );
        if (!ids.isEmpty()) {
            return ids.get(0);
        }
        UUID walletId = UUID.randomUUID();
        jdbcTemplate.update(
                "INSERT INTO wallets (wallet_id, user_id, balance, currency, status) VALUES (?, ?, 0.00, 'INR', 'ACTIVE') ON CONFLICT (user_id) DO NOTHING",
                walletId, userId
        );
        return jdbcTemplate.queryForObject(
                "SELECT wallet_id FROM wallets WHERE user_id = ?",
                (rs, rowNum) -> UUID.fromString(rs.getString("wallet_id")),
                userId
        );
    }
}
