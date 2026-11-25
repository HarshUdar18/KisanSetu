package com.kisansetu.modules.cart.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.cart.dto.*;
import com.kisansetu.modules.cart.entity.WeeklyCart;
import com.kisansetu.modules.cart.entity.WeeklyCartDay;
import com.kisansetu.modules.cart.entity.WeeklyCartItem;
import com.kisansetu.modules.cart.repository.WeeklyCartDayRepository;
import com.kisansetu.modules.cart.repository.WeeklyCartRepository;
import com.kisansetu.modules.pricing.entity.MarketPrice;
import com.kisansetu.modules.pricing.repository.MarketPriceRepository;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.product.repository.ProductRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class WeeklyCartService {

    private final WeeklyCartRepository weeklyCartRepository;
    private final WeeklyCartDayRepository weeklyCartDayRepository;
    private final ProductRepository productRepository;
    private final MarketPriceRepository marketPriceRepository;
    private final UserRepository userRepository;

    public WeeklyCartService(WeeklyCartRepository weeklyCartRepository,
                             WeeklyCartDayRepository weeklyCartDayRepository,
                             ProductRepository productRepository,
                             MarketPriceRepository marketPriceRepository,
                             UserRepository userRepository) {
        this.weeklyCartRepository = weeklyCartRepository;
        this.weeklyCartDayRepository = weeklyCartDayRepository;
        this.productRepository = productRepository;
        this.marketPriceRepository = marketPriceRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<WeeklyCartDto> getWeeklyCarts(UUID userId) {
        return weeklyCartRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::buildWeeklyCartDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public WeeklyCartDto getWeeklyCart(UUID userId, UUID cartId) {
        WeeklyCart cart = weeklyCartRepository.findByIdAndUserId(cartId, userId)
                .orElseThrow(() -> new ApiException("WEEKLY_CART_NOT_FOUND", "Weekly cart not found", HttpStatus.NOT_FOUND));
        return buildWeeklyCartDto(cart);
    }

    @Transactional
    public WeeklyCartDto createWeeklyCart(UUID userId, CreateWeeklyCartRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "User not found", HttpStatus.NOT_FOUND));

        WeeklyCart cart = new WeeklyCart(user, request.getTitle());
        WeeklyCart saved = weeklyCartRepository.save(cart);
        return buildWeeklyCartDto(saved);
    }

    @Transactional
    public WeeklyCartDto assignDayItems(UUID userId, UUID cartId, AssignWeeklyCartDayRequest request) {
        WeeklyCart cart = weeklyCartRepository.findByIdAndUserId(cartId, userId)
                .orElseThrow(() -> new ApiException("WEEKLY_CART_NOT_FOUND", "Weekly cart not found", HttpStatus.NOT_FOUND));

        // If submitted, cannot edit through assignDayItems directly unless using modify endpoint
        if ("LOCKED".equalsIgnoreCase(cart.getStatus()) || ( "SUBMITTED".equalsIgnoreCase(cart.getStatus()) && cart.getModificationCount() >= 1 )) {
            throw new ApiException("WEEKLY_CART_LOCKED", "This weekly cart is locked and cannot be edited", HttpStatus.BAD_REQUEST);
        }

        String dayOfWeek = request.getDayOfWeek().toUpperCase();
        WeeklyCartDay day = cart.getDays().stream()
                .filter(d -> d.getDayOfWeek().equalsIgnoreCase(dayOfWeek))
                .findFirst()
                .orElseGet(() -> {
                    WeeklyCartDay newDay = new WeeklyCartDay(cart, dayOfWeek);
                    cart.getDays().add(newDay);
                    return newDay;
                });

        day.getItems().clear();
        if (request.getItems() != null) {
            for (WeeklyCartItemInput input : request.getItems()) {
                Product product = productRepository.findById(input.getProductId())
                        .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found: " + input.getProductId(), HttpStatus.NOT_FOUND));

                if (!product.isAvailable()) {
                    throw new ApiException("PRODUCT_UNAVAILABLE", product.getName() + " is currently unavailable", HttpStatus.BAD_REQUEST);
                }

                WeeklyCartItem item = new WeeklyCartItem(day, product, input.getQuantity());
                day.getItems().add(item);
            }
        }

        WeeklyCart saved = weeklyCartRepository.save(cart);
        return buildWeeklyCartDto(saved);
    }

    @Transactional
    public WeeklyCartDto submitWeeklyCart(UUID userId, UUID cartId) {
        WeeklyCart cart = weeklyCartRepository.findByIdAndUserId(cartId, userId)
                .orElseThrow(() -> new ApiException("WEEKLY_CART_NOT_FOUND", "Weekly cart not found", HttpStatus.NOT_FOUND));

        if (cart.getDays().isEmpty() || cart.getDays().stream().allMatch(d -> d.getItems().isEmpty())) {
            throw new ApiException("EMPTY_WEEKLY_CART", "Weekly cart must have at least one product scheduled before submission", HttpStatus.BAD_REQUEST);
        }

        // Validate product availability
        for (WeeklyCartDay day : cart.getDays()) {
            for (WeeklyCartItem item : day.getItems()) {
                if (!item.getProduct().isAvailable()) {
                    throw new ApiException("PRODUCT_UNAVAILABLE", item.getProduct().getName() + " is not available", HttpStatus.BAD_REQUEST);
                }
            }
        }

        cart.setStatus("SUBMITTED");
        WeeklyCart saved = weeklyCartRepository.save(cart);
        return buildWeeklyCartDto(saved);
    }

    @Transactional
    public WeeklyCartDto modifyWeeklyCart(UUID userId, UUID cartId, List<AssignWeeklyCartDayRequest> dayRequests) {
        WeeklyCart cart = weeklyCartRepository.findByIdAndUserId(cartId, userId)
                .orElseThrow(() -> new ApiException("WEEKLY_CART_NOT_FOUND", "Weekly cart not found", HttpStatus.NOT_FOUND));

        // CRITICAL BUSINESS RULE ENFORCEMENT:
        // modificationCount = 0 -> allowed, sets modificationCount = 1, locked
        // modificationCount >= 1 -> REJECT WITH 409
        if (cart.getModificationCount() >= 1) {
            throw new ApiException(
                    "WEEKLY_CART_MODIFICATION_LIMIT_REACHED",
                    "This weekly cart has already been modified once and is now locked.",
                    HttpStatus.CONFLICT
            );
        }

        if (dayRequests != null) {
            for (AssignWeeklyCartDayRequest req : dayRequests) {
                String dayOfWeek = req.getDayOfWeek().toUpperCase();
                WeeklyCartDay day = cart.getDays().stream()
                        .filter(d -> d.getDayOfWeek().equalsIgnoreCase(dayOfWeek))
                        .findFirst()
                        .orElseGet(() -> {
                            WeeklyCartDay newDay = new WeeklyCartDay(cart, dayOfWeek);
                            cart.getDays().add(newDay);
                            return newDay;
                        });

                day.getItems().clear();
                if (req.getItems() != null) {
                    for (WeeklyCartItemInput input : req.getItems()) {
                        Product product = productRepository.findById(input.getProductId())
                                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found: " + input.getProductId(), HttpStatus.NOT_FOUND));
                        WeeklyCartItem item = new WeeklyCartItem(day, product, input.getQuantity());
                        day.getItems().add(item);
                    }
                }
            }
        }

        cart.setModificationCount(1);
        cart.setStatus("LOCKED"); // Locked after the 1 allowed modification
        WeeklyCart saved = weeklyCartRepository.save(cart);
        return buildWeeklyCartDto(saved);
    }

    public WeeklyCartDto buildWeeklyCartDto(WeeklyCart cart) {
        WeeklyCartDto dto = new WeeklyCartDto();
        dto.setId(cart.getId());
        dto.setTitle(cart.getTitle());
        dto.setStatus(cart.getStatus());
        dto.setModificationCount(cart.getModificationCount());
        // Can be modified only if status is not locked and modificationCount == 0
        dto.setModifiable(!"LOCKED".equalsIgnoreCase(cart.getStatus()) && cart.getModificationCount() == 0);

        List<WeeklyCartDayDto> dayDtos = new ArrayList<>();
        BigDecimal weeklyTotal = BigDecimal.ZERO;

        // Order days: MONDAY to SUNDAY
        List<String> orderedDays = Arrays.asList("MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY");
        Map<String, WeeklyCartDay> dayMap = cart.getDays().stream()
                .collect(Collectors.toMap(d -> d.getDayOfWeek().toUpperCase(), d -> d, (a, b) -> a));

        for (String dayName : orderedDays) {
            WeeklyCartDay day = dayMap.get(dayName);
            List<WeeklyCartItemDto> itemDtos = new ArrayList<>();
            BigDecimal dayTotal = BigDecimal.ZERO;

            if (day != null) {
                for (WeeklyCartItem item : day.getItems()) {
                    Product p = item.getProduct();
                    MarketPrice mp = marketPriceRepository.findByProductId(p.getId()).orElse(null);
                    BigDecimal unitPrice = mp != null ? mp.getCurrentPrice() : BigDecimal.valueOf(30.0);
                    BigDecimal itemTotal = unitPrice.multiply(item.getQuantity()).setScale(2, RoundingMode.HALF_UP);

                    itemDtos.add(new WeeklyCartItemDto(
                            item.getId(),
                            p.getId(),
                            p.getName(),
                            p.getMarathiName(),
                            p.getUnit(),
                            p.getImageUrl(),
                            item.getQuantity(),
                            unitPrice,
                            itemTotal
                    ));

                    dayTotal = dayTotal.add(itemTotal);
                }
            }

            weeklyTotal = weeklyTotal.add(dayTotal);
            dayDtos.add(new WeeklyCartDayDto(dayName, itemDtos, dayTotal));
        }

        dto.setDays(dayDtos);
        dto.setWeeklyEstimatedTotal(weeklyTotal);
        return dto;
    }
}
