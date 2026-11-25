package com.kisansetu.cart;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.cart.dto.AssignWeeklyCartDayRequest;
import com.kisansetu.modules.cart.dto.CreateWeeklyCartRequest;
import com.kisansetu.modules.cart.dto.WeeklyCartDto;
import com.kisansetu.modules.cart.dto.WeeklyCartItemInput;
import com.kisansetu.modules.cart.entity.WeeklyCart;
import com.kisansetu.modules.cart.repository.WeeklyCartDayRepository;
import com.kisansetu.modules.cart.repository.WeeklyCartRepository;
import com.kisansetu.modules.pricing.repository.MarketPriceRepository;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.product.repository.ProductRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import com.kisansetu.modules.cart.service.WeeklyCartService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.http.HttpStatus;

import java.math.BigDecimal;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

class WeeklyCartModificationTest {

    private WeeklyCartRepository weeklyCartRepository;
    private WeeklyCartDayRepository weeklyCartDayRepository;
    private ProductRepository productRepository;
    private MarketPriceRepository marketPriceRepository;
    private UserRepository userRepository;
    private WeeklyCartService weeklyCartService;

    private UUID userId;
    private UUID cartId;
    private User testUser;
    private Product tomato;

    @BeforeEach
    void setUp() {
        weeklyCartRepository = Mockito.mock(WeeklyCartRepository.class);
        weeklyCartDayRepository = Mockito.mock(WeeklyCartDayRepository.class);
        productRepository = Mockito.mock(ProductRepository.class);
        marketPriceRepository = Mockito.mock(MarketPriceRepository.class);
        userRepository = Mockito.mock(UserRepository.class);

        weeklyCartService = new WeeklyCartService(
                weeklyCartRepository,
                weeklyCartDayRepository,
                productRepository,
                marketPriceRepository,
                userRepository
        );

        userId = UUID.randomUUID();
        cartId = UUID.randomUUID();

        testUser = new User("9876543211", "customer@test.com", "hash");
        testUser.setId(userId);

        tomato = new Product();
        tomato.setId(UUID.randomUUID());
        tomato.setName("Desi Tomato");
        tomato.setAvailable(true);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(productRepository.findById(tomato.getId())).thenReturn(Optional.of(tomato));
    }

    @Test
    @DisplayName("Critical Business Rule: Weekly Cart can be modified exactly ONCE; second modification is rejected with HTTP 409")
    void testWeeklyCartSingleModificationRule() {
        WeeklyCart cart = new WeeklyCart(testUser, "My Weekly Produce");
        cart.setId(cartId);
        cart.setStatus("SUBMITTED");
        cart.setModificationCount(0); // Submitted with 0 modifications

        when(weeklyCartRepository.findByIdAndUserId(cartId, userId)).thenReturn(Optional.of(cart));
        when(weeklyCartRepository.save(any(WeeklyCart.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // 1. First modification: modificationCount goes 0 -> 1 (ALLOWED)
        List<AssignWeeklyCartDayRequest> firstModification = List.of(
                new AssignWeeklyCartDayRequest("MONDAY", List.of(new WeeklyCartItemInput(tomato.getId(), BigDecimal.valueOf(2.0))))
        );

        WeeklyCartDto modifiedResult = weeklyCartService.modifyWeeklyCart(userId, cartId, firstModification);
        assertNotNull(modifiedResult);
        assertEquals(1, modifiedResult.getModificationCount());
        assertFalse(modifiedResult.isModifiable(), "Cart should no longer be modifiable after 1 modification");

        // 2. Second modification attempt: modificationCount is 1 -> REJECT WITH 409 CONFLICT!
        List<AssignWeeklyCartDayRequest> secondModification = List.of(
                new AssignWeeklyCartDayRequest("TUESDAY", List.of(new WeeklyCartItemInput(tomato.getId(), BigDecimal.valueOf(1.0))))
        );

        ApiException exception = assertThrows(ApiException.class, () -> {
            weeklyCartService.modifyWeeklyCart(userId, cartId, secondModification);
        });

        assertEquals(HttpStatus.CONFLICT, exception.getStatus());
        assertEquals("WEEKLY_CART_MODIFICATION_LIMIT_REACHED", exception.getCode());
        assertTrue(exception.getMessage().contains("already been modified once"));
    }
}
