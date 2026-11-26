package com.kisansetu.modules.location.repository;

import com.kisansetu.modules.location.entity.GeocodingCache;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface GeocodingCacheRepository extends JpaRepository<GeocodingCache, UUID> {
    Optional<GeocodingCache> findByProviderAndOperationTypeAndQueryHash(
            String provider, String operationType, String queryHash);
}
