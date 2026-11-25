package com.kisansetu.modules.payment.dto;

import com.kisansetu.modules.payment.entity.Payment;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public class PaymentDto {
    private UUID id;
    private UUID orderId;
    private String orderNumber;
    private BigDecimal amount;
    private String currency;
    private String paymentMethod;
    private String status;
    private String transactionId;
    private Instant createdAt;

    public PaymentDto() {}

    public static PaymentDto fromEntity(Payment payment) {
        PaymentDto dto = new PaymentDto();
        dto.setId(payment.getId());
        if (payment.getOrder() != null) {
            dto.setOrderId(payment.getOrder().getId());
            dto.setOrderNumber(payment.getOrder().getOrderNumber());
        }
        dto.setAmount(payment.getAmount());
        dto.setCurrency(payment.getCurrency());
        dto.setPaymentMethod(payment.getPaymentMethod());
        dto.setStatus(payment.getStatus());
        dto.setTransactionId(payment.getTransactionId());
        dto.setCreatedAt(payment.getCreatedAt());
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getOrderId() { return orderId; }
    public void setOrderId(UUID orderId) { this.orderId = orderId; }
    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
