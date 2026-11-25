package com.kisansetu.common.location;

import java.util.Map;

public interface LocationService {
    double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2);
    Map<String, Object> geocodePincode(String pincode);
}
