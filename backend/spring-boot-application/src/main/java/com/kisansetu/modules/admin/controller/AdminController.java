package com.kisansetu.modules.admin.controller;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.admin.dto.CreateAdminRequest;
import com.kisansetu.modules.admin.dto.CreateCategoryRequest;
import com.kisansetu.modules.admin.dto.UserSummaryDto;
import com.kisansetu.modules.admin.service.AdminManagementService;
import com.kisansetu.modules.audit.entity.AuditLog;
import com.kisansetu.modules.catalog.dto.CategoryDto;
import com.kisansetu.modules.catalog.entity.ProductCategory;
import com.kisansetu.modules.catalog.repository.ProductCategoryRepository;
import com.kisansetu.modules.farmer.entity.FarmerProfile;
import com.kisansetu.modules.farmer.repository.FarmerProfileRepository;
import com.kisansetu.modules.hub.dto.CreateHubRequest;
import com.kisansetu.modules.hub.dto.HubDto;
import com.kisansetu.modules.hub.dto.UpdateHubRequest;
import com.kisansetu.modules.hub.service.HubManagementService;
import com.kisansetu.modules.order.dto.OrderDto;
import com.kisansetu.modules.order.repository.OrderRepository;
import com.kisansetu.modules.user.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/admin")
@Tag(name = "Admin Management", description = "Endpoints restricted to Platform Administrators and Super Administrators")
@SecurityRequirement(name = "BearerAuth")
@PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
public class AdminController {

    private final UserRepository userRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final OrderRepository orderRepository;
    private final FarmerProfileRepository farmerProfileRepository;
    private final AdminManagementService adminManagementService;
    private final HubManagementService hubManagementService;

    public AdminController(UserRepository userRepository,
                           ProductCategoryRepository productCategoryRepository,
                           OrderRepository orderRepository,
                           FarmerProfileRepository farmerProfileRepository,
                           AdminManagementService adminManagementService,
                           HubManagementService hubManagementService) {
        this.userRepository = userRepository;
        this.productCategoryRepository = productCategoryRepository;
        this.orderRepository = orderRepository;
        this.farmerProfileRepository = farmerProfileRepository;
        this.adminManagementService = adminManagementService;
        this.hubManagementService = hubManagementService;
    }

    @GetMapping("/users")
    @Operation(summary = "List all platform users", description = "Retrieves all users across customer, farmer, and administrator roles.")
    public ResponseEntity<ApiResponse<List<UserSummaryDto>>> getAllUsers() {
        List<UserSummaryDto> users = userRepository.findAll().stream()
                .map(UserSummaryDto::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok("Users retrieved successfully", users));
    }

    @PostMapping("/categories")
    @Operation(summary = "Create product category", description = "Creates a new agricultural product category in the master catalog.")
    public ResponseEntity<ApiResponse<CategoryDto>> createCategory(@Valid @RequestBody CreateCategoryRequest request) {
        if (productCategoryRepository.findByCode(request.getCode().trim().toUpperCase()).isPresent()) {
            throw new ApiException("DUPLICATE_CATEGORY", "Category code already exists: " + request.getCode(), HttpStatus.CONFLICT);
        }

        ProductCategory category = new ProductCategory(
                request.getName().trim(),
                request.getCode().trim().toUpperCase(),
                request.getDescription(),
                request.getIconUrl(),
                request.getDisplayOrder()
        );

        ProductCategory saved = productCategoryRepository.save(category);
        CategoryDto dto = CategoryDto.fromEntity(saved, 0);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Category created successfully", dto));
    }

