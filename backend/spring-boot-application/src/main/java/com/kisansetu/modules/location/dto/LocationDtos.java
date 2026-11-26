package com.kisansetu.modules.location.dto;

import java.util.List;
import java.util.Map;

public class LocationDtos {

    public record GeocodeResult(
            double latitude,
            double longitude,
            String displayName,
            String village,
            String district,
            String state,
            String pincode,
            String country,
            String osmType,
            Long osmId,
            List<Double> boundingBox,
            String provider
    ) {}

    public record NearbyHubResult(
            String hubId,
            String hubCode,
            String hubName,
            String hubType,
            String address,
            String district,
            String state,
            String pincode,
            double latitude,
            double longitude,
            double distanceMeters,
            String distanceType
    ) {}

    public record RouteRequest(
            double originLatitude,
            double originLongitude,
            double destinationLatitude,
            double destinationLongitude,
            String travelMode
    ) {}

    public record RouteCoordinate(double latitude, double longitude) {}

    public record RouteResult(
            double distanceMeters,
            double durationSeconds,
            String travelMode,
            String provider,
            List<RouteCoordinate> geometry,
            String disclaimer
    ) {}

    public record DistanceRequest(
            double originLatitude,
            double originLongitude,
            double destinationLatitude,
            double destinationLongitude,
            String calculationType
    ) {}

    public record ProviderStatus(
            String mapProvider,
            String tileUrl,
            String attribution,
            String geocodingProvider,
            boolean geocodingEnabled,
            String routingProvider,
            boolean routingEnabled,
            String nearbyProvider,
            Map<String, Object> limits
    ) {}
}
