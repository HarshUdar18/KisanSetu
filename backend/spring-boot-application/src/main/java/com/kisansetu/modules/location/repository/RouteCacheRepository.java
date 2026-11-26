package com.kisansetu.modules.location.repository;

import com.kisansetu.modules.location.entity.RouteCache;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RouteCacheRepository extends JpaRepository<RouteCache, UUID> {
    Optional<RouteCache> findByProviderAndTravelModeAndOriginHashAndDestinationHash(
            String provider, String travelMode, String originHash, String destinationHash);
}
