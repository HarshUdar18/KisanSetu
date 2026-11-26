package com.kisansetu.modules.location.provider;

import com.kisansetu.modules.location.dto.LocationDtos.GeocodeResult;

public interface ReverseGeocodingProvider {
    String getProviderName();
    GeocodeResult reverseGeocode(double latitude, double longitude);
}
