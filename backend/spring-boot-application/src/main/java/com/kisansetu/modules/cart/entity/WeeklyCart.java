package com.kisansetu.modules.cart.entity;

import com.kisansetu.modules.user.entity.User;
import jakarta.persistence.*;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "weekly_carts")
public class WeeklyCart {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 150)
    private String title = "My Weekly Produce Plan";

    @Column(nullable = false, length = 30)
    private String status = "DRAFT"; // DRAFT, SUBMITTED, LOCKED

    @Column(name = "modification_count", nullable = false)
    private int modificationCount = 0;

    @OneToMany(mappedBy = "weeklyCart", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<WeeklyCartDay> days = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public WeeklyCart() {}

    public WeeklyCart(User user, String title) {
        this.user = user;
        this.title = title;
        this.status = "DRAFT";
        this.modificationCount = 0;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getModificationCount() { return modificationCount; }
    public void setModificationCount(int modificationCount) { this.modificationCount = modificationCount; }
    public List<WeeklyCartDay> getDays() { return days; }
    public void setDays(List<WeeklyCartDay> days) { this.days = days; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
