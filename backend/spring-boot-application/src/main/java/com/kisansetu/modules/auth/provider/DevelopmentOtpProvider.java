package com.kisansetu.modules.auth.provider;

import com.kisansetu.common.exception.BadRequestException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.stereotype.Component;

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
    private final boolean exposeInDevelopment;
    private final SecureRandom random = new SecureRandom();
    private final Map<String, OtpEntry> otpCache = new ConcurrentHashMap<>();
    private final Map<String, Deque<Instant>> rateLimitWindows = new ConcurrentHashMap<>();

    @org.springframework.beans.factory.annotation.Autowired
    public DevelopmentOtpProvider(
            Environment environment,
            SmsProvider smsProvider,
            @Value("${app.auth.otp.expose-in-development:false}") boolean exposeInDevelopment) {
        this.environment = environment;
        this.smsProvider = smsProvider;
        this.exposeInDevelopment = exposeInDevelopment;
    }

    public DevelopmentOtpProvider(Environment environment, SmsProvider smsProvider) {
        this(environment, smsProvider, true);
    }

    public boolean isDevelopmentMode() {
        return exposeInDevelopment
                && environment.acceptsProfiles(Profiles.of("dev", "local"))
                && !environment.acceptsProfiles(Profiles.of("prod", "production"));
    }

    public GeneratedOtpChallenge generateOtp(String identifier) {
        Instant now = Instant.now();

        OtpEntry existing = otpCache.get(identifier);
        if (existing != null && now.isBefore(existing.lastSentAt.plusSeconds(RESEND_COOLDOWN_SECONDS))) {
            long waitSeconds = Duration.between(now, existing.lastSentAt.plusSeconds(RESEND_COOLDOWN_SECONDS))
                    .getSeconds() + 1;
            throw new BadRequestException("Please wait " + waitSeconds + " seconds before requesting a new OTP.");
        }

        Deque<Instant> timestamps = rateLimitWindows.computeIfAbsent(identifier, k -> new ArrayDeque<>());
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

        String otp = String.format("%06d", random.nextInt(1000000));
        String otpHash = sha256(identifier + ":" + otp);
        otpCache.put(identifier, new OtpEntry(otpHash, now, now.plusSeconds(OTP_EXPIRY_SECONDS)));

        boolean devExpose = isDevelopmentMode();
        if (!devExpose && (identifier.matches("^[6-9]\\d{9}$") || identifier.startsWith("+"))) {
            smsProvider.sendOtpSms(identifier,
                    "Your Kisan Setu verification code is " + otp + ". Valid for 5 minutes.");
        }
        log.info("Dynamic OTP challenge generated for identifier ending in {}",
                identifier.length() >= 4 ? identifier.substring(identifier.length() - 4) : "****");

        return new GeneratedOtpChallenge(
                identifier,
                "OTP dispatched successfully.",
                devExpose ? otp : null,
                OTP_EXPIRY_SECONDS,
                RESEND_COOLDOWN_SECONDS);
    }

    public SmsProvider getSmsProvider() {
        return smsProvider;
    }

    public void verifyOtp(String identifier, String enteredOtp) {
        OtpEntry entry = otpCache.get(identifier);
        if (entry == null) {
            throw new BadRequestException("No active OTP found. Please request a new OTP.");
        }

        if (entry.isExpired()) {
            otpCache.remove(identifier);
            throw new BadRequestException("OTP has expired. Please request a new OTP.");
        }

        if (entry.attempts >= MAX_ATTEMPTS) {
            otpCache.remove(identifier);
            throw new BadRequestException("Maximum OTP verification attempts exceeded. Please request a new OTP.");
        }

        String enteredHash = sha256(identifier + ":" + enteredOtp);
        if (!MessageDigest.isEqual(entry.otpHash.getBytes(StandardCharsets.UTF_8),
                enteredHash.getBytes(StandardCharsets.UTF_8))) {
            entry.attempts++;
            int remaining = MAX_ATTEMPTS - entry.attempts;
            if (remaining <= 0) {
                otpCache.remove(identifier);
                throw new BadRequestException("Maximum OTP verification attempts exceeded. Please request a new OTP.");
            }
            throw new BadRequestException("Invalid OTP entered. " + remaining + " attempt(s) remaining.");
        }

        otpCache.remove(identifier);
    }

    private String sha256(String value) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(md.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }

    public record GeneratedOtpChallenge(
            String phone,
            String message,
            String developmentOtp,
            int expiresInSeconds,
            int resendCooldownSeconds) {
    }

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

        boolean isExpired() {
            return Instant.now().isAfter(expiresAt);
        }
    }
}
