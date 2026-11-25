package com.kisansetu.modules.order.dto;

import com.kisansetu.modules.customer.dto.AddressDto;
import com.kisansetu.modules.order.entity.Order;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

public class OrderDto {
    private UUID id;
    private String orderNumber;
    private LocalDate deliveryDate;
    private String deliverySlot;
    private String orderStatus;
    private BigDecimal subtotal;
    private BigDecimal deliveryFee;
    private BigDecimal logisticsFee;
    private BigDecimal taxAmount;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private String paymentStatus;
    private String paymentReference;
    private AddressDto address;
    private String deliveryAddressJson;
    private List<OrderItemDto> items = new ArrayList<>();
    private Instant createdAt;

    public OrderDto() {}

    public static OrderDto fromEntity(Order order) {
        OrderDto dto = new OrderDto();
        dto.setId(order.getId());
        dto.setOrderNumber(order.getOrderNumber());
        dto.setDeliveryDate(order.getDeliveryDate());
        dto.setDeliverySlot(order.getDeliverySlot());
        dto.setOrderStatus(order.getOrderStatus());
        dto.setSubtotal(order.getSubtotal());
        dto.setDeliveryFee(order.getDeliveryFee());
        dto.setLogisticsFee(order.getLogisticsFee());
        dto.setTaxAmount(order.getTaxAmount());
        dto.setDiscountAmount(order.getDiscountAmount());
        dto.setTotalAmount(order.getTotalAmount());
        dto.setPaymentStatus(order.getPaymentStatus());
        dto.setPaymentReference(order.getPaymentReference());
        dto.setDeliveryAddressJson(order.getDeliveryAddressJson());
        if (order.getAddress() != null) {
            dto.setAddress(AddressDto.fromEntity(order.getAddress()));
        }
        if (order.getItems() != null) {
            dto.setItems(order.getItems().stream().map(OrderItemDto::fromEntity).collect(Collectors.toList()));
        }
        dto.setCreatedAt(order.getCreatedAt());
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
    public LocalDate getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(LocalDate deliveryDate) { this.deliveryDate = deliveryDate; }
    public String getDeliverySlot() { return deliverySlot; }
    public void setDeliverySlot(String deliverySlot) { this.deliverySlot = deliverySlot; }
    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }
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
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public String getPaymentReference() { return paymentReference; }
    public void setPaymentReference(String paymentReference) { this.paymentReference = paymentReference; }
    public AddressDto getAddress() { return address; }
    public void setAddress(AddressDto address) { this.address = address; }
    public String getDeliveryAddressJson() { return deliveryAddressJson; }
    public void setDeliveryAddressJson(String deliveryAddressJson) { this.deliveryAddressJson = deliveryAddressJson; }
    public List<OrderItemDto> getItems() { return items; }
    public void setItems(List<OrderItemDto> items) { this.items = items; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
