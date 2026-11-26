package com.kisansetu.modules.servicearea;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.location.spatial.SpatialLocationService;
import com.kisansetu.modules.servicearea.dto.GeofenceDtos.ImportBoundaryRequest;
import com.kisansetu.modules.servicearea.service.GeofenceService;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mock;

class GeofenceModuleTest {

    private final JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
    private final SpatialLocationService spatialService = new SpatialLocationService(jdbcTemplate);
    private final GeofenceService geofenceService = new GeofenceService(jdbcTemplate, spatialService, new ObjectMapper());

    @Test
    void validatePoint_rejectsOutOfRangeCoordinates() {
        assertThrows(ApiException.class, () -> geofenceService.validatePoint(95.0, 73.85, "CUSTOMER_DELIVERY"));
        assertThrows(ApiException.class, () -> geofenceService.validatePoint(18.52, -185.0, "CUSTOMER_DELIVERY"));
    }

    @Test
    void importGeoJsonBoundary_requiresSourceAndLicenseProvenance() {
        ImportBoundaryRequest missingProvenance = new ImportBoundaryRequest(
                "Test Boundary",
                "{\"type\":\"Polygon\",\"coordinates\":[[[73.8,18.5],[73.9,18.5],[73.9,18.6],[73.8,18.6],[73.8,18.5]]]}",
                "",
                null,
                "",
                "v1",
                "test"
        );
        ApiException ex = assertThrows(ApiException.class, () ->
                geofenceService.importGeoJsonBoundary(UUID.randomUUID(), UUID.randomUUID(), missingProvenance));
        assertEquals("MISSING_PROVENANCE", ex.getCode());
    }
}
