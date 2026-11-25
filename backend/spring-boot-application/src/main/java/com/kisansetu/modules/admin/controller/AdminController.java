package com.kisansetu.modules.admin.controller;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.admin.dto.CreateCategoryRequest;
import com.kisansetu.modules.admin.dto.UserSummaryDto;
import com.kisansetu.modules.catalog.dto.CategoryDto;
import com.kisansetu.modules.catalog.entity.ProductCategory;
import com.kisansetu.modules.catalog.repository.ProductCategoryRepository;
import com.kisansetu.modules.farmer.entity.FarmerProfile;
import com.kisansetu.modules.farmer.repository.FarmerProfileRepository;
import com.kisansetu.modules.order.dto.OrderDto;
import com.kisansetu.modules.order.repository.OrderRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/admin")
@Tag(name = "Admin Management", description = "Endpoints restricted strictly to Platform Administrators (ROLE_ADMIN)")
@SecurityRequirement(name = "BearerAuth")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final UserRepository userRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final OrderRepository orderRepository;
    private final FarmerProfileRepository farmerProfileRepository;

    public AdminController(UserRepository userRepository,
                           ProductCategoryRepository productCategoryRepository,
                           OrderRepository orderRepository,
                           FarmerProfileRepository farmerProfileRepository) {
        this.userRepository = userRepository;
        this.productCategoryRepository = productCategoryRepository;
        this.orderRepository = orderRepository;
        this.farmerProfileRepository = farmerProfileRepository;
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
}
