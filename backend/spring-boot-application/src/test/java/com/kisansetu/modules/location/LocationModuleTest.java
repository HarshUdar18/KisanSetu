package com.kisansetu.modules.location;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.location.spatial.SpatialLocationService;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mock;

class LocationModuleTest {

    private final SpatialLocationService spatialService = new SpatialLocationService(mock(JdbcTemplate.class));

    @Test
    void validateCoordinates_acceptsValidIndiaCoordinates() {
        assertDoesNotThrow(() -> spatialService.validateCoordinates(18.5204, 73.8567));
        assertDoesNotThrow(() -> spatialService.validateCoordinates(-90.0, 180.0));
    }

    @Test
    void validateCoordinates_rejectsOutOfRangeValues() {
        assertThrows(ApiException.class, () -> spatialService.validateCoordinates(91.0, 73.85));
        assertThrows(ApiException.class, () -> spatialService.validateCoordinates(18.52, -181.0));
        assertThrows(ApiException.class, () -> spatialService.validateCoordinates(Double.NaN, 73.85));
    }

    @Test
    void haversineMeters_calculatesPuneToNashikApproxDistance() {
        double meters = SpatialLocationService.haversineMeters(18.5204, 73.8567, 19.9975, 73.7898);
        assertTrue(meters > 150_000 && meters < 180_000, "Expected ~164km, got " + meters);
    }
}
