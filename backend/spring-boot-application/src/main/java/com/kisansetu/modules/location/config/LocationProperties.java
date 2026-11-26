package com.kisansetu.modules.location.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "kisansetu.location")
public class LocationProperties {

    private MapConfig map = new MapConfig();
    private GeocodingConfig geocoding = new GeocodingConfig();
    private RoutingConfig routing = new RoutingConfig();
    private NearbyConfig nearby = new NearbyConfig();

    public static class MapConfig {
        private String provider = "openstreetmap";
        private String tileUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
        private String attribution = "© OpenStreetMap contributors";

        public String getProvider() { return provider; }
        public void setProvider(String provider) { this.provider = provider; }
        public String getTileUrl() { return tileUrl; }
        public void setTileUrl(String tileUrl) { this.tileUrl = tileUrl; }
        public String getAttribution() { return attribution; }
        public void setAttribution(String attribution) { this.attribution = attribution; }
    }

    public static class GeocodingConfig {
        private String provider = "nominatim";
        private String baseUrl = "https://nominatim.openstreetmap.org";
        private String userAgent = "KisanSetu/1.0 (contact@kisansetu.local)";
        private boolean enabled = true;
        private long minimumIntervalMs = 1100;
        private long cacheTtlHours = 168;

        public String getProvider() { return provider; }
        public void setProvider(String provider) { this.provider = provider; }
        public String getBaseUrl() { return baseUrl; }
        public void setBaseUrl(String baseUrl) { this.baseUrl = baseUrl; }
        public String getUserAgent() { return userAgent; }
        public void setUserAgent(String userAgent) { this.userAgent = userAgent; }
        public boolean isEnabled() { return enabled; }
        public void setEnabled(boolean enabled) { this.enabled = enabled; }
        public long getMinimumIntervalMs() { return minimumIntervalMs; }
        public void setMinimumIntervalMs(long minimumIntervalMs) { this.minimumIntervalMs = minimumIntervalMs; }
        public long getCacheTtlHours() { return cacheTtlHours; }
        public void setCacheTtlHours(long cacheTtlHours) { this.cacheTtlHours = cacheTtlHours; }
    }

    public static class RoutingConfig {
        private String provider = "osrm";
        private String baseUrl = "https://router.project-osrm.org";
        private boolean enabled = true;
        private long cacheTtlHours = 3;

        public String getProvider() { return provider; }
        public void setProvider(String provider) { this.provider = provider; }
        public String getBaseUrl() { return baseUrl; }
        public void setBaseUrl(String baseUrl) { this.baseUrl = baseUrl; }
        public boolean isEnabled() { return enabled; }
        public void setEnabled(boolean enabled) { this.enabled = enabled; }
        public long getCacheTtlHours() { return cacheTtlHours; }
        public void setCacheTtlHours(long cacheTtlHours) { this.cacheTtlHours = cacheTtlHours; }
    }

    public static class NearbyConfig {
        private String databaseProvider = "postgis";

        public String getDatabaseProvider() { return databaseProvider; }
        public void setDatabaseProvider(String databaseProvider) { this.databaseProvider = databaseProvider; }
    }

    public MapConfig getMap() { return map; }
    public void setMap(MapConfig map) { this.map = map; }
    public GeocodingConfig getGeocoding() { return geocoding; }
    public void setGeocoding(GeocodingConfig geocoding) { this.geocoding = geocoding; }
    public RoutingConfig getRouting() { return routing; }
    public void setRouting(RoutingConfig routing) { this.routing = routing; }
    public NearbyConfig getNearby() { return nearby; }
    public void setNearby(NearbyConfig nearby) { this.nearby = nearby; }
}
