package com.kisansetu.modules.tracking.dto;

import com.kisansetu.modules.tracking.entity.TrackingEvent;
import java.time.Instant;
import java.util.UUID;

public class TrackingEventDto {
    private UUID id;
    private String status;
    private String title;
    private String description;
    private String location;
    private Instant occurredAt;
    private boolean isCompleted;
    private int displayOrder;

    public TrackingEventDto() {}

    public static TrackingEventDto fromEntity(TrackingEvent event) {
        TrackingEventDto dto = new TrackingEventDto();
        dto.setId(event.getId());
        dto.setStatus(event.getStatus());
        dto.setTitle(event.getTitle());
        dto.setDescription(event.getDescription());
        dto.setLocation(event.getLocation());
        dto.setOccurredAt(event.getOccurredAt());
        dto.setCompleted(event.isCompleted());
        dto.setDisplayOrder(event.getDisplayOrder());
        return dto;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public Instant getOccurredAt() { return occurredAt; }
    public void setOccurredAt(Instant occurredAt) { this.occurredAt = occurredAt; }
    public boolean isCompleted() { return isCompleted; }
    public void setCompleted(boolean completed) { isCompleted = completed; }
    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }
}
