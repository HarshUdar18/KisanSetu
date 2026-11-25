package com.kisansetu.modules.order.dto;

import com.kisansetu.modules.order.entity.OrderItem;
import java.math.BigDecimal;
import java.util.UUID;

public class OrderItemDto {
    private UUID id;
    private UUID productId;
    private String productName;
    private BigDecimal quantity;
    private String unit;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;

    public OrderItemDto() {}

    public static OrderItemDto fromEntity(OrderItem item) {
        OrderItemDto dto = new OrderItemDto();
        dto.setId(item.getId());
        dto.setProductId(item.getProduct() != null ? item.getProduct().getId() : null);
        dto.setProductName(item.getProductName());
        dto.setQuantity(item.getQuantity());
        dto.setUnit(item.getUnit());
        dto.setUnitPrice(item.getUnitPrice());
        dto.setTotalPrice(item.getTotalPrice());
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }
}
