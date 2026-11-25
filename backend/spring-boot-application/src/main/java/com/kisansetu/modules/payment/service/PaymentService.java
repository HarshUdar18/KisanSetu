package com.kisansetu.modules.payment.service;

import com.kisansetu.common.events.DomainEventPublisher;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.order.entity.Order;
import com.kisansetu.modules.order.repository.OrderRepository;
import com.kisansetu.modules.payment.dto.MockPaymentRequest;
import com.kisansetu.modules.payment.dto.PaymentDto;
import com.kisansetu.modules.payment.entity.Payment;
import com.kisansetu.modules.payment.entity.PaymentTransaction;
import com.kisansetu.modules.payment.repository.PaymentRepository;
import com.kisansetu.modules.payment.repository.PaymentTransactionRepository;
import com.kisansetu.modules.tracking.entity.TrackingEvent;
import com.kisansetu.modules.tracking.repository.TrackingEventRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final PaymentTransactionRepository paymentTransactionRepository;
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final TrackingEventRepository trackingEventRepository;
    private final DomainEventPublisher eventPublisher;
    private final SecureRandom random = new SecureRandom();

    public PaymentService(PaymentRepository paymentRepository,
                          PaymentTransactionRepository paymentTransactionRepository,
                          OrderRepository orderRepository,
                          UserRepository userRepository,
                          TrackingEventRepository trackingEventRepository,
                          DomainEventPublisher eventPublisher) {
        this.paymentRepository = paymentRepository;
        this.paymentTransactionRepository = paymentTransactionRepository;
        this.orderRepository = orderRepository;
        this.userRepository = userRepository;
        this.trackingEventRepository = trackingEventRepository;
        this.eventPublisher = eventPublisher;
    }

    @Transactional
    public PaymentDto processMockPayment(UUID userId, MockPaymentRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "User not found", HttpStatus.NOT_FOUND));

        Order order = orderRepository.findByIdAndUserId(request.getOrderId(), userId)
                .orElseThrow(() -> new ApiException("ORDER_NOT_FOUND", "Order not found or unauthorized", HttpStatus.NOT_FOUND));

        if ("PAID".equalsIgnoreCase(order.getOrderStatus()) || "CONFIRMED".equalsIgnoreCase(order.getOrderStatus())) {
            throw new ApiException("ORDER_ALREADY_PAID", "Order has already been paid and confirmed", HttpStatus.BAD_REQUEST);
        }

        String txnId = "TXN-" + System.currentTimeMillis() + "-" + (1000 + random.nextInt(9000));
        Payment payment = new Payment(
                order,
                user,
                order.getTotalAmount(),
                request.getPaymentMethod(),
                txnId
        );

        if (request.isSimulateSuccess()) {
            payment.setStatus("SUCCESS");
            paymentRepository.save(payment);

            PaymentTransaction txn = new PaymentTransaction(
                    payment,
                    "CAPTURE",
                    "SUCCESS",
                    "Mock payment verified successfully through KisanSetu Mock Payment Provider"
            );
            paymentTransactionRepository.save(txn);

            order.setOrderStatus("CONFIRMED");
            order.setPaymentStatus("COMPLETED");
            order.setPaymentReference(txnId);
            orderRepository.save(order);

            // Initialize supply chain tracking timeline
            initializeTrackingEvents(order);

            eventPublisher.publish("payment.succeeded", "com.kisansetu.events.PaymentSucceeded", java.util.Map.of(
                    "paymentId", payment.getId().toString(),
                    "orderId", order.getId().toString(),
                    "customerId", userId.toString(),
                    "amount", order.getTotalAmount().toString(),
                    "transactionId", txnId
            ));

            return PaymentDto.fromEntity(payment);
        } else {
            payment.setStatus("FAILED");
            paymentRepository.save(payment);

            PaymentTransaction txn = new PaymentTransaction(
                    payment,
                    "CAPTURE",
                    "FAILED",
                    "Payment simulation failed as requested by test client"
            );
            paymentTransactionRepository.save(txn);

            order.setPaymentStatus("FAILED");
            orderRepository.save(order);

            eventPublisher.publish("payment.failed", "com.kisansetu.events.PaymentFailed", java.util.Map.of(
                    "paymentId", payment.getId().toString(),
                    "orderId", order.getId().toString(),
                    "customerId", userId.toString(),
                    "reason", "Simulated failure"
            ));

            return PaymentDto.fromEntity(payment);
        }
    }

    @Transactional(readOnly = true)
    public PaymentDto getPayment(UUID userId, UUID paymentId) {
        Payment payment = paymentRepository.findByIdAndUserId(paymentId, userId)
                .orElseThrow(() -> new ApiException("PAYMENT_NOT_FOUND", "Payment not found or unauthorized", HttpStatus.NOT_FOUND));
        return PaymentDto.fromEntity(payment);
    }

    private void initializeTrackingEvents(Order order) {
        // Clear any old tracking events if retried
        List<TrackingEvent> existing = trackingEventRepository.findByOrderIdOrderByDisplayOrderAsc(order.getId());
        if (!existing.isEmpty()) {
            trackingEventRepository.deleteAll(existing);
        }

        List<TrackingEvent> events = new ArrayList<>();
        events.add(new TrackingEvent(order, "ORDER_CONFIRMED", "Order Confirmed", "Order received and validated. Farmgate harvest scheduled.", "KisanSetu Platform", true, 1));
        events.add(new TrackingEvent(order, "FARMER_PROCESSING", "Farmer Processing", "Partner farmers are harvesting fresh produce in the morning cycle.", "Farm Aggregation", false, 2));
        events.add(new TrackingEvent(order, "COLLECTION_POINT", "Collection Point", "Produce arriving at village collection center for digital weighing.", "Village Collection Center", false, 3));
        events.add(new TrackingEvent(order, "QUALITY_CHECK", "Quality Check", "Agricultural quality inspection and optical defect sorting.", "QC Lab Pune", false, 4));
        events.add(new TrackingEvent(order, "WAREHOUSE", "Warehouse Sorting", "Cold-chain intake, washing, and customer package palletizing.", "Central Warehouse Pune", false, 5));
        events.add(new TrackingEvent(order, "HUB", "Regional Hub", "En-route to suburban distribution hub.", "Suburban Hub", false, 6));
        events.add(new TrackingEvent(order, "DELIVERY_STATION", "Delivery Station", "Arrived at local micro-fulfillment center.", "Local Station (Shivajinagar/Akurdi)", false, 7));
        events.add(new TrackingEvent(order, "OUT_FOR_DELIVERY", "Out for Delivery", "Delivery partner assigned with direct insulated delivery crate.", "Last-mile Route", false, 8));
        events.add(new TrackingEvent(order, "DELIVERED", "Delivered", "Delivered fresh to doorstep with verified OTP receipt.", "Customer Address", false, 9));

        trackingEventRepository.saveAll(events);
    }
}
