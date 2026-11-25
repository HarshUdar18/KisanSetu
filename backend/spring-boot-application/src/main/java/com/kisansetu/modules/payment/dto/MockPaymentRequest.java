package com.kisansetu.modules.payment.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public class MockPaymentRequest {

    @NotNull(message = "Order ID is required")
    private UUID orderId;

    private String paymentMethod = "MOCK_UPI"; // MOCK_UPI, MOCK_CARD, MOCK_NETBANKING

    private boolean simulateSuccess = true;

    public MockPaymentRequest() {}

    public MockPaymentRequest(UUID orderId, String paymentMethod, boolean simulateSuccess) {
        this.orderId = orderId;
        this.paymentMethod = paymentMethod;
        this.simulateSuccess = simulateSuccess;
    }

    public UUID getOrderId() { return orderId; }
    public void setOrderId(UUID orderId) { this.orderId = orderId; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public boolean isSimulateSuccess() { return simulateSuccess; }
    public void setSimulateSuccess(boolean simulateSuccess) { this.simulateSuccess = simulateSuccess; }
}
