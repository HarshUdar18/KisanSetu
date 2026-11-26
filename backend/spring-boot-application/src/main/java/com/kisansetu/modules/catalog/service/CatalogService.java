package com.kisansetu.modules.catalog.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.catalog.dto.CategoryDto;
import com.kisansetu.modules.catalog.entity.ProductCategory;
import com.kisansetu.modules.catalog.repository.ProductCategoryRepository;
import com.kisansetu.modules.farmer.entity.FarmerListing;
import com.kisansetu.modules.farmer.repository.FarmerListingRepository;
import com.kisansetu.modules.pricing.entity.MarketPrice;
import com.kisansetu.modules.pricing.repository.MarketPriceRepository;
import com.kisansetu.modules.product.dto.ProductDto;
import com.kisansetu.modules.product.entity.*;
import com.kisansetu.modules.product.repository.*;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class CatalogService {

    private final ProductCategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final MarketPriceRepository marketPriceRepository;
    private final FarmerListingRepository farmerListingRepository;
    private final ProductVarietyRepository varietyRepository;
    private final ProductVariantRepository variantRepository;
    private final ProductTranslationRepository translationRepository;
    private final ProductUnitRepository unitRepository;
    private final UnitConversionRepository conversionRepository;

    public CatalogService(ProductCategoryRepository categoryRepository,
                          ProductRepository productRepository,
                          MarketPriceRepository marketPriceRepository,
                          FarmerListingRepository farmerListingRepository,
                          ProductVarietyRepository varietyRepository,
                          ProductVariantRepository variantRepository,
                          ProductTranslationRepository translationRepository,
                          ProductUnitRepository unitRepository,
                          UnitConversionRepository conversionRepository) {
        this.categoryRepository = categoryRepository;
        this.productRepository = productRepository;
        this.marketPriceRepository = marketPriceRepository;
        this.farmerListingRepository = farmerListingRepository;
        this.varietyRepository = varietyRepository;
        this.variantRepository = variantRepository;
        this.translationRepository = translationRepository;
        this.unitRepository = unitRepository;
        this.conversionRepository = conversionRepository;
    }

    @Transactional(readOnly = true)
    @Cacheable(value = "catalogCategories", key = "'all'")
    public List<CategoryDto> getCategories() {
        Map<UUID, Long> countsByCat = productRepository.findAll().stream()
                .filter(p -> p.getCategory() != null)
                .collect(Collectors.groupingBy(p -> p.getCategory().getId(), Collectors.counting()));
        return categoryRepository.findByIsActiveTrueOrderByDisplayOrderAsc()
                .stream()
                .map(category -> CategoryDto.fromEntity(category, countsByCat.getOrDefault(category.getId(), 0L)))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ProductDto> getProducts(UUID categoryId, String query) {
        return getProducts(categoryId, query, "stock_first", null);
    }

    @Transactional(readOnly = true)
    public List<ProductDto> getProducts(UUID categoryId, String query, String sortBy, Boolean inStockOnly) {
        List<Product> products;
        if (query != null && !query.trim().isEmpty()) {
            products = productRepository.searchProducts(query.trim());
        } else if (categoryId != null) {
            products = productRepository.findByCategoryId(categoryId);
        } else {
            products = productRepository.findAll();
        }

        Map<UUID, MarketPrice> priceMap = marketPriceRepository.findAll().stream()
                .filter(mp -> mp.getProduct() != null)
                .collect(Collectors.toMap(mp -> mp.getProduct().getId(), mp -> mp, (a, b) -> a));

        Map<UUID, List<FarmerListing>> listingsByProduct = farmerListingRepository.findByIsAvailableTrueOrderByCreatedAtDesc()
                .stream()
                .filter(l -> l.getProduct() != null && "ACTIVE".equalsIgnoreCase(l.getStatus()))
                .collect(Collectors.groupingBy(l -> l.getProduct().getId()));

        List<ProductDto> dtos = products.stream()
                .map(p -> mapProductWithBatchData(p, priceMap.get(p.getId()), listingsByProduct.getOrDefault(p.getId(), List.of())))
                .filter(dto -> !Boolean.TRUE.equals(inStockOnly) || "IN_STOCK".equals(dto.getStockStatus()) || "LOW_STOCK".equals(dto.getStockStatus()))
                .collect(Collectors.toList());

        Comparator<ProductDto> stockOrder = Comparator.comparingInt(dto -> switch (dto.getStockStatus()) {
            case "IN_STOCK" -> 0;
            case "LOW_STOCK" -> 1;
            case "OUT_OF_STOCK" -> 2;
            default -> 3;
        });

        Comparator<ProductDto> secondary = switch (sortBy != null ? sortBy : "stock_first") {
            case "name" -> Comparator.comparing(ProductDto::getName, String.CASE_INSENSITIVE_ORDER);
            case "price_asc" -> Comparator.comparing(d -> d.getCurrentPrice() != null ? d.getCurrentPrice() : BigDecimal.valueOf(Double.MAX_VALUE));
            case "price_desc" -> Comparator.comparing((ProductDto d) -> d.getCurrentPrice() != null ? d.getCurrentPrice() : BigDecimal.ZERO).reversed();
            default -> Comparator.comparing(ProductDto::getName, String.CASE_INSENSITIVE_ORDER);
        };

        dtos.sort(stockOrder.thenComparing(secondary));
        return dtos;
    }

    @Transactional(readOnly = true)
    public ProductDto getProduct(UUID productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found", HttpStatus.NOT_FOUND));
        return mapProductWithPrice(product);
    }

    @Transactional(readOnly = true)
    public CategoryDto getCategory(UUID categoryId) {
        ProductCategory cat = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new ApiException("CATEGORY_NOT_FOUND", "Category not found", HttpStatus.NOT_FOUND));
        long count = productRepository.findByCategoryIdAndIsAvailableTrue(cat.getId()).size();
        return CategoryDto.fromEntity(cat, count);
    }

    @Transactional(readOnly = true)
    public ProductDto getProductByCode(String productCode) {
        Product product = productRepository.findByProductCodeIgnoreCase(productCode.trim())
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found for code: " + productCode, HttpStatus.NOT_FOUND));
        return mapProductWithPrice(product);
    }

    @Transactional(readOnly = true)
    public List<ProductVariety> getVarieties(UUID productId) {
        return varietyRepository.findByProductIdAndIsActiveTrueOrderByVarietyNameAsc(productId);
    }

    @Transactional(readOnly = true)
    public List<ProductVariant> getVariants(UUID productId) {
        return variantRepository.findByProductIdAndIsActiveTrue(productId);
    }

    @Transactional(readOnly = true)
    public List<ProductTranslation> getTranslations(UUID productId) {
        return translationRepository.findByProductId(productId);
    }

    @Transactional(readOnly = true)
    public List<ProductUnit> getUnits() {
        return unitRepository.findByIsActiveTrueOrderByCategoryAscCodeAsc();
    }

    @Transactional(readOnly = true)
    public Map<String, Object> convertUnit(String fromCode, String toCode, BigDecimal quantity) {
        ProductUnit from = unitRepository.findByCodeIgnoreCase(fromCode.trim())
                .orElseThrow(() -> new ApiException("UNIT_NOT_FOUND", "Unknown unit: " + fromCode, HttpStatus.NOT_FOUND));
        ProductUnit to = unitRepository.findByCodeIgnoreCase(toCode.trim())
                .orElseThrow(() -> new ApiException("UNIT_NOT_FOUND", "Unknown unit: " + toCode, HttpStatus.NOT_FOUND));

        if (!from.getCategory().equals(to.getCategory())) {
            throw new ApiException("INVALID_UNIT_CONVERSION",
                    "Cannot convert between different unit categories: " + from.getCategory() + " and " + to.getCategory(),
                    HttpStatus.BAD_REQUEST);
        }
        if (from.getId().equals(to.getId())) {
            return Map.of("from", from.getCode(), "to", to.getCode(), "quantity", quantity, "convertedQuantity", quantity);
        }

        BigDecimal factor = conversionRepository.findByFromUnitIdAndToUnitId(from.getId(), to.getId())
                .map(UnitConversion::getConversionFactor)
                .orElseGet(() -> conversionRepository.findByFromUnitIdAndToUnitId(to.getId(), from.getId())
                        .map(inv -> BigDecimal.ONE.divide(inv.getConversionFactor(), 6, RoundingMode.HALF_UP))
                        .orElseThrow(() -> new ApiException("CONVERSION_NOT_DEFINED",
                                "No explicit conversion rule between " + from.getCode() + " and " + to.getCode(),
                                HttpStatus.BAD_REQUEST)));

        return Map.of(
                "from", from.getCode(),
                "to", to.getCode(),
                "quantity", quantity,
                "convertedQuantity", quantity.multiply(factor).setScale(3, RoundingMode.HALF_UP)
        );
    }

    private ProductDto mapProductWithPrice(Product product) {
        MarketPrice mp = marketPriceRepository.findByProductId(product.getId()).orElse(null);
        List<FarmerListing> listings = farmerListingRepository.findByProductIdAndIsAvailableTrue(product.getId());
        return mapProductWithBatchData(product, mp, listings);
    }

    private ProductDto mapProductWithBatchData(Product product, MarketPrice mp, List<FarmerListing> listings) {
        List<FarmerListing> stockedListings = listings.stream()
                .filter(l -> l.getQuantityAvailable() != null && l.getQuantityAvailable().compareTo(BigDecimal.ZERO) > 0)
                .toList();

        BigDecimal totalListingQty = stockedListings.stream()
                .map(FarmerListing::getQuantityAvailable)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal lowestListingPrice = stockedListings.stream()
                .map(FarmerListing::getPricePerUnit)
                .filter(p -> p != null && p.compareTo(BigDecimal.ZERO) > 0)
                .min(BigDecimal::compareTo)
                .orElse(null);

        BigDecimal effectivePrice = lowestListingPrice != null
                ? lowestListingPrice
                : (mp != null ? mp.getCurrentPrice() : null);
        BigDecimal prevPrice = mp != null ? mp.getPreviousPrice() : null;

        ProductDto dto = ProductDto.fromEntity(product, effectivePrice, prevPrice);
        dto.setActiveListingCount(stockedListings.size());
        dto.setLowestListingPrice(lowestListingPrice);

        BigDecimal effectiveStock = totalListingQty.compareTo(BigDecimal.ZERO) > 0
                ? totalListingQty
                : (product.getStockQuantity() != null ? product.getStockQuantity() : BigDecimal.ZERO);
        dto.setStockQuantity(effectiveStock);

        if (!product.isAvailable()) {
            dto.setStockStatus("UNAVAILABLE");
        } else if (effectiveStock.compareTo(BigDecimal.ZERO) <= 0) {
            dto.setStockStatus("OUT_OF_STOCK");
        } else if (effectiveStock.compareTo(BigDecimal.TEN) <= 0) {
            dto.setStockStatus("LOW_STOCK");
        } else {
            dto.setStockStatus("IN_STOCK");
        }
        return dto;
    }
}
