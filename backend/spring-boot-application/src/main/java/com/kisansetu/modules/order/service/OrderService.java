package com.kisansetu.modules.order.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.kisansetu.common.events.DomainEventPublisher;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.operations.service.StockConservationService;
import com.kisansetu.modules.cart.dto.CartDto;
import com.kisansetu.modules.cart.entity.Cart;
import com.kisansetu.modules.cart.entity.CartItem;
import com.kisansetu.modules.cart.service.CartService;
import com.kisansetu.modules.customer.dto.AddressDto;
import com.kisansetu.modules.customer.entity.Address;
import com.kisansetu.modules.customer.repository.AddressRepository;
import com.kisansetu.modules.order.dto.CheckoutSummaryDto;
import com.kisansetu.modules.order.dto.CreateOrderRequest;
import com.kisansetu.modules.order.dto.OrderDto;
import com.kisansetu.modules.order.entity.Order;
import com.kisansetu.modules.order.entity.OrderItem;
import com.kisansetu.modules.order.repository.OrderItemRepository;
import com.kisansetu.modules.order.repository.OrderRepository;
import com.kisansetu.modules.pricing.entity.MarketPrice;
import com.kisansetu.modules.pricing.repository.MarketPriceRepository;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.servicearea.entity.ServiceArea;
import com.kisansetu.modules.servicearea.repository.ServiceAreaRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final CartService cartService;
    private final AddressRepository addressRepository;
    private final ServiceAreaRepository serviceAreaRepository;
    private final MarketPriceRepository marketPriceRepository;
    private final UserRepository userRepository;
    private final DomainEventPublisher eventPublisher;
    private final StockConservationService stockConservationService;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final SecureRandom random = new SecureRandom();

    public OrderService(OrderRepository orderRepository,
            OrderItemRepository orderItemRepository,
            CartService cartService,
            AddressRepository addressRepository,
            ServiceAreaRepository serviceAreaRepository,
            MarketPriceRepository marketPriceRepository,
            UserRepository userRepository,
            DomainEventPublisher eventPublisher,
            StockConservationService stockConservationService) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.cartService = cartService;
        this.addressRepository = addressRepository;
        this.serviceAreaRepository = serviceAreaRepository;
        this.marketPriceRepository = marketPriceRepository;
        this.userRepository = userRepository;
        this.eventPublisher = eventPublisher;
        this.stockConservationService = stockConservationService;
    }

    @Transactional(readOnly = true)
    public List<OrderDto> getOrders(UUID userId) {
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(OrderDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public OrderDto getOrder(UUID userId, UUID orderId) {
        Order order = orderRepository.findByIdAndUserId(orderId, userId)
                .orElseThrow(() -> new ApiException("ORDER_NOT_FOUND", "Order not found or unauthorized",
                        HttpStatus.NOT_FOUND));
        return OrderDto.fromEntity(order);
    }

    @Transactional(readOnly = true)
    public CheckoutSummaryDto getCheckoutSummary(UUID userId, UUID addressId) {
        CartDto cart = cartService.getCart(userId);
        if (cart.getItems().isEmpty()) {
            throw new ApiException("CART_EMPTY", "Cannot proceed to checkout with an empty cart",
                    HttpStatus.BAD_REQUEST);
        }

        CheckoutSummaryDto summary = new CheckoutSummaryDto();
        summary.setItems(cart.getItems());
        summary.setSubtotal(cart.getSubtotal());
        summary.setDeliveryFee(cart.getDeliveryFee());
        summary.setLogisticsFee(cart.getLogisticsFee());
        summary.setTaxAmount(cart.getTaxAmount());
        summary.setTotalAmount(cart.getTotalAmount());

        if (addressId != null) {
            Address address = addressRepository.findByIdAndUserId(addressId, userId)
                    .orElse(null);
            if (address != null) {
                summary.setSelectedAddress(AddressDto.fromEntity(address));
                Optional<ServiceArea> sa = serviceAreaRepository.findByPincode(address.getPincode());
                summary.setServiceable(sa.isPresent() && "ACTIVE".equalsIgnoreCase(sa.get().getStatus()));
                summary.setServiceAreaName(sa.map(ServiceArea::getName).orElse(null));
            }
        } else {
            Address def = addressRepository.findByUserIdAndIsDefaultTrue(userId).orElse(null);
            if (def != null) {
                summary.setSelectedAddress(AddressDto.fromEntity(def));
                Optional<ServiceArea> sa = serviceAreaRepository.findByPincode(def.getPincode());
                summary.setServiceable(sa.isPresent() && "ACTIVE".equalsIgnoreCase(sa.get().getStatus()));
                summary.setServiceAreaName(sa.map(ServiceArea::getName).orElse(null));
            }
        }

        return summary;
    }

    @Transactional
    public OrderDto createOrderFromCart(UUID userId, CreateOrderRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "User not found", HttpStatus.NOT_FOUND));

        Cart cart = cartService.getOrCreateCartEntity(userId);
        if (cart.getItems().isEmpty()) {
            throw new ApiException("CART_EMPTY", "Cart is empty. Add products before creating an order.",
                    HttpStatus.BAD_REQUEST);
        }

        Address address = addressRepository.findByIdAndUserId(request.getAddressId(), userId)
                .orElseThrow(() -> new ApiException("ADDRESS_NOT_FOUND", "Address not found or unauthorized",
                        HttpStatus.NOT_FOUND));

        ServiceArea serviceArea = serviceAreaRepository.findByPincode(address.getPincode())
                .orElseThrow(() -> new ApiException("OUTSIDE_SERVICE_AREA",
                        "Delivery address is outside the supported service area (Shivajinagar/Akurdi).",
                        HttpStatus.BAD_REQUEST));

        String addressJson = "";
        try {
            addressJson = objectMapper.writeValueAsString(AddressDto.fromEntity(address));
        } catch (Exception ignored) {
        }

        String orderNumber = "ORD-" + (100000 + random.nextInt(900000));

        Order order = new Order(
                orderNumber,
                user,
                address,
                addressJson,
                serviceArea,
                request.getDeliveryDate(),
                request.getDeliverySlot());

        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cart.getItems()) {
            Product p = item.getProduct();
            MarketPrice mp = marketPriceRepository.findByProductId(p.getId()).orElse(null);
            BigDecimal unitPrice = mp != null ? mp.getCurrentPrice() : BigDecimal.valueOf(30.0);
            BigDecimal itemTotal = unitPrice.multiply(item.getQuantity()).setScale(2, RoundingMode.HALF_UP);

            OrderItem orderItem = new OrderItem(
                    order,
                    p,
                    p.getName(),
                    item.getQuantity(),
                    p.getUnit(),
                    unitPrice, // PRICE LOCKED!
                    itemTotal);

            order.getItems().add(orderItem);
            subtotal = subtotal.add(itemTotal);
        }

        BigDecimal deliveryFee = subtotal.compareTo(BigDecimal.valueOf(300.0)) >= 0 ? BigDecimal.ZERO
                : BigDecimal.valueOf(30.0);
        BigDecimal logisticsFee = BigDecimal.valueOf(15.0);
        BigDecimal taxAmount = subtotal.multiply(BigDecimal.valueOf(0.05)).setScale(2, RoundingMode.HALF_UP);
        BigDecimal total = subtotal.add(deliveryFee).add(logisticsFee).add(taxAmount);

        order.setSubtotal(subtotal);
        order.setDeliveryFee(deliveryFee);
        order.setLogisticsFee(logisticsFee);
        order.setTaxAmount(taxAmount);
        order.setTotalAmount(total);
        order.setOrderStatus("PENDING_PAYMENT");
        order.setPaymentStatus("PENDING");

        Order savedOrder = orderRepository.save(order);

        // Atomically reserve stock with pessimistic locking
        stockConservationService.reserveStockForOrder(savedOrder.getId(), savedOrder.getItems());

        // Clear user's shopping cart after order creation
        cartService.clearCart(userId);

        eventPublisher.publish("order.created", "com.kisansetu.events.OrderCreated", java.util.Map.of(
                "orderId", savedOrder.getId().toString(),
                "orderNumber", savedOrder.getOrderNumber(),
                "customerId", userId.toString(),
                "totalAmount", savedOrder.getTotalAmount().toString()));

        return OrderDto.fromEntity(savedOrder);
    }

    @Transactional
    public OrderDto cancelOrder(UUID userId, UUID orderId, String reason) {
        Order order = orderRepository.findByIdAndUserId(orderId, userId)
                .orElseThrow(() -> new ApiException("ORDER_NOT_FOUND", "Order not found or unauthorized",
                        HttpStatus.NOT_FOUND));

        String currentStatus = order.getOrderStatus();
        if (!"PENDING_PAYMENT".equalsIgnoreCase(currentStatus) && !"CONFIRMED".equalsIgnoreCase(currentStatus)) {
            throw new ApiException("ORDER_CANNOT_BE_CANCELLED",
                    "Order cannot be cancelled in status: " + currentStatus, HttpStatus.BAD_REQUEST);
        }

        order.setOrderStatus("CANCELLED");
        if ("COMPLETED".equalsIgnoreCase(order.getPaymentStatus())
                || "PAID".equalsIgnoreCase(order.getPaymentStatus())) {
            order.setPaymentStatus("REFUND_INITIATED");
        }
        Order saved = orderRepository.save(order);

        // Release reserved stock on cancellation
        stockConservationService.releaseStockForOrder(saved.getId(), saved.getItems());

        eventPublisher.publish("order.cancelled", "com.kisansetu.events.OrderCancelled", java.util.Map.of(
                "orderId", saved.getId().toString(),
                "customerId", userId.toString(),
                "reason", reason != null ? reason : "Customer requested cancellation"));

        return OrderDto.fromEntity(saved);
    }
}
