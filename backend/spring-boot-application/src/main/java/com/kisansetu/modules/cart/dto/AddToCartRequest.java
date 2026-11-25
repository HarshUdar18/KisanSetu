package com.kisansetu.modules.cart.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.util.UUID;

public class AddToCartRequest {

    @NotNull(message = "Product ID is required")
    private UUID productId;

    @NotNull(message = "Quantity is required")
    @Positive(message = "Quantity must be greater than zero")
    private BigDecimal quantity = BigDecimal.ONE;

    public AddToCartRequest() {}

    public AddToCartRequest(UUID productId, BigDecimal quantity) {
        this.productId = productId;
        this.quantity = quantity;
    }

    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }
}
