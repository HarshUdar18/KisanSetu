package com.kisansetu.farmer;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.catalog.entity.ProductCategory;
import com.kisansetu.modules.farmer.FarmerListingService;
import com.kisansetu.modules.farmer.dto.CreateListingRequest;
import com.kisansetu.modules.farmer.dto.FarmerListingDto;
import com.kisansetu.modules.farmer.dto.UpdateAvailabilityRequest;
import com.kisansetu.modules.farmer.dto.UpdateListingRequest;
import com.kisansetu.modules.farmer.entity.FarmerListing;
import com.kisansetu.modules.farmer.entity.FarmerProfile;
import com.kisansetu.modules.farmer.repository.FarmerListingRepository;
import com.kisansetu.modules.farmer.repository.FarmerProfileRepository;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.product.repository.ProductRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.http.HttpStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class FarmerListingTest {

    private FarmerListingRepository listingRepository;
    private ProductRepository productRepository;
    private UserRepository userRepository;
    private FarmerProfileRepository farmerProfileRepository;
    private FarmerListingService listingService;

    private User farmerUser;
    private User otherFarmerUser;
    private FarmerProfile farmerProfile;
    private Product product;
    private FarmerListing existingListing;

    @BeforeEach
    void setUp() {
        listingRepository = Mockito.mock(FarmerListingRepository.class);
        productRepository = Mockito.mock(ProductRepository.class);
        userRepository = Mockito.mock(UserRepository.class);
        farmerProfileRepository = Mockito.mock(FarmerProfileRepository.class);

        listingService = new FarmerListingService(listingRepository, productRepository, userRepository, farmerProfileRepository);

        farmerUser = new User("9876543212", "farmer@kisansetu.com", "hash");
        farmerUser.setId(UUID.randomUUID());

        otherFarmerUser = new User("9876543299", "farmer2@kisansetu.com", "hash");
        otherFarmerUser.setId(UUID.randomUUID());

        farmerProfile = new FarmerProfile(farmerUser, "Tukaram Patil", "Khed", "Pune", "Maharashtra", "410501", "Vegetables");
        farmerProfile.setId(UUID.randomUUID());

        ProductCategory category = new ProductCategory("Vegetables", "VEGETABLES", "Fresh farm vegetables", null, 1);
        product = new Product(category, "Desi Tomato", "टोमॅटो", "Fresh red country tomatoes", "kg", null);
        product.setId(UUID.randomUUID());

        existingListing = new FarmerListing(
                farmerUser,
                product,
                new BigDecimal("150.00"),
                "kg",
                new BigDecimal("32.50"),
                LocalDate.now().plusDays(1),
                "Premium juicy tomatoes",
                "GRADE_A"
        );
        existingListing.setId(UUID.randomUUID());
    }

    @Test
    @DisplayName("Farmer can successfully create a produce listing")
    void testCreateListingSuccess() {
        CreateListingRequest request = new CreateListingRequest();
        request.setProductId(product.getId());
        request.setQuantityAvailable(new BigDecimal("200.00"));
        request.setUnit("kg");
        request.setPricePerUnit(new BigDecimal("30.00"));
        request.setHarvestDate(LocalDate.now());
        request.setDescription("Freshly picked tomatoes");
        request.setQualityGrade("GRADE_A");

        when(userRepository.findById(farmerUser.getId())).thenReturn(Optional.of(farmerUser));
        when(farmerProfileRepository.findByUserId(farmerUser.getId())).thenReturn(Optional.of(farmerProfile));
        when(productRepository.findById(product.getId())).thenReturn(Optional.of(product));
        when(listingRepository.save(any(FarmerListing.class))).thenAnswer(invocation -> {
            FarmerListing saved = invocation.getArgument(0);
            saved.setId(UUID.randomUUID());
            return saved;
        });

        FarmerListingDto result = listingService.createListing(farmerUser.getId(), request);

        assertNotNull(result);
        assertEquals(product.getId(), result.getProductId());
        assertEquals(farmerUser.getId(), result.getFarmerId());
        assertEquals(new BigDecimal("200.00"), result.getQuantityAvailable());
        assertEquals("kg", result.getUnit());
        assertEquals(new BigDecimal("30.00"), result.getPricePerUnit());
        assertTrue(result.getIsAvailable());
        assertEquals("ACTIVE", result.getStatus());
        verify(listingRepository, times(1)).save(any(FarmerListing.class));
    }

    @Test
    @DisplayName("Create listing fails when farmer user is not found")
    void testCreateListingFailsWhenUserNotFound() {
        CreateListingRequest request = new CreateListingRequest();
        request.setProductId(product.getId());

        when(userRepository.findById(farmerUser.getId())).thenReturn(Optional.empty());

        ApiException exception = assertThrows(ApiException.class, () ->
                listingService.createListing(farmerUser.getId(), request));

        assertEquals("USER_NOT_FOUND", exception.getCode());
        assertEquals(HttpStatus.NOT_FOUND, exception.getStatus());
    }

    @Test
    @DisplayName("Farmer can view own listings")
    void testGetListingsForFarmer() {
        when(farmerProfileRepository.findByUserId(farmerUser.getId())).thenReturn(Optional.of(farmerProfile));
        when(listingRepository.findByFarmerIdOrderByCreatedAtDesc(farmerUser.getId()))
                .thenReturn(List.of(existingListing));

        List<FarmerListingDto> listings = listingService.getFarmerListings(farmerUser.getId());

        assertNotNull(listings);
        assertEquals(1, listings.size());
        assertEquals(existingListing.getId(), listings.get(0).getId());
        assertEquals("Tukaram Patil", listings.get(0).getFarmerName());
    }

    @Test
    @DisplayName("Farmer can update own listing")
    void testUpdateOwnListingSuccess() {
        UpdateListingRequest request = new UpdateListingRequest();
        request.setQuantityAvailable(new BigDecimal("120.00"));
        request.setPricePerUnit(new BigDecimal("34.00"));
        request.setQualityGrade("GRADE_A_PLUS");
        request.setIsAvailable(true);

        when(listingRepository.findById(existingListing.getId())).thenReturn(Optional.of(existingListing));
        when(farmerProfileRepository.findByUserId(farmerUser.getId())).thenReturn(Optional.of(farmerProfile));
        when(listingRepository.save(any(FarmerListing.class))).thenAnswer(invocation -> invocation.getArgument(0));

        FarmerListingDto updated = listingService.updateListing(farmerUser.getId(), existingListing.getId(), request);

        assertNotNull(updated);
        assertEquals(new BigDecimal("120.00"), updated.getQuantityAvailable());
        assertEquals(new BigDecimal("34.00"), updated.getPricePerUnit());
        assertEquals("GRADE_A_PLUS", updated.getQualityGrade());
    }

    @Test
    @DisplayName("Farmer B is prohibited from updating Farmer A's listing (403 Forbidden)")
    void testUpdateListingProhibitsUnauthorizedFarmer() {
        UpdateListingRequest request = new UpdateListingRequest();
        request.setQuantityAvailable(new BigDecimal("50.00"));

        when(listingRepository.findById(existingListing.getId())).thenReturn(Optional.of(existingListing));

        ApiException exception = assertThrows(ApiException.class, () ->
                listingService.updateListing(otherFarmerUser.getId(), existingListing.getId(), request));

        assertEquals("UNAUTHORIZED_ACCESS", exception.getCode());
        assertEquals(HttpStatus.FORBIDDEN, exception.getStatus());
        verify(listingRepository, never()).save(any());
    }

    @Test
    @DisplayName("Farmer can toggle availability of produce listing")
    void testUpdateAvailabilitySuccess() {
        UpdateAvailabilityRequest request = new UpdateAvailabilityRequest();
        request.setIsAvailable(false);

        when(listingRepository.findById(existingListing.getId())).thenReturn(Optional.of(existingListing));
        when(farmerProfileRepository.findByUserId(farmerUser.getId())).thenReturn(Optional.of(farmerProfile));
        when(listingRepository.save(any(FarmerListing.class))).thenAnswer(invocation -> invocation.getArgument(0));

        FarmerListingDto updated = listingService.updateAvailability(farmerUser.getId(), existingListing.getId(), request);

        assertNotNull(updated);
        assertFalse(updated.getIsAvailable());
        assertEquals("INACTIVE", updated.getStatus());
    }
}
