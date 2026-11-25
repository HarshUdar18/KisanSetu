package com.kisansetu.pricing;

import com.kisansetu.modules.cart.entity.Cart;
import com.kisansetu.modules.cart.entity.CartItem;
import com.kisansetu.modules.cart.service.CartService;
import com.kisansetu.modules.customer.entity.Address;
import com.kisansetu.modules.customer.repository.AddressRepository;
import com.kisansetu.modules.order.dto.CreateOrderRequest;
import com.kisansetu.modules.order.dto.OrderDto;
import com.kisansetu.modules.order.entity.Order;
import com.kisansetu.modules.order.repository.OrderItemRepository;
import com.kisansetu.modules.order.repository.OrderRepository;
import com.kisansetu.modules.order.service.OrderService;
import com.kisansetu.modules.pricing.entity.MarketPrice;
import com.kisansetu.modules.pricing.repository.MarketPriceRepository;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.servicearea.entity.ServiceArea;
import com.kisansetu.modules.servicearea.repository.ServiceAreaRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

class PriceLockingTest {

    private OrderRepository orderRepository;
    private OrderItemRepository orderItemRepository;
    private CartService cartService;
    private AddressRepository addressRepository;
    private ServiceAreaRepository serviceAreaRepository;
    private MarketPriceRepository marketPriceRepository;
    private UserRepository userRepository;
    private OrderService orderService;

    private UUID userId;
    private UUID addressId;
    private User testUser;
    private Address testAddress;
    private ServiceArea serviceArea;
    private Product tomato;
    private MarketPrice tomatoMarketPrice;

    @BeforeEach
    void setUp() {
        orderRepository = Mockito.mock(OrderRepository.class);
        orderItemRepository = Mockito.mock(OrderItemRepository.class);
        cartService = Mockito.mock(CartService.class);
        addressRepository = Mockito.mock(AddressRepository.class);
        serviceAreaRepository = Mockito.mock(ServiceAreaRepository.class);
        marketPriceRepository = Mockito.mock(MarketPriceRepository.class);
        userRepository = Mockito.mock(UserRepository.class);

        orderService = new OrderService(
                orderRepository,
                orderItemRepository,
                cartService,
                addressRepository,
                serviceAreaRepository,
                marketPriceRepository,
                userRepository,
                Mockito.mock(com.kisansetu.common.events.DomainEventPublisher.class),
                Mockito.mock(com.kisansetu.modules.operations.service.StockConservationService.class)
        );

        userId = UUID.randomUUID();
        addressId = UUID.randomUUID();

        testUser = new User("9876543211", "customer@test.com", "hash");
        testUser.setId(userId);

        testAddress = new Address();
        testAddress.setId(addressId);
        testAddress.setUser(testUser);
        testAddress.setPincode("411005");

        serviceArea = new ServiceArea();
        serviceArea.setName("Shivajinagar");
        serviceArea.setStatus("ACTIVE");
        serviceArea.setPincode("411005");

        tomato = new Product();
        tomato.setId(UUID.randomUUID());
        tomato.setName("Desi Tomato");
        tomato.setUnit("kg");
        tomato.setAvailable(true);

        // Initial Market Price: Rs 30
        tomatoMarketPrice = new MarketPrice(tomato, BigDecimal.valueOf(30.0), BigDecimal.valueOf(28.0));

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(addressRepository.findByIdAndUserId(addressId, userId)).thenReturn(Optional.of(testAddress));
        when(serviceAreaRepository.findByPincode("411005")).thenReturn(Optional.of(serviceArea));
        when(marketPriceRepository.findByProductId(tomato.getId())).thenReturn(Optional.of(tomatoMarketPrice));
        when(orderRepository.save(any(Order.class))).thenAnswer(invocation -> {
            Order o = invocation.getArgument(0);
            o.setId(UUID.randomUUID());
            return o;
        });
    }

    @Test
    @DisplayName("Critical Rule: OrderItem unit price is locked at checkout; subsequent market price changes do not alter existing order price")
    void testPriceLockingImmutability() {
        // 1. Setup cart with 2 kg of tomatoes at current market price 30.00
        Cart cart = new Cart(testUser);
        CartItem cartItem = new CartItem(cart, tomato, BigDecimal.valueOf(2.0));
        cart.getItems().add(cartItem);

        when(cartService.getOrCreateCartEntity(userId)).thenReturn(cart);

        CreateOrderRequest request = new CreateOrderRequest();
        request.setAddressId(addressId);
        request.setDeliveryDate(LocalDate.now().plusDays(1));
        request.setDeliverySlot("Morning (07:00 AM - 10:00 AM)");

        // 2. Create order
        OrderDto createdOrder = orderService.createOrderFromCart(userId, request);
        assertNotNull(createdOrder);
        assertEquals(1, createdOrder.getItems().size());
        assertEquals(new BigDecimal("30.0"), createdOrder.getItems().get(0).getUnitPrice());
        assertEquals(new BigDecimal("60.00"), createdOrder.getItems().get(0).getTotalPrice());

        // 3. Market price increases to Rs 35.00
        tomatoMarketPrice.setCurrentPrice(BigDecimal.valueOf(35.0));

        // 4. Verify that existing order still maintains locked price of 30.0
        assertEquals(new BigDecimal("30.0"), createdOrder.getItems().get(0).getUnitPrice(),
                "Existing order unit price MUST remain immutable at 30.00 despite market price increase to 35.00");
    }
}
