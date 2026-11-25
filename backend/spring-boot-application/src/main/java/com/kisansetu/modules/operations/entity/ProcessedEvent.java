package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "processed_events")
public class ProcessedEvent {
    @Id
    @Column(name = "event_id", length = 100)
    private String eventId;

    @Column(name = "event_type", nullable = false, length = 120)
    private String eventType;

    @Column(name = "processed_at", nullable = false)
    private Instant processedAt = Instant.now();

    public ProcessedEvent() {}

    public ProcessedEvent(String eventId, String eventType) {
        this.eventId = eventId;
        this.eventType = eventType;
        this.processedAt = Instant.now();
    }

    public String getEventId() { return eventId; }
    public String getEventType() { return eventType; }
    public Instant getProcessedAt() { return processedAt; }
}
