package com.kisansetu.modules.subscription.entity;

import com.kisansetu.modules.cart.entity.WeeklyCart;
import com.kisansetu.modules.customer.entity.Address;
import com.kisansetu.modules.servicearea.entity.ServiceArea;
import com.kisansetu.modules.user.entity.User;
import jakarta.persistence.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "subscriptions")
public class Subscription {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "weekly_cart_id")
    private WeeklyCart weeklyCart;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_area_id")
    private ServiceArea serviceArea;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "address_id")
    private Address address;

    @Column(nullable = false, length = 30)
    private String frequency = "WEEKLY"; // WEEKLY, BIWEEKLY, MONTHLY

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(nullable = false, length = 30)
    private String status = "ACTIVE"; // ACTIVE, PAUSED, CANCELLED

    @Column(name = "delivery_preferences")
    private String deliveryPreferences;

    @OneToMany(mappedBy = "subscription", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<SubscriptionItem> items = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public Subscription() {}

    public Subscription(User user, WeeklyCart weeklyCart, ServiceArea serviceArea, Address address, String frequency, LocalDate startDate, String deliveryPreferences) {
        this.user = user;
        this.weeklyCart = weeklyCart;
        this.serviceArea = serviceArea;
        this.address = address;
        this.frequency = frequency;
        this.startDate = startDate;
        this.deliveryPreferences = deliveryPreferences;
        this.status = "ACTIVE";
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
    public WeeklyCart getWeeklyCart() { return weeklyCart; }
    public void setWeeklyCart(WeeklyCart weeklyCart) { this.weeklyCart = weeklyCart; }
    public ServiceArea getServiceArea() { return serviceArea; }
    public void setServiceArea(ServiceArea serviceArea) { this.serviceArea = serviceArea; }
    public Address getAddress() { return address; }
    public void setAddress(Address address) { this.address = address; }
    public String getFrequency() { return frequency; }
    public void setFrequency(String frequency) { this.frequency = frequency; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getDeliveryPreferences() { return deliveryPreferences; }
    public void setDeliveryPreferences(String deliveryPreferences) { this.deliveryPreferences = deliveryPreferences; }
    public List<SubscriptionItem> getItems() { return items; }
    public void setItems(List<SubscriptionItem> items) { this.items = items; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
