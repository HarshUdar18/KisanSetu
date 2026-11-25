package com.kisansetu.modules.cart.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.cart.dto.*;
import com.kisansetu.modules.cart.entity.Cart;
import com.kisansetu.modules.cart.entity.CartItem;
import com.kisansetu.modules.cart.repository.CartItemRepository;
import com.kisansetu.modules.cart.repository.CartRepository;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final MarketPriceRepository marketPriceRepository;
    private final UserRepository userRepository;

    public CartService(CartRepository cartRepository,
                       CartItemRepository cartItemRepository,
                       ProductRepository productRepository,
                       MarketPriceRepository marketPriceRepository,
                       UserRepository userRepository) {
        this.cartRepository = cartRepository;
        this.cartItemRepository = cartItemRepository;
        this.productRepository = productRepository;
        this.marketPriceRepository = marketPriceRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Cart getOrCreateCartEntity(UUID userId) {
        return cartRepository.findByUserId(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "User not found", HttpStatus.NOT_FOUND));
                    return cartRepository.save(new Cart(user));
                });
    }

    @Transactional
    public CartDto getCart(UUID userId) {
        Cart cart = getOrCreateCartEntity(userId);
        return buildCartDto(cart);
    }

    @Transactional
    public CartDto addItem(UUID userId, AddToCartRequest request) {
        Cart cart = getOrCreateCartEntity(userId);
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found", HttpStatus.NOT_FOUND));

        if (!product.isAvailable()) {
            throw new ApiException("PRODUCT_UNAVAILABLE", "Product is currently out of stock", HttpStatus.BAD_REQUEST);
        }

        Optional<CartItem> existingItem = cartItemRepository.findByCartIdAndProductId(cart.getId(), product.getId());
        if (existingItem.isPresent()) {
            CartItem item = existingItem.get();
            item.setQuantity(item.getQuantity().add(request.getQuantity()));
            cartItemRepository.save(item);
        } else {
            CartItem newItem = new CartItem(cart, product, request.getQuantity());
            cartItemRepository.save(newItem);
            cart.getItems().add(newItem);
        }

        return getCart(userId);
    }

    @Transactional
    public CartDto updateItem(UUID userId, UUID itemId, UpdateCartItemRequest request) {
        Cart cart = getOrCreateCartEntity(userId);
        CartItem item = cartItemRepository.findById(itemId)
                .orElseThrow(() -> new ApiException("CART_ITEM_NOT_FOUND", "Cart item not found", HttpStatus.NOT_FOUND));

        if (!item.getCart().getId().equals(cart.getId())) {
            throw new ApiException("UNAUTHORIZED", "Not your cart item", HttpStatus.FORBIDDEN);
        }

        if (request.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
            cart.getItems().remove(item);
            cartItemRepository.delete(item);
        } else {
            item.setQuantity(request.getQuantity());
            cartItemRepository.save(item);
        }

        return getCart(userId);
    }

    @Transactional
    public CartDto removeItem(UUID userId, UUID itemId) {
        Cart cart = getOrCreateCartEntity(userId);
        CartItem item = cartItemRepository.findById(itemId)
                .orElseThrow(() -> new ApiException("CART_ITEM_NOT_FOUND", "Cart item not found", HttpStatus.NOT_FOUND));

        if (!item.getCart().getId().equals(cart.getId())) {
            throw new ApiException("UNAUTHORIZED", "Not your cart item", HttpStatus.FORBIDDEN);
        }

        cart.getItems().remove(item);
        cartItemRepository.delete(item);
        return getCart(userId);
    }

    @Transactional
    public void clearCart(UUID userId) {
        Cart cart = getOrCreateCartEntity(userId);
        cartItemRepository.deleteByCartId(cart.getId());
        cart.getItems().clear();
    }

    public CartDto buildCartDto(Cart cart) {
        CartDto dto = new CartDto();
        dto.setId(cart.getId());

        List<CartItemDto> itemDtos = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        int count = 0;

        for (CartItem item : cart.getItems()) {
            Product p = item.getProduct();
            MarketPrice mp = marketPriceRepository.findByProductId(p.getId()).orElse(null);
            BigDecimal unitPrice = mp != null ? mp.getCurrentPrice() : BigDecimal.valueOf(30.0);
            BigDecimal itemTotal = unitPrice.multiply(item.getQuantity()).setScale(2, RoundingMode.HALF_UP);

            itemDtos.add(new CartItemDto(
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

            subtotal = subtotal.add(itemTotal);
            count += item.getQuantity().intValue();
        }

        dto.setItems(itemDtos);
        dto.setItemCount(count);
        dto.setSubtotal(subtotal);

        if (subtotal.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal deliveryFee = subtotal.compareTo(BigDecimal.valueOf(300.0)) >= 0 ? BigDecimal.ZERO : BigDecimal.valueOf(30.0);
            BigDecimal logisticsFee = BigDecimal.valueOf(15.0);
            BigDecimal taxAmount = subtotal.multiply(BigDecimal.valueOf(0.05)).setScale(2, RoundingMode.HALF_UP);
            BigDecimal total = subtotal.add(deliveryFee).add(logisticsFee).add(taxAmount);

            dto.setDeliveryFee(deliveryFee);
            dto.setLogisticsFee(logisticsFee);
            dto.setTaxAmount(taxAmount);
            dto.setTotalAmount(total);
        } else {
            dto.setDeliveryFee(BigDecimal.ZERO);
            dto.setLogisticsFee(BigDecimal.ZERO);
            dto.setTaxAmount(BigDecimal.ZERO);
            dto.setTotalAmount(BigDecimal.ZERO);
        }

        return dto;
    }
}
