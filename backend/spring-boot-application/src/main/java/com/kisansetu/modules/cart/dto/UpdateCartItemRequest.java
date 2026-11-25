package com.kisansetu.modules.cart.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import java.math.BigDecimal;

public class UpdateCartItemRequest {

    @NotNull(message = "Quantity is required")
    @PositiveOrZero(message = "Quantity must be zero or positive")
    private BigDecimal quantity;

    public UpdateCartItemRequest() {}

    public UpdateCartItemRequest(BigDecimal quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }
}
