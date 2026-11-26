package com.kisansetu.modules.location.provider;

import com.kisansetu.modules.location.dto.LocationDtos.RouteResult;

public interface RoutingProvider {
    String getProviderName();
    RouteResult calculateRoute(double originLat, double originLon, double destLat, double destLon, String travelMode);
}
