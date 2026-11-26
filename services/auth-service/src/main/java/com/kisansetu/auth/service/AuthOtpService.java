package com.kisansetu.auth.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.HexFormat;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AuthOtpService {

    public static final int OTP_EXPIRY_SECONDS = 300;
    public static final int RESEND_COOLDOWN_SECONDS = 30;
    public static final int MAX_ATTEMPTS = 5;
    public static final int RATE_LIMIT_WINDOW_SECONDS = 900;
    public static final int MAX_REQUESTS_PER_WINDOW = 5;

    private final Environment environment;
    private final boolean exposeInDevelopment;
    private final SecureRandom random = new SecureRandom();
    private final Map<String, OtpEntry> otpCache = new ConcurrentHashMap<>();
    private final Map<String, Deque<Instant>> rateLimits = new ConcurrentHashMap<>();

    @Autowired
    public AuthOtpService(
            Environment environment,
            @Value("${app.auth.otp.expose-in-development:false}") boolean exposeInDevelopment) {
        this.environment = environment;
        this.exposeInDevelopment = exposeInDevelopment;
    }

    public AuthOtpService(Environment environment) {
        this(environment, false);
    }

    public boolean isDevelopmentMode() {
        return exposeInDevelopment
                && environment.acceptsProfiles(Profiles.of("dev", "local"))
                && !environment.acceptsProfiles(Profiles.of("prod", "production"));
    }

    public OtpResult generateOtp(String phone) {
        Instant now = Instant.now();
        OtpEntry existing = otpCache.get(phone);
        if (existing != null && now.isBefore(existing.lastSentAt.plusSeconds(RESEND_COOLDOWN_SECONDS))) {
            long wait = Duration.between(now, existing.lastSentAt.plusSeconds(RESEND_COOLDOWN_SECONDS)).getSeconds() + 1;
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS,
                    "Please wait " + wait + " seconds before requesting a new OTP.");
        }

        Deque<Instant> timestamps = rateLimits.computeIfAbsent(phone, k -> new ArrayDeque<>());
        synchronized (timestamps) {
            Instant cutoff = now.minusSeconds(RATE_LIMIT_WINDOW_SECONDS);
            while (!timestamps.isEmpty() && timestamps.peekFirst().isBefore(cutoff)) {
                timestamps.pollFirst();
            }
            if (timestamps.size() >= MAX_REQUESTS_PER_WINDOW) {
                throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Too many OTP requests.");
            }
            timestamps.addLast(now);
        }

        String otp = String.format("%06d", random.nextInt(1000000));
        String otpHash = sha256(phone + ":" + otp);
        otpCache.put(phone, new OtpEntry(otpHash, now, now.plusSeconds(OTP_EXPIRY_SECONDS)));
        return new OtpResult(phone, isDevelopmentMode() ? otp : null, OTP_EXPIRY_SECONDS, RESEND_COOLDOWN_SECONDS);
    }

    public void verifyOtp(String phone, String enteredOtp) {
        OtpEntry entry = otpCache.get(phone);
        if (entry == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No active OTP found.");
        }
        if (Instant.now().isAfter(entry.expiresAt)) {
            otpCache.remove(phone);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "OTP has expired.");
        }
        if (entry.attempts >= MAX_ATTEMPTS) {
            otpCache.remove(phone);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Maximum verification attempts exceeded.");
        }
        String enteredHash = sha256(phone + ":" + enteredOtp);
        if (!MessageDigest.isEqual(entry.otpHash.getBytes(StandardCharsets.UTF_8),
                enteredHash.getBytes(StandardCharsets.UTF_8))) {
            entry.attempts++;
            int remaining = MAX_ATTEMPTS - entry.attempts;
            if (remaining <= 0) {
                otpCache.remove(phone);
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Maximum verification attempts exceeded.");
            }
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid OTP. " + remaining + " attempt(s) remaining.");
        }
        otpCache.remove(phone);
    }

    private String sha256(String value) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(md.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }

    public record OtpResult(String phone, String developmentOtp, int expiresInSeconds, int resendCooldownSeconds) {}

    private static class OtpEntry {
        final String otpHash;
        final Instant lastSentAt;
        final Instant expiresAt;
        int attempts = 0;

        OtpEntry(String otpHash, Instant lastSentAt, Instant expiresAt) {
            this.otpHash = otpHash;
            this.lastSentAt = lastSentAt;
            this.expiresAt = expiresAt;
        }
    }
}
