package com.kisansetu.modules.location.provider;

import com.kisansetu.modules.location.dto.LocationDtos.GeocodeResult;
import java.util.List;

public interface GeocodingProvider {
    String getProviderName();
    List<GeocodeResult> forwardGeocode(String query);
}
