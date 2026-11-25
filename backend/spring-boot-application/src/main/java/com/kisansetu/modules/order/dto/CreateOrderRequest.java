package com.kisansetu.modules.order.dto;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.UUID;

public class CreateOrderRequest {

    @NotNull(message = "Delivery address ID is required")
    private UUID addressId;

    @NotNull(message = "Delivery date is required")
    private LocalDate deliveryDate;

    private String deliverySlot = "Morning (07:00 AM - 10:00 AM)";

    public CreateOrderRequest() {}

    public UUID getAddressId() { return addressId; }
    public void setAddressId(UUID addressId) { this.addressId = addressId; }
    public LocalDate getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(LocalDate deliveryDate) { this.deliveryDate = deliveryDate; }
    public String getDeliverySlot() { return deliverySlot; }
    public void setDeliverySlot(String deliverySlot) { this.deliverySlot = deliverySlot; }
}
