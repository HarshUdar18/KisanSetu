package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "govt_schemes")
public class GovtScheme {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false, length = 200)
    private String title;
    @Column(nullable = false, length = 150)
    private String ministry;
    @Column(nullable = false, length = 80)
    private String category;
    @Column(name = "benefit_summary", nullable = false, columnDefinition = "TEXT")
    private String benefitSummary;
    @Column(columnDefinition = "TEXT")
    private String eligibility;
    @Column(name = "apply_url", length = 500)
    private String applyUrl;
    @Column(name = "is_active", nullable = false)
    private boolean isActive = true;
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getMinistry() { return ministry; }
    public void setMinistry(String ministry) { this.ministry = ministry; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getBenefitSummary() { return benefitSummary; }
    public void setBenefitSummary(String benefitSummary) { this.benefitSummary = benefitSummary; }
    public String getEligibility() { return eligibility; }
    public void setEligibility(String eligibility) { this.eligibility = eligibility; }
    public String getApplyUrl() { return applyUrl; }
    public void setApplyUrl(String applyUrl) { this.applyUrl = applyUrl; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public Instant getCreatedAt() { return createdAt; }
}
