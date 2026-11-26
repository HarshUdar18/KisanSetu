package com.kisansetu.modules.location.cache;

import com.kisansetu.common.exception.ApiException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Shared rate limiter for external mapping providers (e.g. Nominatim 1 req/sec policy).
 * Uses Redis SETNX when available across replicas, with a local lock fallback for single-instance/test runs.
 */
@Component
public class DistributedLocationRateLimiter {

    private static final Logger log = LoggerFactory.getLogger(DistributedLocationRateLimiter.class);
    private final StringRedisTemplate redisTemplate;
    private final ReentrantLock localLock = new ReentrantLock();
    private long lastLocalRequestAtMs = 0L;

    public DistributedLocationRateLimiter(ObjectProvider<StringRedisTemplate> redisTemplateProvider) {
        this.redisTemplate = redisTemplateProvider.getIfAvailable();
    }

    public void acquireSlot(String providerKey, long minimumIntervalMs) {
        if (minimumIntervalMs <= 0) return;

        if (redisTemplate != null) {
            try {
                String key = "kisansetu:ratelimit:location:" + providerKey;
                for (int attempt = 0; attempt < 3; attempt++) {
                    Boolean acquired = redisTemplate.opsForValue()
                            .setIfAbsent(key, "1", Duration.ofMillis(minimumIntervalMs));
                    if (Boolean.TRUE.equals(acquired)) {
                        return;
                    }
                    Thread.sleep(Math.min(minimumIntervalMs, 1200));
                }
                throw new ApiException("RATE_LIMITED",
                        "Location provider rate limit active; please retry shortly.",
                        HttpStatus.TOO_MANY_REQUESTS);
            } catch (ApiException ex) {
                throw ex;
            } catch (Exception e) {
                log.debug("Redis rate limiter unavailable ({}); falling back to local lock", e.getMessage());
            }
        }

        localLock.lock();
        try {
            long now = System.currentTimeMillis();
            long elapsed = now - lastLocalRequestAtMs;
            if (elapsed < minimumIntervalMs) {
                Thread.sleep(minimumIntervalMs - elapsed);
            }
            lastLocalRequestAtMs = System.currentTimeMillis();
        } catch (InterruptedException ie) {
            Thread.currentThread().interrupt();
            throw new ApiException("RATE_LIMITED", "Interrupted while waiting for provider slot", HttpStatus.TOO_MANY_REQUESTS);
        } finally {
            localLock.unlock();
        }
    }
}
