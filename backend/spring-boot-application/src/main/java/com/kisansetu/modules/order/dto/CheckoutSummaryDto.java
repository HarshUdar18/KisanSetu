package com.kisansetu.modules.order.dto;

import com.kisansetu.modules.cart.dto.CartItemDto;
import com.kisansetu.modules.customer.dto.AddressDto;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class CheckoutSummaryDto {
    private List<CartItemDto> items = new ArrayList<>();
    private AddressDto selectedAddress;
    private boolean serviceable = true;
    private String serviceAreaName;
    private BigDecimal subtotal = BigDecimal.ZERO;
    private BigDecimal deliveryFee = BigDecimal.ZERO;
    private BigDecimal logisticsFee = BigDecimal.ZERO;
    private BigDecimal taxAmount = BigDecimal.ZERO;
    private BigDecimal discountAmount = BigDecimal.ZERO;
    private BigDecimal totalAmount = BigDecimal.ZERO;

    public CheckoutSummaryDto() {}

    public List<CartItemDto> getItems() { return items; }
    public void setItems(List<CartItemDto> items) { this.items = items; }
    public AddressDto getSelectedAddress() { return selectedAddress; }
    public void setSelectedAddress(AddressDto selectedAddress) { this.selectedAddress = selectedAddress; }
    public boolean isServiceable() { return serviceable; }
    public void setServiceable(boolean serviceable) { this.serviceable = serviceable; }
    public String getServiceAreaName() { return serviceAreaName; }
    public void setServiceAreaName(String serviceAreaName) { this.serviceAreaName = serviceAreaName; }
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    public BigDecimal getDeliveryFee() { return deliveryFee; }
    public void setDeliveryFee(BigDecimal deliveryFee) { this.deliveryFee = deliveryFee; }
    public BigDecimal getLogisticsFee() { return logisticsFee; }
    public void setLogisticsFee(BigDecimal logisticsFee) { this.logisticsFee = logisticsFee; }
    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }
    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
}
