package com.kisansetu.modules.tracking.dto;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class OrderTrackingTimelineDto {
    private UUID orderId;
    private String orderNumber;
    private String currentStatus;
    private List<TrackingEventDto> events = new ArrayList<>();

    public OrderTrackingTimelineDto() {}

    public OrderTrackingTimelineDto(UUID orderId, String orderNumber, String currentStatus, List<TrackingEventDto> events) {
        this.orderId = orderId;
        this.orderNumber = orderNumber;
        this.currentStatus = currentStatus;
        this.events = events;
    }

    public UUID getOrderId() { return orderId; }
    public void setOrderId(UUID orderId) { this.orderId = orderId; }
    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
    public String getCurrentStatus() { return currentStatus; }
    public void setCurrentStatus(String currentStatus) { this.currentStatus = currentStatus; }
    public List<TrackingEventDto> getEvents() { return events; }
    public void setEvents(List<TrackingEventDto> events) { this.events = events; }
}
