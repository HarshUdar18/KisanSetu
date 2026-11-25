package com.kisansetu.modules.subscription.dto;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.UUID;

public class CreateSubscriptionRequest {

    private UUID weeklyCartId;

    @NotNull(message = "Address ID is required")
    private UUID addressId;

    private String frequency = "WEEKLY"; // WEEKLY, BIWEEKLY, MONTHLY

    @NotNull(message = "Start date is required")
    private LocalDate startDate;

    private String deliveryPreferences;

    public CreateSubscriptionRequest() {}

    public UUID getWeeklyCartId() { return weeklyCartId; }
    public void setWeeklyCartId(UUID weeklyCartId) { this.weeklyCartId = weeklyCartId; }
    public UUID getAddressId() { return addressId; }
    public void setAddressId(UUID addressId) { this.addressId = addressId; }
    public String getFrequency() { return frequency; }
    public void setFrequency(String frequency) { this.frequency = frequency; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public String getDeliveryPreferences() { return deliveryPreferences; }
    public void setDeliveryPreferences(String deliveryPreferences) { this.deliveryPreferences = deliveryPreferences; }
}
