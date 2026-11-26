package com.kisansetu.auth.controller;

import com.kisansetu.auth.entity.AuthRefreshToken;
import com.kisansetu.auth.entity.AuthRole;
import com.kisansetu.auth.entity.AuthUser;
import com.kisansetu.auth.repository.AuthRefreshTokenRepository;
import com.kisansetu.auth.repository.AuthRoleRepository;
import com.kisansetu.auth.repository.AuthUserRepository;
import com.kisansetu.auth.service.AuthJwtService;
import com.kisansetu.auth.service.AuthOtpService;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.*;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthUserRepository userRepo;
    private final AuthRoleRepository roleRepo;
    private final AuthRefreshTokenRepository refreshRepo;
    private final PasswordEncoder passwordEncoder;
    private final AuthJwtService jwtService;
    private final AuthOtpService otpService;
    private final Optional<RabbitTemplate> rabbitTemplate;

    public AuthController(AuthUserRepository userRepo,
                          AuthRoleRepository roleRepo,
                          AuthRefreshTokenRepository refreshRepo,
                          PasswordEncoder passwordEncoder,
                          AuthJwtService jwtService,
                          AuthOtpService otpService,
                          Optional<RabbitTemplate> rabbitTemplate) {
        this.userRepo = userRepo;
        this.roleRepo = roleRepo;
        this.refreshRepo = refreshRepo;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.otpService = otpService;
        this.rabbitTemplate = rabbitTemplate;
    }

    @PostMapping("/register")
    @Transactional
    public ResponseEntity<Map<String, Object>> register(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String email = body.get("email");
        String password = body.get("password");
        String roleInput = body.getOrDefault("role", "CUSTOMER").toUpperCase();
        String roleId = roleInput.startsWith("ROLE_") ? roleInput : "ROLE_" + roleInput;

        if (!StringUtils.hasText(phone) || !StringUtils.hasText(password)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Phone and password are required");
        }
        if (userRepo.existsByPhone(phone)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Phone already registered");
        }

        AuthRole role = roleRepo.findById(roleId)
                .orElseGet(() -> roleRepo.save(new AuthRole(roleId, roleId)));
        AuthUser user = new AuthUser();
        user.setPhone(phone);
        user.setEmail(StringUtils.hasText(email) ? email.trim().toLowerCase() : null);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.getRoles().add(role);
        AuthUser saved = userRepo.save(user);

        rabbitTemplate.ifPresent(rt -> {
            try {
                rt.convertAndSend("kisansetu.events", "user.registered", Map.of(
                        "eventType", "USER_REGISTERED",
                        "userId", saved.getId().toString(),
                        "phone", saved.getPhone(),
                        "role", roleId
                ));
            } catch (Exception ignored) {}
        });

        return ResponseEntity.status(HttpStatus.CREATED).body(wrap("Registration successful", issueTokens(saved)));
    }

    @PostMapping("/login")
    @Transactional
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        String identifier = body.getOrDefault("identifier", body.getOrDefault("phoneNumber", "")).trim();
        String password = body.getOrDefault("password", "");
        AuthUser user = userRepo.findByPhoneOrEmail(identifier, identifier.toLowerCase())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }
        return ResponseEntity.ok(wrap("Login successful", issueTokens(user)));
    }

    @PostMapping({"/send-otp", "/request-otp"})
    public ResponseEntity<Map<String, Object>> sendOtp(@RequestBody Map<String, String> body) {
        String phone = body.getOrDefault("phone", body.getOrDefault("phoneNumber", "")).trim();
        var res = otpService.generateOtp(phone);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("phone", res.phone());
        data.put("message", "OTP dispatched successfully.");
        if (res.developmentOtp() != null) {
            data.put("developmentOtp", res.developmentOtp());
        }
        data.put("expiresInSeconds", res.expiresInSeconds());
        data.put("resendCooldownSeconds", res.resendCooldownSeconds());
        return ResponseEntity.ok(wrap("OTP dispatched", data));
    }

    @PostMapping("/verify-otp")
    @Transactional
    public ResponseEntity<Map<String, Object>> verifyOtp(@RequestBody Map<String, String> body) {
        String phone = body.getOrDefault("phone", body.getOrDefault("phoneNumber", "")).trim();
        String otp = body.getOrDefault("otp", "").trim();
        otpService.verifyOtp(phone, otp);

        AuthUser user = userRepo.findByPhone(phone).orElseGet(() -> {
            AuthRole role = roleRepo.findById("ROLE_CUSTOMER")
                    .orElseGet(() -> roleRepo.save(new AuthRole("ROLE_CUSTOMER", "Customer")));
            AuthUser u = new AuthUser();
            u.setPhone(phone);
            u.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));
            u.getRoles().add(role);
            return userRepo.save(u);
        });
        return ResponseEntity.ok(wrap("OTP verification successful", issueTokens(user)));
    }

    @PostMapping("/refresh")
    @Transactional
    public ResponseEntity<Map<String, Object>> refresh(@RequestBody Map<String, String> body) {
        String token = body.get("refreshToken");
        AuthRefreshToken stored = refreshRepo.findByToken(token)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token"));
        if (Boolean.TRUE.equals(stored.getRevoked()) || stored.isExpired()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token expired or revoked");
        }
        stored.setRevoked(true);
        refreshRepo.save(stored);
        return ResponseEntity.ok(wrap("Token refreshed", issueTokens(stored.getUser())));
    }

    @PostMapping("/logout")
    @Transactional
    public ResponseEntity<Map<String, Object>> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        if (StringUtils.hasText(authHeader) && authHeader.startsWith("Bearer ")) {
            try {
                var claims = jwtService.parseClaims(authHeader.substring(7));
                UUID userId = UUID.fromString(claims.get("userId", String.class));
                refreshRepo.findByUserIdAndRevokedFalse(userId).ifPresent(rt -> {
                    rt.setRevoked(true);
                    refreshRepo.save(rt);
                });
            } catch (Exception ignored) {}
        }
        return ResponseEntity.ok(wrap("Logged out successfully", null));
    }

    private Map<String, Object> issueTokens(AuthUser user) {
        List<String> roles = user.getRoles().stream().map(AuthRole::getId).toList();
        String access = jwtService.generateToken(user.getId(), user.getPhone(), roles);
        refreshRepo.findByUserIdAndRevokedFalse(user.getId()).ifPresent(rt -> {
            rt.setRevoked(true);
            refreshRepo.save(rt);
        });
        String refresh = UUID.randomUUID() + "." + UUID.randomUUID();
        refreshRepo.save(new AuthRefreshToken(user, refresh, Instant.now().plusSeconds(30L * 24 * 3600)));

        Map<String, Object> res = new LinkedHashMap<>();
        res.put("token", access);
        res.put("refreshToken", refresh);
        res.put("type", "Bearer");
        res.put("userId", user.getId());
        res.put("identifier", user.getPhone());
        res.put("roles", roles);
        res.put("expiresInMs", jwtService.getExpirationMs());
        return res;
    }

    private Map<String, Object> wrap(String message, Object data) {
        Map<String, Object> env = new LinkedHashMap<>();
        env.put("success", true);
        env.put("message", message);
        env.put("data", data);
        return env;
    }
}
