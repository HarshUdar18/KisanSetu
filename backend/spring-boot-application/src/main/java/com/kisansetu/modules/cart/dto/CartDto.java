package com.kisansetu.modules.cart.dto;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class CartDto {
    private UUID id;
    private List<CartItemDto> items = new ArrayList<>();
    private int itemCount;
    private BigDecimal subtotal = BigDecimal.ZERO;
    private BigDecimal deliveryFee = BigDecimal.ZERO;
    private BigDecimal logisticsFee = BigDecimal.ZERO;
    private BigDecimal taxAmount = BigDecimal.ZERO;
    private BigDecimal totalAmount = BigDecimal.ZERO;

    public CartDto() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public List<CartItemDto> getItems() { return items; }
    public void setItems(List<CartItemDto> items) { this.items = items; }
    public int getItemCount() { return itemCount; }
    public void setItemCount(int itemCount) { this.itemCount = itemCount; }
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    public BigDecimal getDeliveryFee() { return deliveryFee; }
    public void setDeliveryFee(BigDecimal deliveryFee) { this.deliveryFee = deliveryFee; }
    public BigDecimal getLogisticsFee() { return logisticsFee; }
    public void setLogisticsFee(BigDecimal logisticsFee) { this.logisticsFee = logisticsFee; }
    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
}
