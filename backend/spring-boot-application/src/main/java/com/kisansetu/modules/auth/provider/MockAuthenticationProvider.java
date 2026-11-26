package com.kisansetu.modules.auth.provider;

import com.kisansetu.common.exception.BadRequestException;
import com.kisansetu.common.security.JwtService;
import com.kisansetu.modules.audit.AuditService;
import com.kisansetu.modules.auth.dto.AuthResult;
import com.kisansetu.modules.auth.dto.OtpChallenge;
import com.kisansetu.modules.auth.dto.RegisterUserRequest;
import com.kisansetu.modules.auth.entity.PasswordResetToken;
import com.kisansetu.modules.auth.entity.RefreshToken;
import com.kisansetu.modules.auth.repository.PasswordResetTokenRepository;
import com.kisansetu.modules.auth.repository.RefreshTokenRepository;
import com.kisansetu.modules.customer.entity.CustomerProfile;
import com.kisansetu.modules.customer.repository.CustomerProfileRepository;
import com.kisansetu.modules.farmer.entity.FarmerProfile;
import com.kisansetu.modules.farmer.repository.FarmerProfileRepository;
import com.kisansetu.modules.user.entity.Role;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.RoleRepository;
import com.kisansetu.modules.user.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Component
public class MockAuthenticationProvider implements AuthenticationProvider {

    private static final Logger log = LoggerFactory.getLogger(MockAuthenticationProvider.class);

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final CustomerProfileRepository customerProfileRepository;
    private final FarmerProfileRepository farmerProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuditService auditService;
    private final DevelopmentOtpProvider otpProvider;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final SecureRandom resetRandom = new SecureRandom();
    private final long jwtExpirationMs;
    private final String googleClientId;

