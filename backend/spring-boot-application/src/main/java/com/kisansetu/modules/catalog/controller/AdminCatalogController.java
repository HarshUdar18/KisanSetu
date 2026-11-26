package com.kisansetu.modules.catalog.controller;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.audit.AuditService;
import com.kisansetu.modules.catalog.dto.CategoryDto;
import com.kisansetu.modules.catalog.entity.ProductCategory;
import com.kisansetu.modules.catalog.repository.ProductCategoryRepository;
import com.kisansetu.modules.pricing.entity.MarketPrice;
import com.kisansetu.modules.pricing.repository.MarketPriceRepository;
import com.kisansetu.modules.product.dto.ProductDto;
import com.kisansetu.modules.product.entity.*;
import com.kisansetu.modules.product.repository.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin")
@Tag(name = "Admin Product Taxonomy & Catalogue", description = "Master category, product, variety, variant (SKU), and translation management")
@SecurityRequirement(name = "BearerAuth")
@PreAuthorize("hasRole('ADMIN')")
public class AdminCatalogController {

    private final ProductCategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final MarketPriceRepository marketPriceRepository;
    private final ProductVarietyRepository varietyRepository;
    private final ProductVariantRepository variantRepository;
    private final ProductTranslationRepository translationRepository;
    private final ProductUnitRepository unitRepository;
    private final AuditService auditService;

    public AdminCatalogController(ProductCategoryRepository categoryRepository,
                                  ProductRepository productRepository,
                                  MarketPriceRepository marketPriceRepository,
                                  ProductVarietyRepository varietyRepository,
                                  ProductVariantRepository variantRepository,
                                  ProductTranslationRepository translationRepository,
                                  ProductUnitRepository unitRepository,
                                  AuditService auditService) {
        this.categoryRepository = categoryRepository;
        this.productRepository = productRepository;
        this.marketPriceRepository = marketPriceRepository;
        this.varietyRepository = varietyRepository;
        this.variantRepository = variantRepository;
        this.translationRepository = translationRepository;
        this.unitRepository = unitRepository;
        this.auditService = auditService;
    }

    @PutMapping("/categories/{id}")
    @Transactional
    @Operation(summary = "Update product category (prevents circular parent relationships)")
    public ResponseEntity<ApiResponse<CategoryDto>> updateCategory(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody Map<String, Object> body) {
        ProductCategory cat = categoryRepository.findById(id)
                .orElseThrow(() -> new ApiException("CATEGORY_NOT_FOUND", "Category not found", HttpStatus.NOT_FOUND));

        if (body.get("parentCategoryId") != null && !body.get("parentCategoryId").toString().isBlank()) {
            UUID parentId = UUID.fromString(body.get("parentCategoryId").toString());
            if (parentId.equals(id)) {
                throw new ApiException("CIRCULAR_CATEGORY", "A category cannot be its own parent", HttpStatus.BAD_REQUEST);
            }
            UUID cursor = parentId;
            while (cursor != null) {
                ProductCategory parent = categoryRepository.findById(cursor)
                        .orElseThrow(() -> new ApiException("CATEGORY_NOT_FOUND", "Parent category not found", HttpStatus.NOT_FOUND));
                if (id.equals(parent.getParentCategoryId())) {
                    throw new ApiException("CIRCULAR_CATEGORY", "Circular parent category hierarchy detected", HttpStatus.BAD_REQUEST);
                }
                cursor = parent.getParentCategoryId();
            }
            cat.setParentCategoryId(parentId);
        }
        if (body.get("name") != null) cat.setName(body.get("name").toString().trim());
        if (body.get("description") != null) cat.setDescription(body.get("description").toString());
        if (body.get("displayOrder") != null) cat.setDisplayOrder(Integer.parseInt(body.get("displayOrder").toString()));
        if (body.get("isActive") != null) cat.setActive(Boolean.parseBoolean(body.get("isActive").toString()));
        cat.setUpdatedAt(Instant.now());

        ProductCategory saved = categoryRepository.save(cat);
        auditService.logEvent(principal.getId(), "CATEGORY_UPDATED", "CATEGORY", saved.getId().toString(),
                "Updated category " + saved.getCode(), null);
        return ResponseEntity.ok(ApiResponse.ok("Category updated", CategoryDto.fromEntity(saved, 0)));
    }

    @PostMapping("/products")
    @Transactional
    @Operation(summary = "Create master product with unique category-scoped productCode")
    public ResponseEntity<ApiResponse<ProductDto>> createProduct(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody Map<String, Object> body) {
        UUID categoryId = UUID.fromString(body.get("categoryId").toString());
        ProductCategory category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new ApiException("CATEGORY_NOT_FOUND", "Category not found", HttpStatus.NOT_FOUND));

