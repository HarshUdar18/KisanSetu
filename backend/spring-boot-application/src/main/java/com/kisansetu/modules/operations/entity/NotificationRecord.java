package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "notifications")
public class NotificationRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(name = "user_id")
    private UUID userId;
    @Column(nullable = false, length = 150)
    private String title;
    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;
    @Column(nullable = false, length = 40)
    private String type = "GENERAL";
    @Column(name = "is_read", nullable = false)
    private boolean isRead = false;
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }
    public Instant getCreatedAt() { return createdAt; }
}
