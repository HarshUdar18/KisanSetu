package com.kisansetu.modules.payment.repository;

import com.kisansetu.modules.payment.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, UUID> {
    List<Payment> findByUserIdOrderByCreatedAtDesc(UUID userId);
    Optional<Payment> findByIdAndUserId(UUID id, UUID userId);
    Optional<Payment> findByOrderId(UUID orderId);
    Optional<Payment> findByTransactionId(String transactionId);
}
