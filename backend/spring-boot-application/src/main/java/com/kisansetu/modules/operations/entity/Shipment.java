package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "shipments")
public class Shipment {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(name = "order_id")
    private UUID orderId;
    @Column(name = "delivery_partner_name", length = 120)
    private String deliveryPartnerName;
    @Column(name = "delivery_partner_phone", length = 20)
    private String deliveryPartnerPhone;
    @Column(name = "vehicle_number", length = 30)
    private String vehicleNumber;
    @Column(name = "origin_hub", length = 150)
    private String originHub;
    @Column(name = "destination_address", length = 255)
    private String destinationAddress;
    @Column(nullable = false, length = 30)
    private String status = "ASSIGNED";
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getOrderId() { return orderId; }
    public void setOrderId(UUID orderId) { this.orderId = orderId; }
    public String getDeliveryPartnerName() { return deliveryPartnerName; }
    public void setDeliveryPartnerName(String deliveryPartnerName) { this.deliveryPartnerName = deliveryPartnerName; }
    public String getDeliveryPartnerPhone() { return deliveryPartnerPhone; }
    public void setDeliveryPartnerPhone(String deliveryPartnerPhone) { this.deliveryPartnerPhone = deliveryPartnerPhone; }
    public String getVehicleNumber() { return vehicleNumber; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }
    public String getOriginHub() { return originHub; }
    public void setOriginHub(String originHub) { this.originHub = originHub; }
    public String getDestinationAddress() { return destinationAddress; }
    public void setDestinationAddress(String destinationAddress) { this.destinationAddress = destinationAddress; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
