package com.kisansetu.modules.cart.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.cart.dto.AddToCartRequest;
import com.kisansetu.modules.cart.dto.CartDto;
import com.kisansetu.modules.cart.dto.UpdateCartItemRequest;
import com.kisansetu.modules.cart.service.CartService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/cart")
@Tag(name = "Customer Cart", description = "Standard shopping cart with authoritative live price calculation")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping
    @Operation(summary = "Get user cart with live market price re-evaluation")
    public ResponseEntity<ApiResponse<CartDto>> getCart(@AuthenticationPrincipal UserPrincipal principal) {
        CartDto cart = cartService.getCart(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Cart retrieved", cart));
    }

    @PostMapping("/items")
    @Operation(summary = "Add product item to cart")
    public ResponseEntity<ApiResponse<CartDto>> addItem(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody AddToCartRequest request) {
        CartDto cart = cartService.addItem(principal.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok("Item added to cart", cart));
    }

    @PutMapping("/items/{id}")
    @Operation(summary = "Update cart item quantity")
    public ResponseEntity<ApiResponse<CartDto>> updateItem(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @Valid @RequestBody UpdateCartItemRequest request) {
        CartDto cart = cartService.updateItem(principal.getId(), id, request);
        return ResponseEntity.ok(ApiResponse.ok("Cart updated", cart));
    }

    @DeleteMapping("/items/{id}")
    @Operation(summary = "Remove item from cart")
    public ResponseEntity<ApiResponse<CartDto>> removeItem(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        CartDto cart = cartService.removeItem(principal.getId(), id);
        return ResponseEntity.ok(ApiResponse.ok("Item removed from cart", cart));
    }

    @DeleteMapping
    @Operation(summary = "Clear all items in cart")
    public ResponseEntity<ApiResponse<Void>> clearCart(@AuthenticationPrincipal UserPrincipal principal) {
        cartService.clearCart(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Cart cleared", null));
    }
}