    @GetMapping("/categories")
    @Operation(summary = "List all product categories for administrative management")
    public ResponseEntity<ApiResponse<List<CategoryDto>>> getAllCategories() {
        List<CategoryDto> categories = productCategoryRepository.findAll().stream()
                .map(c -> CategoryDto.fromEntity(c, 0))
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok("All categories retrieved", categories));
    }

    @GetMapping("/orders")
    @Operation(summary = "List all platform orders for admin operations")
    public ResponseEntity<ApiResponse<List<OrderDto>>> getAllOrders() {
        List<OrderDto> orders = orderRepository.findAll().stream()
                .map(OrderDto::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok("All orders retrieved", orders));
    }

    @GetMapping("/farmers")
    @Operation(summary = "List all farmer profiles for admin management")
    public ResponseEntity<ApiResponse<List<FarmerProfile>>> getAllFarmers() {
        return ResponseEntity.ok(ApiResponse.ok("All farmers retrieved", farmerProfileRepository.findAll()));
    }

    // --- Super Admin: Admin Account Management ---
    @PostMapping("/admins")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Create regular admin account (Super Admin only)")
    public ResponseEntity<ApiResponse<UserSummaryDto>> createAdmin(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateAdminRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Admin account created", adminManagementService.createAdmin(principal.getId(), request)));
    }

    @GetMapping("/admins")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "List all admin & super admin accounts (Super Admin only)")
    public ResponseEntity<ApiResponse<List<UserSummaryDto>>> listAdmins() {
        return ResponseEntity.ok(ApiResponse.ok("Admin accounts retrieved", adminManagementService.listAdmins()));
    }

    @PutMapping("/admins/{id}/activate")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Activate an admin account (Super Admin only)")
    public ResponseEntity<ApiResponse<UserSummaryDto>> activateAdmin(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Admin activated", adminManagementService.setAdminStatus(id, principal.getId(), "ACTIVE")));
    }

    @PutMapping("/admins/{id}/deactivate")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Deactivate an admin account (Super Admin only)")
    public ResponseEntity<ApiResponse<UserSummaryDto>> deactivateAdmin(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Admin deactivated", adminManagementService.setAdminStatus(id, principal.getId(), "INACTIVE")));
    }

    // --- Hub Management (Super Admin mutates; assigned Admins can view) ---
    @PostMapping("/hubs")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Create operational hub (Super Admin only)")
    public ResponseEntity<ApiResponse<HubDto>> createHub(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateHubRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Hub created successfully", hubManagementService.createHub(principal.getId(), request)));
    }

    @GetMapping("/hubs")
    @Operation(summary = "List hubs (Super Admin sees all; regular Admin sees assigned hubs)")
    public ResponseEntity<ApiResponse<List<HubDto>>> listHubs(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(required = false) String status) {
        boolean isSuperAdmin = principal.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_SUPER_ADMIN"));
        return ResponseEntity.ok(ApiResponse.ok("Hubs retrieved",
                hubManagementService.listHubs(status, principal.getId(), isSuperAdmin)));
    }

    @GetMapping("/hubs/{id}")
    @Operation(summary = "Get hub details (Super Admin or assigned Admin)")
    public ResponseEntity<ApiResponse<HubDto>> getHub(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        boolean isSuperAdmin = principal.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_SUPER_ADMIN"));
        return ResponseEntity.ok(ApiResponse.ok("Hub retrieved",
                hubManagementService.getHub(id, principal.getId(), isSuperAdmin)));
    }

    @PutMapping("/hubs/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Update hub details (Super Admin only)")
    public ResponseEntity<ApiResponse<HubDto>> updateHub(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody UpdateHubRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Hub updated",
                hubManagementService.updateHub(id, principal.getId(), request)));
    }

    @PutMapping("/hubs/{id}/status")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Activate or deactivate hub (Super Admin only)")
    public ResponseEntity<ApiResponse<HubDto>> toggleHubStatus(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(ApiResponse.ok("Hub status updated",
                hubManagementService.toggleHubStatus(id, principal.getId(), body.get("status"))));
    }

    @PostMapping("/hubs/{id}/assign-admin")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Assign an admin to a hub (Super Admin only)")
    public ResponseEntity<ApiResponse<Void>> assignAdminToHub(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody Map<String, UUID> body) {
        hubManagementService.assignAdminToHub(id, body.get("adminUserId"), principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Admin assigned to hub", null));
    }

    @DeleteMapping("/hubs/{id}/assign-admin/{adminId}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Remove admin assignment from hub (Super Admin only)")
    public ResponseEntity<ApiResponse<Void>> removeAdminFromHub(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @PathVariable UUID adminId) {
        hubManagementService.removeAdminFromHub(id, adminId, principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Admin removed from hub", null));
    }

    @GetMapping("/audit-logs")
    @Operation(summary = "List administrative audit logs")
    public ResponseEntity<ApiResponse<List<AuditLog>>> listAuditLogs() {
        return ResponseEntity.ok(ApiResponse.ok("Audit logs retrieved", adminManagementService.listAuditLogs()));
    }
}
