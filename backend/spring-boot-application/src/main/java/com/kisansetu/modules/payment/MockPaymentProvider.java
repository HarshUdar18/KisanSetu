package com.kisansetu.modules.payment;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@Service
@Profile({"dev", "local", "test"})
public class MockPaymentProvider implements PaymentProvider {

    private static final Logger log = LoggerFactory.getLogger(MockPaymentProvider.class);

    @Override
    public Map<String, Object> initiatePayment(String orderId, BigDecimal amount, String customerPhone) {
        String mockPaymentId = "pay_mock_" + UUID.randomUUID().toString().substring(0, 12);
        log.info("[MOCK PAYMENT] Initiated payment for Order: {} Amount: INR {} Phone: {} -> PaymentId: {}",
                orderId, amount, customerPhone, mockPaymentId);
        return Map.of(
                "paymentId", mockPaymentId,
                "orderId", orderId,
                "amount", amount,
                "currency", "INR",
                "status", "CREATED",
                "mode", "MOCK_LOCAL"
        );
    }

    @Override
    public Map<String, Object> verifyPayment(String paymentId, String orderId) {
        log.info("[MOCK PAYMENT] Auto-verifying payment: {} for Order: {}", paymentId, orderId);
        return Map.of(
                "paymentId", paymentId,
                "orderId", orderId,
                "status", "SUCCESS",
                "verified", true
        );
    }

    @Override
    public Map<String, Object> initiateFarmerPayout(String farmerId, BigDecimal amount, String bankAccountNumber, String ifsc) {
        String mockPayoutId = "payout_mock_" + UUID.randomUUID().toString().substring(0, 12);
        log.info("[MOCK PAYOUT] Scheduled T+1 direct settlement to Farmer: {} Amount: INR {} A/C: {} IFSC: {} -> PayoutId: {}",
                farmerId, amount, bankAccountNumber, ifsc, mockPayoutId);
        return Map.of(
                "payoutId", mockPayoutId,
                "farmerId", farmerId,
                "amount", amount,
                "status", "PROCESSED",
                "settlementCycle", "T+1"
        );
    }
}
