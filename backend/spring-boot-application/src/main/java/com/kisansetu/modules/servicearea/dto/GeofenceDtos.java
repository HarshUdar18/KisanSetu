package com.kisansetu.modules.servicearea.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public class GeofenceDtos {

    public record ServiceCapabilitiesDto(
            boolean customerDeliveryEnabled,
            boolean customerCollectionEnabled,
            boolean customerOrderEnabled,
            boolean farmerRegistrationEnabled,
            boolean farmerListingEnabled,
            boolean farmCollectionEnabled,
            boolean pincodeFallbackCustomerEnabled,
            boolean pincodeFallbackFarmerEnabled,
            BigDecimal minimumOrderAmount,
            String ruleStatus
    ) {
        public ServiceCapabilitiesDto(
                boolean customerDeliveryEnabled,
                boolean customerCollectionEnabled,
                boolean customerOrderEnabled,
                boolean farmerRegistrationEnabled,
                boolean farmerListingEnabled,
                boolean farmCollectionEnabled,
                BigDecimal minimumOrderAmount,
                String ruleStatus) {
            this(
                    customerDeliveryEnabled,
                    customerCollectionEnabled,
                    customerOrderEnabled,
                    farmerRegistrationEnabled,
                    farmerListingEnabled,
                    farmCollectionEnabled,
                    false,
                    false,
                    minimumOrderAmount,
                    ruleStatus
            );
        }
    }

    public record ServiceAreaSummaryDto(
            UUID regionId,
            String regionCode,
            String regionName,
            String cityName,
            UUID zoneId,
            String zoneCode,
            String zoneName,
            UUID localityId,
            String localityCode,
            String localityName,
            String localityStatus,
            boolean hasActiveBoundary,
            Integer activeBoundaryVersion,
            String boundarySource,
            ServiceCapabilitiesDto capabilities
    ) {}

    public record GeofenceValidateRequest(
            double latitude,
            double longitude,
            String requestedOperation,
            String pinCode,
            String locality,
            String city,
            String state,
            UUID addressId
    ) {
        public GeofenceValidateRequest(double latitude, double longitude, String requestedOperation) {
            this(latitude, longitude, requestedOperation, null, null, null, null, null);
        }
    }

    public record GeofenceValidationResult(
            boolean insideServiceArea,
            boolean serviceable,
            String reasonCode,
            String decisionMethod,
            String message,
            UUID regionId,
            String regionName,
            UUID zoneId,
            String zoneName,
            UUID localityId,
            String localityCode,
            String localityName,
            Integer boundaryVersion,
            String pinCode,
            boolean pinCodeVerified,
            boolean boundaryVerified,
            String capability,
            ServiceCapabilitiesDto capabilities
    ) {}

    public record PincodeServiceabilityDto(
            UUID pincodeId,
            String pinCode,
            String stateName,
            String districtName,
            String postalLocalityName,
            UUID localityId,
            String localityCode,
            String localityName,
            UUID zoneId,
            String serviceabilityStatus,
            boolean customerDeliveryEnabled,
            boolean farmerCollectionEnabled,
            String dataSource,
            String sourceUrl,
            String verificationStatus,
            Instant lastVerifiedAt,
            Instant approvedAt,
            Instant effectiveFrom,
            Instant effectiveUntil
    ) {}

    public record ImportPincodeRequest(
            String pinCode,
            String stateName,
            String districtName,
            String postalLocalityName,
            UUID localityId,
            String dataSource,
            String sourceUrl,
            boolean customerDeliveryEnabled,
            boolean farmerCollectionEnabled
    ) {}

    public record ReviewPincodeRequest(
            String verificationStatus,
            String serviceabilityStatus,
            Boolean customerDeliveryEnabled,
            Boolean farmerCollectionEnabled,
            String reason
    ) {}

    public record ImportBoundaryRequest(
            String boundaryName,
            String geoJson,
            String boundarySource,
            String sourceUrl,
            String sourceLicense,
            String sourceVersion,
            String changeReason
    ) {}

    public record WorkflowTransitionRequest(
            String reason
    ) {}

    public record UpdateCoverageRulesRequest(
            Boolean customerDeliveryEnabled,
            Boolean farmerRegistrationEnabled,
            Boolean farmerListingEnabled,
            Boolean customerOrderEnabled,
            Boolean collectionEnabled,
            Boolean deliveryEnabled,
            Boolean pincodeFallbackCustomerEnabled,
            Boolean pincodeFallbackFarmerEnabled,
            BigDecimal minimumOrderAmount,
            String status,
            String reason
    ) {}

    public record BoundaryResponseDto(
            UUID geofenceId,
            UUID localityId,
            String localityCode,
            String localityName,
            String boundaryName,
            int boundaryVersion,
            String verificationStatus,
            String boundarySource,
            String sourceUrl,
            String sourceLicense,
            String sourceVersion,
            String geoJson,
            Instant verifiedAt
    ) {}
}
