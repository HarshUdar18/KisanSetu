package com.kisansetu.admin;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.admin.controller.AdminController;
import com.kisansetu.modules.admin.dto.CreateCategoryRequest;
import com.kisansetu.modules.admin.dto.UserSummaryDto;
import com.kisansetu.modules.catalog.dto.CategoryDto;
import com.kisansetu.modules.catalog.entity.ProductCategory;
import com.kisansetu.modules.catalog.repository.ProductCategoryRepository;
import com.kisansetu.modules.user.entity.Role;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class AdminControllerTest {

    private UserRepository userRepository;
    private ProductCategoryRepository productCategoryRepository;
    private AdminController adminController;

    private User sampleUser;
    private Role customerRole;

    @BeforeEach
    void setUp() {
        userRepository = Mockito.mock(UserRepository.class);
        productCategoryRepository = Mockito.mock(ProductCategoryRepository.class);

        adminController = new AdminController(
                userRepository,
                productCategoryRepository,
                Mockito.mock(com.kisansetu.modules.order.repository.OrderRepository.class),
                Mockito.mock(com.kisansetu.modules.farmer.repository.FarmerProfileRepository.class));

        customerRole = new Role("ROLE_CUSTOMER", "Registered Customer");

        sampleUser = new User("9876543211", "customer@kisansetu.com", "hash");
        sampleUser.setId(UUID.randomUUID());
        sampleUser.setRoles(Set.of(customerRole));
    }

    @Test
    @DisplayName("Admin can view list of all registered users with their roles")
    void testGetAllUsers() {
        when(userRepository.findAll()).thenReturn(List.of(sampleUser));

        ResponseEntity<ApiResponse<List<UserSummaryDto>>> response = adminController.getAllUsers();

        assertNotNull(response.getBody());
        assertTrue(response.getBody().isSuccess());
        List<UserSummaryDto> users = response.getBody().getData();
        assertEquals(1, users.size());
        assertEquals("9876543211", users.get(0).getPhone());
        assertTrue(users.get(0).getRoles().contains("ROLE_CUSTOMER"));
    }

    @Test
    @DisplayName("Admin can create a new product category")
    void testCreateCategorySuccess() {
        CreateCategoryRequest request = new CreateCategoryRequest();
        request.setName("Organic Cereals");
        request.setCode("CEREALS");
        request.setDescription("Healthy unpolished grains");
        request.setDisplayOrder(5);

        when(productCategoryRepository.findByCode("CEREALS")).thenReturn(Optional.empty());
        when(productCategoryRepository.save(any(ProductCategory.class))).thenAnswer(invocation -> {
            ProductCategory cat = invocation.getArgument(0);
            cat.setId(UUID.randomUUID());
            return cat;
        });

        ResponseEntity<ApiResponse<CategoryDto>> response = adminController.createCategory(request);

        assertNotNull(response.getBody());
        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        CategoryDto created = response.getBody().getData();
        assertEquals("Organic Cereals", created.getName());
        assertEquals("CEREALS", created.getCode());
        verify(productCategoryRepository, times(1)).save(any(ProductCategory.class));
    }

    @Test
    @DisplayName("Category creation rejects duplicate category code (409 Conflict)")
    void testCreateCategoryRejectsDuplicateCode() {
        CreateCategoryRequest request = new CreateCategoryRequest();
        request.setName("Vegetables");
        request.setCode("VEGETABLES");

        ProductCategory existing = new ProductCategory("Vegetables", "VEGETABLES", "Vegetables", null, 1);
        when(productCategoryRepository.findByCode("VEGETABLES")).thenReturn(Optional.of(existing));

        ApiException exception = assertThrows(ApiException.class, () -> adminController.createCategory(request));

        assertEquals("DUPLICATE_CATEGORY", exception.getCode());
        assertEquals(HttpStatus.CONFLICT, exception.getStatus());
        verify(productCategoryRepository, never()).save(any(ProductCategory.class));
    }
}