    public MockAuthenticationProvider(
            UserRepository userRepository,
            RoleRepository roleRepository,
            CustomerProfileRepository customerProfileRepository,
            FarmerProfileRepository farmerProfileRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            AuditService auditService,
            DevelopmentOtpProvider otpProvider,
            RefreshTokenRepository refreshTokenRepository,
            PasswordResetTokenRepository passwordResetTokenRepository,
            @Value("${kisansetu.jwt.expiration-ms:86400000}") long jwtExpirationMs,
            @Value("${app.auth.google.client-id:}") String googleClientId) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.customerProfileRepository = customerProfileRepository;
        this.farmerProfileRepository = farmerProfileRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.auditService = auditService;
        this.otpProvider = otpProvider;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.jwtExpirationMs = jwtExpirationMs;
        this.googleClientId = googleClientId != null ? googleClientId.trim() : "";
    }

    @Override
    @Transactional
    public AuthResult registerUser(RegisterUserRequest request) {
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new BadRequestException("Phone number is already registered: " + request.getPhone());
        }
        if (StringUtils.hasText(request.getEmail()) && userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already registered: " + request.getEmail());
        }

        String rawRole = StringUtils.hasText(request.getRole()) ? request.getRole().toUpperCase() : "ROLE_CUSTOMER";
        final String targetRoleName = rawRole.startsWith("ROLE_") ? rawRole : "ROLE_" + rawRole;

        Role role = roleRepository.findById(targetRoleName)
                .orElseGet(() -> roleRepository.save(new Role(targetRoleName, "Self-registered " + targetRoleName)));

        User user = new User(
                request.getPhone(),
                StringUtils.hasText(request.getEmail()) ? request.getEmail().trim().toLowerCase() : null,
                passwordEncoder.encode(request.getPassword())
        );
        user.addRole(role);
        User savedUser = userRepository.save(user);

        if ("ROLE_FARMER".equals(targetRoleName)) {
            FarmerProfile farmerProfile = new FarmerProfile(
                    savedUser,
                    request.getFullName(),
                    request.getVillage(),
                    request.getDistrict(),
                    request.getState(),
                    request.getPincode(),
                    request.getCropCategory() != null ? request.getCropCategory() : "General Produce"
            );
            farmerProfileRepository.save(farmerProfile);
        } else {
            CustomerProfile customerProfile = new CustomerProfile(
                    savedUser,
                    request.getFullName(),
                    request.getDefaultAddress(),
                    request.getPincode()
            );
            customerProfileRepository.save(customerProfile);
        }

        List<String> roles = savedUser.getRoles().stream().map(Role::getId).collect(Collectors.toList());
        String token = jwtService.generateToken(savedUser.getId(), savedUser.getPhone(), roles);

        auditService.logEvent(savedUser.getId(), "USER_REGISTERED", "USER", savedUser.getId().toString(),
                "Registered with role " + targetRoleName, null);

        String refresh = issueRefreshToken(savedUser);
        return new AuthResult(token, refresh, savedUser.getId(), savedUser.getPhone(), roles, jwtExpirationMs);
    }

    @Override
    @Transactional
    public AuthResult loginWithPassword(String identifier, String password) {
        String trimmed = identifier.trim();
        User user = userRepository.findByPhoneOrEmail(trimmed, trimmed.toLowerCase())
                .orElseThrow(() -> new BadCredentialsException("Invalid phone/email or password"));

        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            auditService.logEvent(user.getId(), "LOGIN_FAILED", "USER", user.getId().toString(), "Password mismatch", null);
            throw new BadCredentialsException("Invalid phone/email or password");
        }

        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new BadRequestException("Account is currently inactive or suspended");
        }

        List<String> roles = user.getRoles().stream().map(Role::getId).collect(Collectors.toList());
        String principalUsername = user.getPhone() != null ? user.getPhone() : user.getEmail();
        String token = jwtService.generateToken(user.getId(), principalUsername, roles);

        auditService.logEvent(user.getId(), "LOGIN_SUCCESS", "USER", user.getId().toString(), "Password login", null);

        String refresh = issueRefreshToken(user);
        return new AuthResult(token, refresh, user.getId(), principalUsername, roles, jwtExpirationMs);
    }

    @Override
    public OtpChallenge sendOtp(String phone) {
        DevelopmentOtpProvider.GeneratedOtpChallenge challenge = otpProvider.generateOtp(phone);
        return new OtpChallenge(
                challenge.phone(),
                challenge.message(),
                challenge.developmentOtp(),
                challenge.expiresInSeconds(),
                challenge.resendCooldownSeconds()
        );
    }

    @Override
    @Transactional
    public AuthResult verifyOtp(String identifier, String otp) {
        return verifyOtp(identifier, otp, null);
    }

    @Override
    @Transactional
    public AuthResult verifyOtp(String identifier, String otp, String requestedRole) {
        String normalized = identifier.trim();
        boolean isEmail = normalized.contains("@");
        String lookup = isEmail ? normalized.toLowerCase() : normalized;
        otpProvider.verifyOtp(lookup, otp);

        String targetRole = (requestedRole != null && requestedRole.trim().equalsIgnoreCase("ROLE_FARMER"))
                ? "ROLE_FARMER" : "ROLE_CUSTOMER";

        User user = userRepository.findByPhoneOrEmail(lookup, lookup.toLowerCase()).orElseGet(() -> {
            Role role = roleRepository.findById(targetRole)
                    .orElseGet(() -> roleRepository.save(new Role(targetRole, "Self-registered " + targetRole)));
            User newUser = new User(
                    isEmail ? null : lookup,
                    isEmail ? lookup : null,
                    passwordEncoder.encode(UUID.randomUUID().toString())
            );
            newUser.addRole(role);
            User saved = userRepository.save(newUser);

            if ("ROLE_FARMER".equals(targetRole)) {
                FarmerProfile fp = new FarmerProfile(saved, "Kisan Setu Farmer", "", "", "Maharashtra", "", "General Produce");
                farmerProfileRepository.save(fp);
            } else {
                CustomerProfile profile = new CustomerProfile(saved, "", "", "");
                customerProfileRepository.save(profile);
            }
            return saved;
        });

        if ("ROLE_CUSTOMER".equals(targetRole) && customerProfileRepository.findByUserId(user.getId()).isEmpty()) {
            customerProfileRepository.save(new CustomerProfile(user, "", "", ""));
        }

        List<String> roles = user.getRoles().stream().map(Role::getId).collect(Collectors.toList());
        if ("ROLE_FARMER".equals(targetRole) && !roles.contains("ROLE_FARMER") && !roles.contains("ROLE_ADMIN")) {
            throw new com.kisansetu.common.exception.ApiException(
                    "ROLE_FORBIDDEN", "This account does not have FARMER role.", org.springframework.http.HttpStatus.FORBIDDEN);
        }
        String principalId = user.getPhone() != null ? user.getPhone() : user.getEmail();
        String token = jwtService.generateToken(user.getId(), principalId, roles);

        auditService.logEvent(user.getId(), "OTP_VERIFIED", "USER", user.getId().toString(), "OTP verified login (" + targetRole + ")", null);

        String refresh = issueRefreshToken(user);
        return new AuthResult(token, refresh, user.getId(), principalId, roles, jwtExpirationMs);
    }

    @Override
    @Transactional
    public AuthResult loginWithGoogle(String idToken) {
        if (!StringUtils.hasText(googleClientId)) {
            throw new com.kisansetu.common.exception.ApiException(
                    "GOOGLE_AUTH_BLOCKED",
                    "Google Sign-In is not configured on this server (missing GOOGLE_OAUTH_CLIENT_ID).",
                    org.springframework.http.HttpStatus.SERVICE_UNAVAILABLE
            );
        }
        if (!StringUtils.hasText(idToken)) {
            throw new BadRequestException("Google ID token is required");
        }
        try {
            var factory = new org.springframework.http.client.SimpleClientHttpRequestFactory();
            factory.setConnectTimeout(5000);
            factory.setReadTimeout(8000);
            var rest = new org.springframework.web.client.RestTemplate(factory);
            @SuppressWarnings("unchecked")
            Map<String, Object> tokenInfo = rest.getForObject(
                    "https://oauth2.googleapis.com/tokeninfo?id_token={token}",
                    Map.class,
                    idToken.trim()
            );
            if (tokenInfo == null) {
                throw new BadCredentialsException("Empty Google tokeninfo response");
            }
            String aud = String.valueOf(tokenInfo.getOrDefault("aud", ""));
            String iss = String.valueOf(tokenInfo.getOrDefault("iss", ""));
            String email = String.valueOf(tokenInfo.getOrDefault("email", "")).trim().toLowerCase();
            boolean emailVerified = "true".equalsIgnoreCase(String.valueOf(tokenInfo.getOrDefault("email_verified", "false")));
            long exp = Long.parseLong(String.valueOf(tokenInfo.getOrDefault("exp", "0")));

            if (!googleClientId.equals(aud)
                    || (!"accounts.google.com".equals(iss) && !"https://accounts.google.com".equals(iss))
                    || !emailVerified
                    || email.isEmpty()
                    || Instant.now().getEpochSecond() >= exp) {
                throw new BadCredentialsException("Invalid or expired Google ID token");
            }

            String name = String.valueOf(tokenInfo.getOrDefault("name", "Kisan Setu Customer"));
            User user = userRepository.findByEmail(email).orElseGet(() -> {
                Role customerRole = roleRepository.findById("ROLE_CUSTOMER")
                        .orElseGet(() -> roleRepository.save(new Role("ROLE_CUSTOMER", "Retail Consumer")));
                User newUser = new User(null, email, passwordEncoder.encode(UUID.randomUUID().toString()));
                newUser.addRole(customerRole);
                User saved = userRepository.save(newUser);
                customerProfileRepository.save(new CustomerProfile(saved, name, "", ""));
                return saved;
            });

            List<String> roles = user.getRoles().stream().map(Role::getId).collect(Collectors.toList());
            String principalId = user.getPhone() != null ? user.getPhone() : user.getEmail();
            String token = jwtService.generateToken(user.getId(), principalId, roles);
            auditService.logEvent(user.getId(), "GOOGLE_LOGIN", "USER", user.getId().toString(), "Google ID token verified", null);
            String refresh = issueRefreshToken(user);
            return new AuthResult(token, refresh, user.getId(), principalId, roles, jwtExpirationMs);
        } catch (com.kisansetu.common.exception.ApiException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new BadCredentialsException("Google Sign-In verification failed: " + ex.getMessage());
        }
    }

    @Override
    public Map<String, Object> getCapabilities() {
        boolean smsConfigured = otpProvider.getSmsProvider() != null && otpProvider.getSmsProvider().isConfigured();
        boolean devMode = otpProvider.isDevelopmentMode();
        return Map.of(
                "phoneOtp", true,
                "emailOtp", true,
                "passwordLogin", true,
                "googleSignIn", StringUtils.hasText(googleClientId),
                "exposeDevOtp", devMode,
                "smsConfigured", smsConfigured,
                "otpDeliveryMode", devMode ? "DEVELOPMENT_IN_APP" : (smsConfigured ? "SMS" : "BLOCKED")
        );
    }

    private String issueRefreshToken(User user) {
        refreshTokenRepository.findByUserIdAndRevokedFalse(user.getId()).ifPresent(existing -> {
            existing.setRevoked(true);
            refreshTokenRepository.save(existing);
        });
        String raw = java.util.UUID.randomUUID() + "." + java.util.UUID.randomUUID();
        RefreshToken rt = new RefreshToken(user, raw, Instant.now().plusSeconds(30L * 24 * 3600));
        refreshTokenRepository.save(rt);
        return raw;
    }

    @Override
    @Transactional
    public AuthResult refreshToken(String refreshToken) {
        if (!StringUtils.hasText(refreshToken)) {
            throw new BadRequestException("Refresh token is required");
        }
        RefreshToken stored = refreshTokenRepository.findByToken(refreshToken)
                .orElseThrow(() -> new BadCredentialsException("Invalid refresh token"));
        if (Boolean.TRUE.equals(stored.getRevoked()) || stored.isExpired()) {
            throw new BadCredentialsException("Refresh token is revoked or expired");
        }

        stored.setRevoked(true);
        refreshTokenRepository.save(stored);

        User user = stored.getUser();
        List<String> roles = user.getRoles().stream().map(Role::getId).collect(Collectors.toList());
        String identifier = user.getPhone() != null ? user.getPhone() : user.getEmail();
        String newAccess = jwtService.generateToken(user.getId(), identifier, roles);
        String newRefresh = issueRefreshToken(user);

        return new AuthResult(newAccess, newRefresh, user.getId(), identifier, roles, jwtExpirationMs);
    }

    @Override
    @Transactional
    public void logout(String token) {
        logout(token, null);
    }

    @Override
    @Transactional
    public void logout(String token, String refreshToken) {
        if (StringUtils.hasText(refreshToken)) {
            refreshTokenRepository.findByToken(refreshToken.trim()).ifPresent(rt -> {
                rt.setRevoked(true);
                refreshTokenRepository.save(rt);
                auditService.logEvent(rt.getUser().getId(), "LOGOUT", "USER", rt.getUser().getId().toString(),
                        "User logged out (refresh token revoked)", null);
            });
        }
        if (StringUtils.hasText(token) && jwtService.isTokenValid(token)) {
            try {
                var userId = jwtService.extractUserId(token);
                refreshTokenRepository.findByUserIdAndRevokedFalse(userId).ifPresent(rt -> {
                    rt.setRevoked(true);
                    refreshTokenRepository.save(rt);
                });
                auditService.logEvent(userId, "LOGOUT", "USER", userId.toString(), "User logged out", null);
            } catch (Exception ignored) {}
        }
    }

    @Override
    @Transactional
    public Map<String, Object> forgotPassword(String identifier) {
        String genericMessage = "If an account exists for that identifier, a password reset code has been issued.";
        if (!StringUtils.hasText(identifier)) {
            return Map.of("message", genericMessage, "expiresInSeconds", 900);
        }
        String trimmed = identifier.trim();
        var userOpt = userRepository.findByPhoneOrEmail(trimmed, trimmed.toLowerCase());
        if (userOpt.isEmpty()) {
            return Map.of("message", genericMessage, "expiresInSeconds", 900);
        }

        User user = userOpt.get();
        passwordResetTokenRepository.findByUserIdAndUsedFalse(user.getId()).forEach(t -> {
            t.setUsed(true);
            passwordResetTokenRepository.save(t);
        });

        String rawCode = String.format("%06d", resetRandom.nextInt(1000000));
        String hash = sha256Hex(rawCode);
        passwordResetTokenRepository.save(new PasswordResetToken(user, hash, Instant.now().plusSeconds(900)));
        auditService.logEvent(user.getId(), "PASSWORD_RESET_REQUESTED", "USER", user.getId().toString(),
                "Password reset code generated", null);

        if (otpProvider.isDevelopmentMode()) {
            return Map.of(
                    "message", genericMessage,
                    "expiresInSeconds", 900,
                    "developmentResetCode", rawCode
            );
        }
        return Map.of("message", genericMessage, "expiresInSeconds", 900);
    }

    @Override
    @Transactional
    public void resetPassword(String identifier, String token, String newPassword) {
        if (!StringUtils.hasText(newPassword) || newPassword.length() < 6) {
            throw new BadRequestException("New password must be at least 6 characters long");
        }
        if (!StringUtils.hasText(identifier) || !StringUtils.hasText(token)) {
            throw new BadRequestException("Identifier and reset code are required");
        }
        String trimmed = identifier.trim();
        User user = userRepository.findByPhoneOrEmail(trimmed, trimmed.toLowerCase())
                .orElseThrow(() -> new BadCredentialsException("Invalid or expired reset code"));

        PasswordResetToken resetToken = passwordResetTokenRepository
                .findTopByUserIdAndUsedFalseOrderByCreatedAtDesc(user.getId())
                .orElseThrow(() -> new BadCredentialsException("Invalid or expired reset code"));

        if (resetToken.isExpired() || !MessageDigest.isEqual(
                resetToken.getTokenHash().getBytes(StandardCharsets.UTF_8),
                sha256Hex(token.trim()).getBytes(StandardCharsets.UTF_8))) {
            throw new BadCredentialsException("Invalid or expired reset code");
        }

        resetToken.setUsed(true);
        passwordResetTokenRepository.save(resetToken);

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        refreshTokenRepository.findByUserIdAndRevokedFalse(user.getId()).ifPresent(rt -> {
            rt.setRevoked(true);
            refreshTokenRepository.save(rt);
        });
        auditService.logEvent(user.getId(), "PASSWORD_RESET_SUCCESS", "USER", user.getId().toString(),
                "Password reset completed", null);
    }

    @Override
    @Transactional
    public void changePassword(UUID userId, String currentPassword, String newPassword) {
        if (!StringUtils.hasText(newPassword) || newPassword.length() < 6) {
            throw new BadRequestException("New password must be at least 6 characters long");
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BadCredentialsException("User not found"));
        if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            throw new BadCredentialsException("Current password is incorrect");
        }
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        refreshTokenRepository.findByUserIdAndRevokedFalse(userId).ifPresent(rt -> {
            rt.setRevoked(true);
            refreshTokenRepository.save(rt);
        });
        auditService.logEvent(userId, "PASSWORD_CHANGED", "USER", userId.toString(),
                "Password changed by user", null);
    }

    private String sha256Hex(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(input.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (Exception e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }
}
