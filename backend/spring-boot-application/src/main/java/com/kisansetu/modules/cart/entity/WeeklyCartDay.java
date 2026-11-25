package com.kisansetu.modules.cart.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "weekly_cart_days", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"weekly_cart_id", "day_of_week"})
})
public class WeeklyCartDay {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "weekly_cart_id", nullable = false)
    private WeeklyCart weeklyCart;

    @Column(name = "day_of_week", nullable = false, length = 15)
    private String dayOfWeek; // MONDAY, TUESDAY, etc.

    @OneToMany(mappedBy = "weeklyCartDay", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<WeeklyCartItem> items = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public WeeklyCartDay() {}

    public WeeklyCartDay(WeeklyCart weeklyCart, String dayOfWeek) {
        this.weeklyCart = weeklyCart;
        this.dayOfWeek = dayOfWeek;
        this.createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public WeeklyCart getWeeklyCart() { return weeklyCart; }
    public void setWeeklyCart(WeeklyCart weeklyCart) { this.weeklyCart = weeklyCart; }
    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }
    public List<WeeklyCartItem> getItems() { return items; }
    public void setItems(List<WeeklyCartItem> items) { this.items = items; }
    public Instant getCreatedAt() { return createdAt; }
}
