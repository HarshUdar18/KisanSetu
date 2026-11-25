package com.kisansetu.modules.auth.provider;

import com.kisansetu.common.exception.BadRequestException;
import com.kisansetu.common.security.JwtService;
import com.kisansetu.modules.audit.AuditService;
import com.kisansetu.modules.auth.dto.AuthResult;
import com.kisansetu.modules.auth.dto.OtpChallenge;
import com.kisansetu.modules.auth.dto.RegisterUserRequest;
import com.kisansetu.modules.auth.entity.RefreshToken;
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

import java.security.SecureRandom;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
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
    private final long jwtExpirationMs;

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
            @Value("${kisansetu.jwt.expiration-ms:86400000}") long jwtExpirationMs) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.customerProfileRepository = customerProfileRepository;
        this.farmerProfileRepository = farmerProfileRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.auditService = auditService;
        this.otpProvider = otpProvider;
        this.refreshTokenRepository = refreshTokenRepository;
        this.jwtExpirationMs = jwtExpirationMs;
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

        return new AuthResult(token, savedUser.getId(), savedUser.getPhone(), roles, jwtExpirationMs);
    }

    @Override
    @Transactional(readOnly = true)
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

        return new AuthResult(token, user.getId(), principalUsername, roles, jwtExpirationMs);
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
    public AuthResult verifyOtp(String phone, String otp) {
        otpProvider.verifyOtp(phone, otp);

        // Find or auto-provision basic user on verified phone
        User user = userRepository.findByPhone(phone).orElseGet(() -> {
            Role customerRole = roleRepository.findById("ROLE_CUSTOMER")
                    .orElseGet(() -> roleRepository.save(new Role("ROLE_CUSTOMER", "Retail Consumer")));
            User newUser = new User(phone, null, passwordEncoder.encode("devSecretPassword123"));
            newUser.addRole(customerRole);
            User saved = userRepository.save(newUser);

            CustomerProfile profile = new CustomerProfile(saved, "New Customer (" + phone + ")", "", "");
            customerProfileRepository.save(profile);
            return saved;
        });

        List<String> roles = user.getRoles().stream().map(Role::getId).collect(Collectors.toList());
        String token = jwtService.generateToken(user.getId(), user.getPhone(), roles);

        auditService.logEvent(user.getId(), "OTP_VERIFIED", "USER", user.getId().toString(), "OTP verified login", null);

        String refresh = issueRefreshToken(user);
        return new AuthResult(token, refresh, user.getId(), user.getPhone(), roles, jwtExpirationMs);
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
}
