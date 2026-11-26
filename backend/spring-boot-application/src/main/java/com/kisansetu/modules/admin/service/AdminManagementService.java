package com.kisansetu.modules.admin.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.admin.dto.CreateAdminRequest;
import com.kisansetu.modules.admin.dto.UserSummaryDto;
import com.kisansetu.modules.audit.AuditService;
import com.kisansetu.modules.audit.entity.AuditLog;
import com.kisansetu.modules.audit.repository.AuditLogRepository;
import com.kisansetu.modules.user.entity.Role;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.RoleRepository;
import com.kisansetu.modules.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class AdminManagementService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuditService auditService;
    private final AuditLogRepository auditLogRepository;

    public AdminManagementService(UserRepository userRepository,
                                  RoleRepository roleRepository,
                                  PasswordEncoder passwordEncoder,
                                  AuditService auditService,
                                  AuditLogRepository auditLogRepository) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.auditService = auditService;
        this.auditLogRepository = auditLogRepository;
    }

    @Transactional
    public UserSummaryDto createAdmin(UUID superAdminId, CreateAdminRequest req) {
        String phone = req.getPhone().trim();
        if (userRepository.existsByPhone(phone)) {
            throw new ApiException("DUPLICATE_PHONE", "Phone number is already registered", HttpStatus.CONFLICT);
        }
        String email = StringUtils.hasText(req.getEmail()) ? req.getEmail().trim().toLowerCase() : null;
        if (email != null && userRepository.existsByEmail(email)) {
            throw new ApiException("DUPLICATE_EMAIL", "Email is already registered", HttpStatus.CONFLICT);
        }

        Role adminRole = roleRepository.findById("ROLE_ADMIN")
                .orElseGet(() -> roleRepository.save(new Role("ROLE_ADMIN", "Platform Administrator")));

        User admin = new User(phone, email, passwordEncoder.encode(req.getPassword()));
        admin.addRole(adminRole);
        User saved = userRepository.save(admin);

        auditService.logEvent(superAdminId, "ADMIN_CREATED", "USER", saved.getId().toString(),
                "Created regular admin account for phone " + phone, null);
        return UserSummaryDto.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<UserSummaryDto> listAdmins() {
        return userRepository.findAll().stream()
                .filter(u -> u.hasRole("ROLE_ADMIN") || u.hasRole("ROLE_SUPER_ADMIN"))
                .map(UserSummaryDto::fromEntity)
                .toList();
    }

    @Transactional
    public UserSummaryDto setAdminStatus(UUID adminId, UUID superAdminId, String status) {
        User target = userRepository.findById(adminId)
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "Admin user not found", HttpStatus.NOT_FOUND));
        if (target.hasRole("ROLE_SUPER_ADMIN") && !"ACTIVE".equals(status)) {
            throw new ApiException("FORBIDDEN", "Cannot deactivate a Super Admin account", HttpStatus.FORBIDDEN);
        }
        target.setStatus(status);
        target.setUpdatedAt(Instant.now());
        User saved = userRepository.save(target);
        auditService.logEvent(superAdminId, "ADMIN_STATUS_" + status, "USER", adminId.toString(),
                "Updated admin status to " + status, null);
        return UserSummaryDto.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<AuditLog> listAuditLogs() {
        return auditLogRepository.findAll();
    }
}
