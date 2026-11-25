package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "fpo_organizations")
public class FpoOrganization {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false, length = 150)
    private String name;
    @Column(name = "registration_number", nullable = false, unique = true, length = 100)
    private String registrationNumber;
    @Column(nullable = false, length = 100)
    private String district;
    @Column(nullable = false, length = 100)
    private String state = "Maharashtra";
    @Column(name = "contact_phone", length = 20)
    private String contactPhone;
    @Column(name = "member_count", nullable = false)
    private int memberCount = 0;
    @Column(nullable = false, length = 30)
    private String status = "ACTIVE";
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getRegistrationNumber() { return registrationNumber; }
    public void setRegistrationNumber(String registrationNumber) { this.registrationNumber = registrationNumber; }
    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }
    public int getMemberCount() { return memberCount; }
    public void setMemberCount(int memberCount) { this.memberCount = memberCount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getCreatedAt() { return createdAt; }
}
