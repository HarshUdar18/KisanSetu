package com.kisansetu.modules.product.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "product_translations", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"product_id", "language_code"})
})
public class ProductTranslation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "product_id", nullable = false)
    private UUID productId;

    @Column(name = "language_code", nullable = false, length = 10)
    private String languageCode;

    @Column(name = "localized_name", nullable = false, length = 150)
    private String localizedName;

    @Column(name = "localized_description", columnDefinition = "TEXT")
    private String localizedDescription;

    @Column(name = "search_aliases", columnDefinition = "TEXT")
    private String searchAliases;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getProductId() { return productId; }
    public void setProductId(UUID productId) { this.productId = productId; }
    public String getLanguageCode() { return languageCode; }
    public void setLanguageCode(String languageCode) { this.languageCode = languageCode; }
    public String getLocalizedName() { return localizedName; }
    public void setLocalizedName(String localizedName) { this.localizedName = localizedName; }
    public String getLocalizedDescription() { return localizedDescription; }
    public void setLocalizedDescription(String localizedDescription) { this.localizedDescription = localizedDescription; }
    public String getSearchAliases() { return searchAliases; }
    public void setSearchAliases(String searchAliases) { this.searchAliases = searchAliases; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