        String productCode = body.get("productCode").toString().trim().toUpperCase();
        String name = body.get("name").toString().trim();
        String canonicalName = body.get("canonicalName") != null
                ? body.get("canonicalName").toString().trim() : name;

        if (productRepository.existsByCategoryIdAndProductCodeIgnoreCase(categoryId, productCode)) {
            throw new ApiException("DUPLICATE_PRODUCT_CODE", "Product code already exists in this category: " + productCode, HttpStatus.CONFLICT);
        }
        if (productRepository.existsByCanonicalNameIgnoreCase(canonicalName)) {
            throw new ApiException("DUPLICATE_PRODUCT_NAME", "Canonical product name already exists: " + canonicalName, HttpStatus.CONFLICT);
        }

        Product product = new Product();
        product.setCategory(category);
        product.setProductCode(productCode);
        product.setName(name);
        product.setCanonicalName(canonicalName);
        if (body.get("marathiName") != null) product.setMarathiName(body.get("marathiName").toString());
        if (body.get("description") != null) product.setDescription(body.get("description").toString());
        if (body.get("scientificName") != null) product.setScientificName(body.get("scientificName").toString());
        if (body.get("botanicalFamily") != null) product.setBotanicalFamily(body.get("botanicalFamily").toString());
        if (body.get("unit") != null) product.setUnit(body.get("unit").toString());
        if (body.get("defaultUnitId") != null) {
            UUID unitId = UUID.fromString(body.get("defaultUnitId").toString());
            unitRepository.findById(unitId).ifPresent(u -> {
                product.setDefaultUnitId(u.getId());
                product.setUnit(u.getCode());
            });
        }
        if (body.get("isPerishable") != null) product.setPerishable(Boolean.parseBoolean(body.get("isPerishable").toString()));
        if (body.get("storageRequirements") != null) product.setStorageRequirements(body.get("storageRequirements").toString());
        if (body.get("shelfLifeInfo") != null) product.setShelfLifeInfo(body.get("shelfLifeInfo").toString());
        if (body.get("imageUrl") != null) product.setImageUrl(body.get("imageUrl").toString());
        product.setSeeded(false);
        product.setCreatedBy(principal.getId());
        product.setUpdatedBy(principal.getId());

        Product saved = productRepository.save(product);

        BigDecimal initialPrice = body.get("currentPrice") != null
                ? new BigDecimal(body.get("currentPrice").toString())
                : BigDecimal.ZERO;
        MarketPrice mp = new MarketPrice();
        mp.setProduct(saved);
        mp.setCurrentPrice(initialPrice);
        marketPriceRepository.save(mp);

