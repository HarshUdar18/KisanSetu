package com.kisansetu.modules.payment;

import java.math.BigDecimal;
import java.util.Map;

public interface PaymentProvider {
    Map<String, Object> initiatePayment(String orderId, BigDecimal amount, String customerPhone);
    Map<String, Object> verifyPayment(String paymentId, String orderId);
    Map<String, Object> initiateFarmerPayout(String farmerId, BigDecimal amount, String bankAccountNumber, String ifsc);
}
