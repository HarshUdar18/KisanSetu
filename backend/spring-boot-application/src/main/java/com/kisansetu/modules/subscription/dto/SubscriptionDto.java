package com.kisansetu.modules.subscription.dto;

import com.kisansetu.modules.customer.dto.AddressDto;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class SubscriptionDto {
    private UUID id;
    private UUID weeklyCartId;
    private String frequency;
    private LocalDate startDate;
    private String status;
    private String deliveryPreferences;
    private AddressDto address;
    private List<SubscriptionItemDto> items = new ArrayList<>();

    public SubscriptionDto() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getWeeklyCartId() { return weeklyCartId; }
    public void setWeeklyCartId(UUID weeklyCartId) { this.weeklyCartId = weeklyCartId; }
    public String getFrequency() { return frequency; }
    public void setFrequency(String frequency) { this.frequency = frequency; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getDeliveryPreferences() { return deliveryPreferences; }
    public void setDeliveryPreferences(String deliveryPreferences) { this.deliveryPreferences = deliveryPreferences; }
    public AddressDto getAddress() { return address; }
    public void setAddress(AddressDto address) { this.address = address; }
    public List<SubscriptionItemDto> getItems() { return items; }
    public void setItems(List<SubscriptionItemDto> items) { this.items = items; }
}
