package com.kisansetu.modules.payment.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "payment_transactions")
public class PaymentTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payment_id", nullable = false)
    private Payment payment;

    @Column(name = "transaction_type", nullable = false, length = 30)
    private String transactionType = "CAPTURE";

    @Column(nullable = false, length = 30)
    private String status; // SUCCESS, FAILED

    @Column(name = "gateway_response", columnDefinition = "TEXT")
    private String gatewayResponse;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public PaymentTransaction() {}

    public PaymentTransaction(Payment payment, String transactionType, String status, String gatewayResponse) {
        this.payment = payment;
        this.transactionType = transactionType;
        this.status = status;
        this.gatewayResponse = gatewayResponse;
        this.createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public Payment getPayment() { return payment; }
    public String getTransactionType() { return transactionType; }
    public String getStatus() { return status; }
    public String getGatewayResponse() { return gatewayResponse; }
    public Instant getCreatedAt() { return createdAt; }
}
