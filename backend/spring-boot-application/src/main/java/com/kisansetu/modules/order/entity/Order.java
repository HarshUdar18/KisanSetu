package com.kisansetu.modules.order.entity;

import com.kisansetu.modules.customer.entity.Address;
import com.kisansetu.modules.servicearea.entity.ServiceArea;
import com.kisansetu.modules.user.entity.User;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "order_number", nullable = false, unique = true, length = 50)
    private String orderNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "address_id")
    private Address address;

    @Column(name = "delivery_address_json", columnDefinition = "TEXT")
    private String deliveryAddressJson;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_area_id")
    private ServiceArea serviceArea;

    @Column(name = "delivery_date", nullable = false)
    private LocalDate deliveryDate;

    @Column(name = "delivery_slot", length = 50)
    private String deliverySlot = "Morning (07:00 AM - 10:00 AM)";

    @Column(name = "order_status", nullable = false, length = 50)
    private String orderStatus = "PENDING_PAYMENT";

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal subtotal = BigDecimal.ZERO;

    @Column(name = "delivery_fee", nullable = false, precision = 10, scale = 2)
    private BigDecimal deliveryFee = BigDecimal.ZERO;

    @Column(name = "logistics_fee", nullable = false, precision = 10, scale = 2)
    private BigDecimal logisticsFee = BigDecimal.ZERO;

    @Column(name = "tax_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal taxAmount = BigDecimal.ZERO;

    @Column(name = "discount_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(name = "total_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalAmount = BigDecimal.ZERO;

    @Column(name = "payment_reference", length = 100)
    private String paymentReference;

    @Column(name = "payment_status", nullable = false, length = 30)
    private String paymentStatus = "PENDING"; // PENDING, COMPLETED, FAILED

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<OrderItem> items = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public Order() {}

    public Order(String orderNumber, User user, Address address, String deliveryAddressJson, ServiceArea serviceArea, LocalDate deliveryDate, String deliverySlot) {
        this.orderNumber = orderNumber;
        this.user = user;
        this.address = address;
        this.deliveryAddressJson = deliveryAddressJson;
        this.serviceArea = serviceArea;
        this.deliveryDate = deliveryDate;
        this.deliverySlot = deliverySlot != null ? deliverySlot : "Morning (07:00 AM - 10:00 AM)";
        this.orderStatus = "PENDING_PAYMENT";
        this.paymentStatus = "PENDING";
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public Address getAddress() { return address; }
    public void setAddress(Address address) { this.address = address; }
    public String getDeliveryAddressJson() { return deliveryAddressJson; }
    public void setDeliveryAddressJson(String deliveryAddressJson) { this.deliveryAddressJson = deliveryAddressJson; }
    public ServiceArea getServiceArea() { return serviceArea; }
    public void setServiceArea(ServiceArea serviceArea) { this.serviceArea = serviceArea; }
    public LocalDate getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(LocalDate deliveryDate) { this.deliveryDate = deliveryDate; }
    public String getDeliverySlot() { return deliverySlot; }
    public void setDeliverySlot(String deliverySlot) { this.deliverySlot = deliverySlot; }
    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    public BigDecimal getDeliveryFee() { return deliveryFee; }
    public void setDeliveryFee(BigDecimal deliveryFee) { this.deliveryFee = deliveryFee; }
    public BigDecimal getLogisticsFee() { return logisticsFee; }
    public void setLogisticsFee(BigDecimal logisticsFee) { this.logisticsFee = logisticsFee; }
    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }
    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public String getPaymentReference() { return paymentReference; }
    public void setPaymentReference(String paymentReference) { this.paymentReference = paymentReference; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
