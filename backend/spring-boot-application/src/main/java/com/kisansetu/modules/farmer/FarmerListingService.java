package com.kisansetu.modules.farmer;

import com.kisansetu.common.events.DomainEventPublisher;
import com.kisansetu.common.exception.ApiException;
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
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class FarmerListingService {

    private final FarmerListingRepository listingRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final FarmerProfileRepository farmerProfileRepository;
    private final DomainEventPublisher eventPublisher;

    @org.springframework.beans.factory.annotation.Autowired
    public FarmerListingService(FarmerListingRepository listingRepository,
            ProductRepository productRepository,
            UserRepository userRepository,
            FarmerProfileRepository farmerProfileRepository,
            DomainEventPublisher eventPublisher) {
        this.listingRepository = listingRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
        this.farmerProfileRepository = farmerProfileRepository;
        this.eventPublisher = eventPublisher;
    }

    public FarmerListingService(FarmerListingRepository listingRepository,
            ProductRepository productRepository,
            UserRepository userRepository,
            FarmerProfileRepository farmerProfileRepository) {
        this(listingRepository, productRepository, userRepository, farmerProfileRepository, null);
    }

    @Transactional
    @CacheEvict(value = { "catalogProducts", "catalogCategories" }, allEntries = true)
    public FarmerListingDto createListing(UUID farmerId, CreateListingRequest request) {
        User farmer = userRepository.findById(farmerId)
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "Farmer user not found", HttpStatus.NOT_FOUND));

        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found: " + request.getProductId(),
                        HttpStatus.NOT_FOUND));

        String unit = request.getUnit() != null ? request.getUnit() : product.getUnit();

        FarmerListing listing = new FarmerListing(
                farmer,
                product,
                request.getQuantityAvailable(),
                unit,
                request.getPricePerUnit(),
                request.getHarvestDate(),
                request.getDescription(),
                request.getQualityGrade());

        FarmerListing saved = listingRepository.save(listing);
        publishListingChanged(saved);
        String farmerName = getFarmerName(farmerId);
        return FarmerListingDto.fromEntity(saved, farmerName);
    }

    private void publishListingChanged(FarmerListing listing) {
        if (eventPublisher == null)
            return;
        eventPublisher.publish("listing.stock_updated", "com.kisansetu.events.ListingStockUpdated", Map.of(
                "listingId", listing.getId().toString(),
                "productId", listing.getProduct().getId().toString(),
                "farmerId", listing.getFarmer().getId().toString(),
                "quantityAvailable",
                listing.getQuantityAvailable() != null ? listing.getQuantityAvailable().toString() : "0",
                "pricePerUnit", listing.getPricePerUnit() != null ? listing.getPricePerUnit().toString() : "0",
                "isAvailable", Boolean.TRUE.equals(listing.getIsAvailable())));
    }

    @Transactional(readOnly = true)
    public List<FarmerListingDto> getFarmerListings(UUID farmerId) {
        String farmerName = getFarmerName(farmerId);
        return listingRepository.findByFarmerIdOrderByCreatedAtDesc(farmerId).stream()
                .map(entity -> FarmerListingDto.fromEntity(entity, farmerName))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public FarmerListingDto getListingById(UUID listingId) {
        FarmerListing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ApiException("LISTING_NOT_FOUND", "Listing not found: " + listingId,
                        HttpStatus.NOT_FOUND));
        String farmerName = getFarmerName(listing.getFarmer().getId());
        return FarmerListingDto.fromEntity(listing, farmerName);
    }

    @Transactional
    @CacheEvict(value = { "catalogProducts", "catalogCategories" }, allEntries = true)
    public FarmerListingDto updateListing(UUID farmerId, UUID listingId, UpdateListingRequest request) {
        FarmerListing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ApiException("LISTING_NOT_FOUND", "Listing not found: " + listingId,
                        HttpStatus.NOT_FOUND));

        if (!listing.getFarmer().getId().equals(farmerId)) {
            throw new ApiException("UNAUTHORIZED_ACCESS", "You can only update your own listings",
                    HttpStatus.FORBIDDEN);
        }

        if (request.getQuantityAvailable() != null) {
            listing.setQuantityAvailable(request.getQuantityAvailable());
        }
        if (request.getUnit() != null) {
            listing.setUnit(request.getUnit());
        }
        if (request.getPricePerUnit() != null) {
            listing.setPricePerUnit(request.getPricePerUnit());
        }
        if (request.getHarvestDate() != null) {
            listing.setHarvestDate(request.getHarvestDate());
        }
        if (request.getDescription() != null) {
            listing.setDescription(request.getDescription());
        }
        if (request.getQualityGrade() != null) {
            listing.setQualityGrade(request.getQualityGrade());
        }
        if (request.getIsAvailable() != null) {
            listing.setIsAvailable(request.getIsAvailable());
            listing.setStatus(request.getIsAvailable() ? "ACTIVE" : "INACTIVE");
        }
        listing.setUpdatedAt(Instant.now());

        FarmerListing updated = listingRepository.save(listing);
        publishListingChanged(updated);
        String farmerName = getFarmerName(farmerId);
        return FarmerListingDto.fromEntity(updated, farmerName);
    }

    @Transactional
    @CacheEvict(value = { "catalogProducts", "catalogCategories" }, allEntries = true)
    public FarmerListingDto updateAvailability(UUID farmerId, UUID listingId, UpdateAvailabilityRequest request) {
        FarmerListing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ApiException("LISTING_NOT_FOUND", "Listing not found: " + listingId,
                        HttpStatus.NOT_FOUND));

        if (!listing.getFarmer().getId().equals(farmerId)) {
            throw new ApiException("UNAUTHORIZED_ACCESS", "You can only update your own listings",
                    HttpStatus.FORBIDDEN);
        }

        listing.setIsAvailable(request.getIsAvailable());
        listing.setStatus(request.getIsAvailable() ? "ACTIVE" : "INACTIVE");

        if (request.getQuantityAvailable() != null) {
            listing.setQuantityAvailable(request.getQuantityAvailable());
        }
        listing.setUpdatedAt(Instant.now());

        FarmerListing updated = listingRepository.save(listing);
        publishListingChanged(updated);
        String farmerName = getFarmerName(farmerId);
        return FarmerListingDto.fromEntity(updated, farmerName);
    }

    @Transactional(readOnly = true)
    public List<FarmerListingDto> getListingsByProduct(UUID productId) {
        return listingRepository.findByProductIdAndIsAvailableTrue(productId).stream()
                .map(entity -> FarmerListingDto.fromEntity(entity, getFarmerName(entity.getFarmer().getId())))
                .collect(Collectors.toList());
    }

    private String getFarmerName(UUID farmerId) {
        return farmerProfileRepository.findByUserId(farmerId)
                .map(FarmerProfile::getFullName)
                .orElse("Farmer");
    }
}
