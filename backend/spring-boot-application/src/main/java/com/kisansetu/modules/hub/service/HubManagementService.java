package com.kisansetu.modules.hub.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.audit.AuditService;
import com.kisansetu.modules.hub.dto.CreateHubRequest;
import com.kisansetu.modules.hub.dto.HubDto;
import com.kisansetu.modules.hub.dto.UpdateHubRequest;
import com.kisansetu.modules.hub.entity.Hub;
import com.kisansetu.modules.hub.entity.HubAdminAssignment;
import com.kisansetu.modules.hub.repository.HubAdminAssignmentRepository;
import com.kisansetu.modules.hub.repository.HubRepository;
import com.kisansetu.modules.location.spatial.SpatialLocationService;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class HubManagementService {

        private final HubRepository hubRepository;
        private final HubAdminAssignmentRepository assignmentRepository;
        private final UserRepository userRepository;
        private final AuditService auditService;
        private final SpatialLocationService spatialLocationService;

        public HubManagementService(HubRepository hubRepository,
                        HubAdminAssignmentRepository assignmentRepository,
                        UserRepository userRepository,
                        AuditService auditService,
                        SpatialLocationService spatialLocationService) {
                this.hubRepository = hubRepository;
                this.assignmentRepository = assignmentRepository;
                this.userRepository = userRepository;
                this.auditService = auditService;
                this.spatialLocationService = spatialLocationService;
        }

        @Transactional
        public HubDto createHub(UUID superAdminId, CreateHubRequest req) {
                String normalizedCode = req.getCode().trim().toUpperCase();
                if (hubRepository.existsByCode(normalizedCode)) {
                        throw new ApiException("DUPLICATE_HUB_CODE", "Hub code already exists: " + normalizedCode,
                                        HttpStatus.CONFLICT);
                }

                User creator = userRepository.findById(superAdminId)
                                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "Acting user not found",
                                                HttpStatus.NOT_FOUND));

                Hub hub = new Hub();
                hub.setName(req.getName().trim());
                hub.setCode(normalizedCode);
                hub.setHubType(req.getHubType() != null && !req.getHubType().isBlank()
                                ? req.getHubType().trim().toUpperCase()
                                : "COLLECTION_HUB");
                hub.setAddressLine(req.getAddressLine());
                hub.setVillage(req.getVillage());
                hub.setDistrict(req.getDistrict());
                hub.setState(req.getState());
                hub.setPincode(req.getPincode());
                hub.setLatitude(req.getLatitude());
                hub.setLongitude(req.getLongitude());
                hub.setContactName(req.getContactName());
                hub.setContactPhone(req.getContactPhone());
                hub.setStatus("ACTIVE");
                hub.setCreatedBy(creator);

                Hub saved = hubRepository.saveAndFlush(hub);
                spatialLocationService.syncHubLocation(
                                saved.getId(),
                                saved.getLatitude() != null ? saved.getLatitude().doubleValue() : null,
                                saved.getLongitude() != null ? saved.getLongitude().doubleValue() : null);
                auditService.logEvent(superAdminId, "HUB_CREATED", "HUB", saved.getId().toString(),
                                "Created hub " + saved.getCode() + " (" + saved.getName() + ")", null);
                return HubDto.fromEntity(saved);
        }

        @Transactional
        public HubDto updateHub(UUID hubId, UUID superAdminId, UpdateHubRequest req) {
                Hub hub = hubRepository.findById(hubId)
                                .orElseThrow(() -> new ApiException("HUB_NOT_FOUND", "Hub not found",
                                                HttpStatus.NOT_FOUND));

                if (req.getName() != null && !req.getName().isBlank())
                        hub.setName(req.getName().trim());
                if (req.getHubType() != null && !req.getHubType().isBlank())
                        hub.setHubType(req.getHubType().trim().toUpperCase());
                if (req.getAddressLine() != null)
                        hub.setAddressLine(req.getAddressLine());
                if (req.getVillage() != null)
                        hub.setVillage(req.getVillage());
                if (req.getDistrict() != null)
                        hub.setDistrict(req.getDistrict());
                if (req.getState() != null)
                        hub.setState(req.getState());
                if (req.getPincode() != null)
                        hub.setPincode(req.getPincode());
                if (req.getLatitude() != null)
                        hub.setLatitude(req.getLatitude());
                if (req.getLongitude() != null)
                        hub.setLongitude(req.getLongitude());
                if (req.getContactName() != null)
                        hub.setContactName(req.getContactName());
                if (req.getContactPhone() != null)
                        hub.setContactPhone(req.getContactPhone());
                hub.setUpdatedAt(Instant.now());

                Hub saved = hubRepository.saveAndFlush(hub);
                spatialLocationService.syncHubLocation(
                                saved.getId(),
                                saved.getLatitude() != null ? saved.getLatitude().doubleValue() : null,
                                saved.getLongitude() != null ? saved.getLongitude().doubleValue() : null);
                auditService.logEvent(superAdminId, "HUB_UPDATED", "HUB", saved.getId().toString(),
                                "Updated hub " + saved.getCode(), null);
                return HubDto.fromEntity(saved);
        }

        @Transactional
        public HubDto toggleHubStatus(UUID hubId, UUID superAdminId, String status) {
                Hub hub = hubRepository.findById(hubId)
                                .orElseThrow(() -> new ApiException("HUB_NOT_FOUND", "Hub not found",
                                                HttpStatus.NOT_FOUND));
                String normalized = status != null ? status.trim().toUpperCase() : "INACTIVE";
                if (!normalized.equals("ACTIVE") && !normalized.equals("INACTIVE")
                                && !normalized.equals("MAINTENANCE")) {
                        throw new ApiException("INVALID_STATUS", "Hub status must be ACTIVE, INACTIVE, or MAINTENANCE",
                                        HttpStatus.BAD_REQUEST);
                }
                hub.setStatus(normalized);
                hub.setUpdatedAt(Instant.now());
                Hub saved = hubRepository.save(hub);
                auditService.logEvent(superAdminId, "HUB_STATUS_CHANGED", "HUB", saved.getId().toString(),
                                "Changed hub status to " + normalized, null);
                return HubDto.fromEntity(saved);
        }

        @Transactional
        public void assignAdminToHub(UUID hubId, UUID adminUserId, UUID superAdminId) {
                Hub hub = hubRepository.findById(hubId)
                                .orElseThrow(() -> new ApiException("HUB_NOT_FOUND", "Hub not found",
                                                HttpStatus.NOT_FOUND));
                User admin = userRepository.findById(adminUserId)
                                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "Admin user not found",
                                                HttpStatus.NOT_FOUND));
                if (!admin.hasRole("ROLE_ADMIN") && !admin.hasRole("ROLE_SUPER_ADMIN")) {
                        throw new ApiException("INVALID_ROLE", "User must hold ROLE_ADMIN to be assigned to a hub",
                                        HttpStatus.BAD_REQUEST);
                }
                User assigner = userRepository.findById(superAdminId).orElse(null);

                HubAdminAssignment assignment = assignmentRepository.findByHubIdAndAdminUserId(hubId, adminUserId)
                                .orElseGet(HubAdminAssignment::new);
                assignment.setHub(hub);
                assignment.setAdminUser(admin);
                assignment.setAssignedBy(assigner);
                assignment.setAssignedAt(Instant.now());
                assignment.setActive(true);
                assignmentRepository.save(assignment);

                auditService.logEvent(superAdminId, "HUB_ADMIN_ASSIGNED", "HUB", hub.getId().toString(),
                                "Assigned admin " + adminUserId + " to hub " + hub.getCode(), null);
        }

        @Transactional
        public void removeAdminFromHub(UUID hubId, UUID adminUserId, UUID superAdminId) {
                HubAdminAssignment assignment = assignmentRepository.findByHubIdAndAdminUserId(hubId, adminUserId)
                                .orElseThrow(() -> new ApiException("ASSIGNMENT_NOT_FOUND",
                                                "Hub admin assignment not found", HttpStatus.NOT_FOUND));
                assignment.setActive(false);
                assignmentRepository.save(assignment);
                auditService.logEvent(superAdminId, "HUB_ADMIN_REMOVED", "HUB", hubId.toString(),
                                "Removed admin " + adminUserId + " from hub", null);
        }

        @Transactional(readOnly = true)
        public List<HubDto> listHubs(String status, UUID requestingUserId, boolean isSuperAdmin) {
                if (isSuperAdmin) {
                        List<Hub> hubs = (status != null && !status.isBlank())
                                        ? hubRepository.findByStatus(status.trim().toUpperCase())
                                        : hubRepository.findAll();
                        return hubs.stream().map(HubDto::fromEntity).toList();
                }
                return assignmentRepository.findByAdminUserIdAndActiveTrue(requestingUserId).stream()
                                .map(HubAdminAssignment::getHub)
                                .filter(h -> status == null || status.isBlank()
                                                || h.getStatus().equalsIgnoreCase(status.trim()))
                                .map(HubDto::fromEntity)
                                .toList();
        }

        @Transactional(readOnly = true)
        public HubDto getHub(UUID hubId, UUID requestingUserId, boolean isSuperAdmin) {
                Hub hub = hubRepository.findById(hubId)
                                .orElseThrow(() -> new ApiException("HUB_NOT_FOUND", "Hub not found",
                                                HttpStatus.NOT_FOUND));
                if (!isSuperAdmin && !assignmentRepository.existsByHubIdAndAdminUserIdAndActiveTrue(hubId,
                                requestingUserId)) {
                        throw new ApiException("FORBIDDEN", "You are not assigned to this hub", HttpStatus.FORBIDDEN);
                }
                return HubDto.fromEntity(hub);
        }
}
