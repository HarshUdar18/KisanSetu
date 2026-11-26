package com.kisansetu.modules.location.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "route_cache", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"provider", "travel_mode", "origin_hash", "destination_hash"})
})
public class RouteCache {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 50)
    private String provider;

    @Column(name = "travel_mode", nullable = false, length = 30)
    private String travelMode;

    @Column(name = "origin_hash", nullable = false, length = 64)
    private String originHash;

    @Column(name = "destination_hash", nullable = false, length = 64)
    private String destinationHash;

    @Column(name = "route_response", nullable = false, columnDefinition = "TEXT")
    private String routeResponse;

    @Column(name = "distance_meters", nullable = false, precision = 14, scale = 2)
    private BigDecimal distanceMeters;

    @Column(name = "duration_seconds", nullable = false, precision = 14, scale = 2)
    private BigDecimal durationSeconds;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }
    public String getTravelMode() { return travelMode; }
    public void setTravelMode(String travelMode) { this.travelMode = travelMode; }
    public String getOriginHash() { return originHash; }
    public void setOriginHash(String originHash) { this.originHash = originHash; }
    public String getDestinationHash() { return destinationHash; }
    public void setDestinationHash(String destinationHash) { this.destinationHash = destinationHash; }
    public String getRouteResponse() { return routeResponse; }
    public void setRouteResponse(String routeResponse) { this.routeResponse = routeResponse; }
    public BigDecimal getDistanceMeters() { return distanceMeters; }
    public void setDistanceMeters(BigDecimal distanceMeters) { this.distanceMeters = distanceMeters; }
    public BigDecimal getDurationSeconds() { return durationSeconds; }
    public void setDurationSeconds(BigDecimal durationSeconds) { this.durationSeconds = durationSeconds; }
    public Instant getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Instant expiresAt) { this.expiresAt = expiresAt; }
    public Instant getCreatedAt() { return createdAt; }
}
