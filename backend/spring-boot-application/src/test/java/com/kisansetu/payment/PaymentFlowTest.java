package com.kisansetu.payment;

import com.kisansetu.modules.order.entity.Order;
import com.kisansetu.modules.order.repository.OrderRepository;
import com.kisansetu.modules.payment.dto.MockPaymentRequest;
import com.kisansetu.modules.payment.dto.PaymentDto;
import com.kisansetu.modules.payment.entity.Payment;
import com.kisansetu.modules.payment.repository.PaymentRepository;
import com.kisansetu.modules.payment.repository.PaymentTransactionRepository;
import com.kisansetu.modules.payment.service.PaymentService;
import com.kisansetu.modules.tracking.repository.TrackingEventRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class PaymentFlowTest {

    private PaymentRepository paymentRepository;
    private PaymentTransactionRepository paymentTransactionRepository;
    private OrderRepository orderRepository;
    private UserRepository userRepository;
    private TrackingEventRepository trackingEventRepository;
    private PaymentService paymentService;

    private UUID userId;
    private UUID orderId;
    private User testUser;
    private Order testOrder;

    @BeforeEach
    void setUp() {
        paymentRepository = Mockito.mock(PaymentRepository.class);
        paymentTransactionRepository = Mockito.mock(PaymentTransactionRepository.class);
        orderRepository = Mockito.mock(OrderRepository.class);
        userRepository = Mockito.mock(UserRepository.class);
        trackingEventRepository = Mockito.mock(TrackingEventRepository.class);

        paymentService = new PaymentService(
                paymentRepository,
                paymentTransactionRepository,
                orderRepository,
                userRepository,
                trackingEventRepository,
                Mockito.mock(com.kisansetu.common.events.DomainEventPublisher.class));

        userId = UUID.randomUUID();
        orderId = UUID.randomUUID();

        testUser = new User("9876543211", "customer@test.com", "hash");
        testUser.setId(userId);

        testOrder = new Order();
        testOrder.setId(orderId);
        testOrder.setUser(testUser);
        testOrder.setTotalAmount(BigDecimal.valueOf(105.0));
        testOrder.setOrderStatus("PENDING_PAYMENT");
        testOrder.setPaymentStatus("PENDING");

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(orderRepository.findByIdAndUserId(orderId, userId)).thenReturn(Optional.of(testOrder));
        when(paymentRepository.save(any(Payment.class))).thenAnswer(invocation -> {
            Payment p = invocation.getArgument(0);
            p.setId(UUID.randomUUID());
            return p;
        });
    }

    @Test
    @DisplayName("Scenario 1: Mock payment success updates order to CONFIRMED and initializes tracking timeline")
    void testSuccessfulPaymentFlow() {
        MockPaymentRequest request = new MockPaymentRequest(orderId, "MOCK_UPI", true);

        PaymentDto paymentResult = paymentService.processMockPayment(userId, request);

        assertNotNull(paymentResult);
        assertEquals("SUCCESS", paymentResult.getStatus());
        assertEquals("CONFIRMED", testOrder.getOrderStatus());
        assertEquals("COMPLETED", testOrder.getPaymentStatus());
        assertNotNull(testOrder.getPaymentReference());

        // Verify tracking events were saved
        verify(trackingEventRepository).saveAll(any());
    }

    @Test
    @DisplayName("Scenario 2: Mock payment failure keeps order in PENDING_PAYMENT status and allows retry")
    void testFailedPaymentFlowAllowsRetry() {
        MockPaymentRequest request = new MockPaymentRequest(orderId, "MOCK_UPI", false);

        PaymentDto paymentResult = paymentService.processMockPayment(userId, request);

        assertNotNull(paymentResult);
        assertEquals("FAILED", paymentResult.getStatus());
        assertEquals("PENDING_PAYMENT", testOrder.getOrderStatus(),
                "Order status should remain PENDING_PAYMENT for retry");
        assertEquals("FAILED", testOrder.getPaymentStatus());
    }
}
