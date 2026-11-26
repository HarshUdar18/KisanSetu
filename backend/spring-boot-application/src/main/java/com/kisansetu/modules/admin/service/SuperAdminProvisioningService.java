package com.kisansetu.modules.admin.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.admin.dto.UserSummaryDto;
import com.kisansetu.modules.audit.AuditService;
import com.kisansetu.modules.user.entity.Role;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.RoleRepository;
import com.kisansetu.modules.user.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

@Service
public class SuperAdminProvisioningService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuditService auditService;
    private final String configuredBootstrapSecret;

    public SuperAdminProvisioningService(
            UserRepository userRepository,
            RoleRepository roleRepository,
            PasswordEncoder passwordEncoder,
            AuditService auditService,
            @Value("${SUPER_ADMIN_BOOTSTRAP_SECRET:}") String configuredBootstrapSecret) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.auditService = auditService;
        this.configuredBootstrapSecret = configuredBootstrapSecret;
    }

    @Transactional
    public UserSummaryDto provisionSuperAdmin(String bootstrapSecret, String phone, String password, String email) {
        if (!StringUtils.hasText(configuredBootstrapSecret)) {
            throw new ApiException("BOOTSTRAP_DISABLED",
                    "Super Admin bootstrap is disabled until SUPER_ADMIN_BOOTSTRAP_SECRET is configured.",
                    HttpStatus.FORBIDDEN);
        }
        if (!StringUtils.hasText(bootstrapSecret) || !MessageDigest.isEqual(
                configuredBootstrapSecret.getBytes(StandardCharsets.UTF_8),
                bootstrapSecret.getBytes(StandardCharsets.UTF_8))) {
            throw new ApiException("INVALID_BOOTSTRAP_SECRET", "Invalid bootstrap secret", HttpStatus.FORBIDDEN);
        }

        boolean alreadyExists = userRepository.findAll().stream()
                .anyMatch(u -> u.hasRole("ROLE_SUPER_ADMIN"));
        if (alreadyExists) {
            throw new ApiException("SUPER_ADMIN_ALREADY_PROVISIONED",
                    "A Super Admin account has already been provisioned.", HttpStatus.CONFLICT);
        }

        if (userRepository.existsByPhone(phone.trim())) {
            throw new ApiException("DUPLICATE_PHONE", "Phone number already exists", HttpStatus.CONFLICT);
        }
        if (StringUtils.hasText(email) && userRepository.existsByEmail(email.trim().toLowerCase())) {
            throw new ApiException("DUPLICATE_EMAIL", "Email already exists", HttpStatus.CONFLICT);
        }

        Role superAdminRole = roleRepository.findById("ROLE_SUPER_ADMIN")
                .orElseGet(() -> roleRepository.save(new Role("ROLE_SUPER_ADMIN", "Platform Super Administrator")));

        User user = new User(
                phone.trim(),
                StringUtils.hasText(email) ? email.trim().toLowerCase() : null,
                passwordEncoder.encode(password)
        );
        user.addRole(superAdminRole);
        User saved = userRepository.save(user);

        auditService.logEvent(saved.getId(), "SUPER_ADMIN_PROVISIONED", "USER", saved.getId().toString(),
                "Initial Super Admin provisioned securely via bootstrap", null);

        return UserSummaryDto.fromEntity(saved);
    }
}
