package com.kisansetu.common.location;

import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class MockLocationService implements LocationService {

    private static final double EARTH_RADIUS_KM = 6371.0;

    @Override
    public double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return Math.round(EARTH_RADIUS_KM * c * 100.0) / 100.0;
    }

    @Override
    public Map<String, Object> geocodePincode(String pincode) {
        if ("411005".equals(pincode)) {
            return Map.of("pincode", "411005", "area", "Shivajinagar, Pune", "latitude", 18.5314, "longitude", 73.8446);
        } else if ("411035".equals(pincode)) {
            return Map.of("pincode", "411035", "area", "Akurdi, Pune", "latitude", 18.6496, "longitude", 73.7707);
        }
        return Map.of("pincode", pincode, "area", "General Region", "latitude", 18.5204, "longitude", 73.8567);
    }
}
