package com.kisansetu.modules.operations.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "quality_inspections")
public class QualityInspection {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(name = "collection_id")
    private UUID collectionId;
    @Column(name = "farmer_id", nullable = false)
    private UUID farmerId;
    @Column(name = "product_id", nullable = false)
    private UUID productId;
    @Column(nullable = false, length = 20)
    private String grade = "GRADE_A";
    @Column(name = "accepted_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal acceptedKg;
    @Column(name = "rejected_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal rejectedKg = BigDecimal.ZERO;
    @Column(name = "inspector_notes", columnDefinition = "TEXT")
    private String inspectorNotes;
    @Column(nullable = false, length = 30)
    private String status = "COMPLETED";
    @Column(name = "inspected_at", nullable = false)
    private Instant inspectedAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getCollectionId() { return collectionId; }
    public void setCollectionId(UUID collectionId) { this.collectionId = collectionId; }
    public UUID getFarmerId() { return farmerId; }
    public void setFarmerId(UUID farmerId) { this.farmerId = farmerId; }
    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }
    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }
    public BigDecimal getAcceptedKg() { return acceptedKg; }
    public void setAcceptedKg(BigDecimal acceptedKg) { this.acceptedKg = acceptedKg; }
    public BigDecimal getRejectedKg() { return rejectedKg; }
    public void setRejectedKg(BigDecimal rejectedKg) { this.rejectedKg = rejectedKg; }
    public String getInspectorNotes() { return inspectorNotes; }
    public void setInspectorNotes(String inspectorNotes) { this.inspectorNotes = inspectorNotes; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getInspectedAt() { return inspectedAt; }
    public void setInspectedAt(Instant inspectedAt) { this.inspectedAt = inspectedAt; }
}
