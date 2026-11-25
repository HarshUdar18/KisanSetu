package com.kisansetu.modules.auth.provider;

import com.kisansetu.common.exception.BadRequestException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.stereotype.Component;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class DevelopmentOtpProvider {

    private static final Logger log = LoggerFactory.getLogger(DevelopmentOtpProvider.class);

    public static final int OTP_EXPIRY_SECONDS = 300;
    public static final int RESEND_COOLDOWN_SECONDS = 30;
    public static final int MAX_ATTEMPTS = 5;
    public static final int RATE_LIMIT_WINDOW_SECONDS = 900; // 15 minutes
    public static final int MAX_REQUESTS_PER_WINDOW = 5;

    private final Environment environment;
    private final SmsProvider smsProvider;
    private final SecureRandom random = new SecureRandom();
    private final Map<String, OtpEntry> otpCache = new ConcurrentHashMap<>();
    private final Map<String, Deque<Instant>> rateLimitWindows = new ConcurrentHashMap<>();

    public DevelopmentOtpProvider(Environment environment, SmsProvider smsProvider) {
        this.environment = environment;
        this.smsProvider = smsProvider;
    }

    public boolean isDevelopmentMode() {
        return environment.acceptsProfiles(Profiles.of("dev", "local"))
                && !environment.acceptsProfiles(Profiles.of("prod", "production"));
    }

    public GeneratedOtpChallenge generateOtp(String phone) {
        Instant now = Instant.now();

        // Enforce resend cooldown
        OtpEntry existing = otpCache.get(phone);
        if (existing != null && now.isBefore(existing.lastSentAt.plusSeconds(RESEND_COOLDOWN_SECONDS))) {
            long waitSeconds = Duration.between(now, existing.lastSentAt.plusSeconds(RESEND_COOLDOWN_SECONDS))
                    .getSeconds() + 1;
            throw new BadRequestException("Please wait " + waitSeconds + " seconds before requesting a new OTP.");
        }

        // Enforce rate limiting (max 5 requests per 15-minute window)
        Deque<Instant> timestamps = rateLimitWindows.computeIfAbsent(phone, k -> new ArrayDeque<>());
        synchronized (timestamps) {
            Instant windowStart = now.minusSeconds(RATE_LIMIT_WINDOW_SECONDS);
            while (!timestamps.isEmpty() && timestamps.peekFirst().isBefore(windowStart)) {
                timestamps.pollFirst();
            }
            if (timestamps.size() >= MAX_REQUESTS_PER_WINDOW) {
                throw new BadRequestException("Too many OTP requests. Please try again later.");
            }
            timestamps.addLast(now);
        }

        // Always generate a fresh dynamic 6-digit OTP; overwrites & invalidates any
        // previous OTP
        String otp = String.format("%06d", random.nextInt(1000000));
        otpCache.put(phone, new OtpEntry(otp, now, now.plusSeconds(OTP_EXPIRY_SECONDS)));

        boolean devMode = isDevelopmentMode();
        if (!devMode) {
            smsProvider.sendOtpSms(phone, "Your Kisan Setu verification code is " + otp + ". Valid for 5 minutes.");
        }
        log.info("Dynamic OTP challenge generated for phone ending in {}",
                phone.length() >= 4 ? phone.substring(phone.length() - 4) : "****");

        return new GeneratedOtpChallenge(
                phone,
                "OTP dispatched successfully.",
                devMode ? otp : null,
                OTP_EXPIRY_SECONDS,
                RESEND_COOLDOWN_SECONDS);
    }

    public void verifyOtp(String phone, String enteredOtp) {
        OtpEntry entry = otpCache.get(phone);
        if (entry == null) {
            throw new BadRequestException("No active OTP found. Please request a new OTP.");
        }

        if (entry.isExpired()) {
            otpCache.remove(phone);
            throw new BadRequestException("OTP has expired. Please request a new OTP.");
        }

        if (entry.attempts >= MAX_ATTEMPTS) {
            otpCache.remove(phone);
            throw new BadRequestException("Maximum OTP verification attempts exceeded. Please request a new OTP.");
        }

        if (!entry.otp.equals(enteredOtp)) {
            entry.attempts++;
            int remaining = MAX_ATTEMPTS - entry.attempts;
            if (remaining <= 0) {
                otpCache.remove(phone);
                throw new BadRequestException("Maximum OTP verification attempts exceeded. Please request a new OTP.");
            }
            throw new BadRequestException("Invalid OTP entered. " + remaining + " attempt(s) remaining.");
        }

        otpCache.remove(phone);
    }

    public record GeneratedOtpChallenge(
            String phone,
            String message,
            String developmentOtp,
            int expiresInSeconds,
            int resendCooldownSeconds) {
    }

    private static class OtpEntry {
        final String otp;
        final Instant lastSentAt;
        final Instant expiresAt;
        int attempts = 0;

        OtpEntry(String otp, Instant lastSentAt, Instant expiresAt) {
            this.otp = otp;
            this.lastSentAt = lastSentAt;
            this.expiresAt = expiresAt;
        }

        boolean isExpired() {
            return Instant.now().isAfter(expiresAt);
        }
    }
}