        auditService.logEvent(principal.getId(), "PRODUCT_CREATED", "PRODUCT", saved.getId().toString(),
                "Created product " + saved.getProductCode() + " (" + saved.getCanonicalName() + ")", null);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Product created", ProductDto.fromEntity(saved, initialPrice, null)));
    }

    @PutMapping("/products/{id}")
    @Transactional
    @Operation(summary = "Update master product (productCode remains immutable)")
    public ResponseEntity<ApiResponse<ProductDto>> updateProduct(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody Map<String, Object> body) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found", HttpStatus.NOT_FOUND));

        if (body.get("name") != null) product.setName(body.get("name").toString().trim());
        if (body.get("marathiName") != null) product.setMarathiName(body.get("marathiName").toString());
        if (body.get("description") != null) product.setDescription(body.get("description").toString());
        if (body.get("scientificName") != null) product.setScientificName(body.get("scientificName").toString());
        if (body.get("botanicalFamily") != null) product.setBotanicalFamily(body.get("botanicalFamily").toString());
        if (body.get("storageRequirements") != null) product.setStorageRequirements(body.get("storageRequirements").toString());
        if (body.get("shelfLifeInfo") != null) product.setShelfLifeInfo(body.get("shelfLifeInfo").toString());
        if (body.get("imageUrl") != null) product.setImageUrl(body.get("imageUrl").toString());
        if (body.get("isPerishable") != null) product.setPerishable(Boolean.parseBoolean(body.get("isPerishable").toString()));
        product.setUpdatedBy(principal.getId());
        product.setUpdatedAt(Instant.now());

        Product saved = productRepository.save(product);
        MarketPrice mp = marketPriceRepository.findByProductId(saved.getId()).orElse(null);
        return ResponseEntity.ok(ApiResponse.ok("Product updated",
                ProductDto.fromEntity(saved, mp != null ? mp.getCurrentPrice() : BigDecimal.ZERO, mp != null ? mp.getPreviousPrice() : null)));
    }

    @PatchMapping("/products/{id}/status")
    @Transactional
    @Operation(summary = "Activate or deactivate master product without deleting historical records")
    public ResponseEntity<ApiResponse<ProductDto>> toggleProductStatus(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody Map<String, Boolean> body) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found", HttpStatus.NOT_FOUND));
        boolean active = Boolean.TRUE.equals(body.get("isAvailable"));
        product.setAvailable(active);
        product.setUpdatedBy(principal.getId());
        product.setUpdatedAt(Instant.now());
        Product saved = productRepository.save(product);

        auditService.logEvent(principal.getId(), active ? "PRODUCT_ACTIVATED" : "PRODUCT_DEACTIVATED",
                "PRODUCT", saved.getId().toString(), "Set isAvailable=" + active, null);
        return ResponseEntity.ok(ApiResponse.ok("Product status updated", ProductDto.fromEntity(saved, null, null)));
    }

    @PostMapping("/products/{id}/varieties")
    @Transactional
    @Operation(summary = "Add agricultural variety/cultivar to a master product")
    public ResponseEntity<ApiResponse<ProductVariety>> addVariety(
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        productRepository.findById(id)
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found", HttpStatus.NOT_FOUND));
        String varietyCode = body.get("varietyCode").trim().toUpperCase();
        if (varietyRepository.existsByProductIdAndVarietyCodeIgnoreCase(id, varietyCode)) {
            throw new ApiException("DUPLICATE_VARIETY_CODE", "Variety code already exists for this product", HttpStatus.CONFLICT);
        }
        ProductVariety v = new ProductVariety();
        v.setProductId(id);
        v.setVarietyCode(varietyCode);
        v.setVarietyName(body.get("varietyName").trim());
        v.setDescription(body.get("description"));
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Variety added", varietyRepository.save(v)));
    }

    @PostMapping("/products/{id}/variants")
    @Transactional
    @Operation(summary = "Add sellable SKU variant to a master product")
    public ResponseEntity<ApiResponse<ProductVariant>> addVariant(
            @PathVariable UUID id,
            @RequestBody Map<String, Object> body) {
        productRepository.findById(id)
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found", HttpStatus.NOT_FOUND));
        String sku = body.get("sku").toString().trim().toUpperCase();
        if (variantRepository.existsBySkuIgnoreCase(sku)) {
            throw new ApiException("DUPLICATE_SKU", "SKU already exists: " + sku, HttpStatus.CONFLICT);
        }
        ProductVariant variant = new ProductVariant();
        variant.setProductId(id);
        if (body.get("varietyId") != null) variant.setVarietyId(UUID.fromString(body.get("varietyId").toString()));
        variant.setSku(sku);
        variant.setVariantName(body.get("variantName").toString().trim());
        if (body.get("grade") != null) variant.setGrade(body.get("grade").toString());
        if (body.get("sizeLabel") != null) variant.setSizeLabel(body.get("sizeLabel").toString());
        if (body.get("packagingLabel") != null) variant.setPackagingLabel(body.get("packagingLabel").toString());
        if (body.get("weightValue") != null) variant.setWeightValue(new BigDecimal(body.get("weightValue").toString()));
        if (body.get("unitId") != null) variant.setUnitId(UUID.fromString(body.get("unitId").toString()));
        if (body.get("attributesJson") != null) variant.setAttributesJson(body.get("attributesJson").toString());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Variant added", variantRepository.save(variant)));
    }

    @PostMapping("/products/{id}/translations")
    @Transactional
    @Operation(summary = "Upsert multilingual translation (en, mr, hi) for a product")
    public ResponseEntity<ApiResponse<ProductTranslation>> upsertTranslation(
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        productRepository.findById(id)
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found", HttpStatus.NOT_FOUND));
        String lang = body.get("languageCode").trim().toLowerCase();
        ProductTranslation tr = translationRepository.findByProductIdAndLanguageCode(id, lang)
                .orElseGet(ProductTranslation::new);
        tr.setProductId(id);
        tr.setLanguageCode(lang);
        tr.setLocalizedName(body.get("localizedName").trim());
        tr.setLocalizedDescription(body.get("localizedDescription"));
        tr.setSearchAliases(body.get("searchAliases"));
        tr.setUpdatedAt(Instant.now());
        return ResponseEntity.ok(ApiResponse.ok("Translation saved", translationRepository.save(tr)));
    }
}
