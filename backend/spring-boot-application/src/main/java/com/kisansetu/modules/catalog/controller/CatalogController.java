package com.kisansetu.modules.catalog.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.catalog.dto.CategoryDto;
import com.kisansetu.modules.catalog.service.CatalogService;
import com.kisansetu.modules.farmer.FarmerListingService;
import com.kisansetu.modules.farmer.dto.FarmerListingDto;
import com.kisansetu.modules.product.dto.ProductDto;
import com.kisansetu.modules.product.entity.ProductTranslation;
import com.kisansetu.modules.product.entity.ProductUnit;
import com.kisansetu.modules.product.entity.ProductVariant;
import com.kisansetu.modules.product.entity.ProductVariety;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Catalog & Products", description = "Public catalog browsing, categories, search, and dynamic pricing inspection")
public class CatalogController {

    private final CatalogService catalogService;
    private final FarmerListingService farmerListingService;

    public CatalogController(CatalogService catalogService, FarmerListingService farmerListingService) {
        this.catalogService = catalogService;
        this.farmerListingService = farmerListingService;
    }

    @GetMapping("/categories")
    @Operation(summary = "Get active product categories with item counts")
    public ResponseEntity<ApiResponse<List<CategoryDto>>> getCategories() {
        List<CategoryDto> categories = catalogService.getCategories();
        return ResponseEntity.ok(ApiResponse.ok("Categories retrieved", categories));
    }

    @GetMapping("/categories/{id}")
    @Operation(summary = "Get category by ID")
    public ResponseEntity<ApiResponse<CategoryDto>> getCategory(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Category retrieved", catalogService.getCategory(id)));
    }

    @GetMapping("/products")
    @Operation(summary = "Browse products with category filter, search, and stock-first sorting")
    public ResponseEntity<ApiResponse<List<ProductDto>>> getProducts(
            @RequestParam(required = false) UUID categoryId,
            @RequestParam(required = false) String search,
            @RequestParam(required = false, defaultValue = "stock_first") String sortBy,
            @RequestParam(required = false) Boolean inStockOnly) {
        List<ProductDto> products = catalogService.getProducts(categoryId, search, sortBy, inStockOnly);
        return ResponseEntity.ok(ApiResponse.ok("Products retrieved", products));
    }

    @GetMapping("/products/{id}/listings")
    @Operation(summary = "List individual farmer produce listings for a master product")
    public ResponseEntity<ApiResponse<List<FarmerListingDto>>> getProductListings(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Farmer listings retrieved", farmerListingService.getListingsByProduct(id)));
    }

    @GetMapping("/products/{id}")
    @Operation(summary = "Get single product detail with authoritative market price")
    public ResponseEntity<ApiResponse<ProductDto>> getProduct(@PathVariable UUID id) {
        ProductDto product = catalogService.getProduct(id);
        return ResponseEntity.ok(ApiResponse.ok("Product retrieved", product));
    }

    @GetMapping("/products/code/{productCode}")
    @Operation(summary = "Get single product by immutable product code")
    public ResponseEntity<ApiResponse<ProductDto>> getProductByCode(@PathVariable String productCode) {
        return ResponseEntity.ok(ApiResponse.ok("Product retrieved", catalogService.getProductByCode(productCode)));
    }

    @GetMapping("/products/{id}/varieties")
    @Operation(summary = "List agricultural varieties (cultivars) for a product")
    public ResponseEntity<ApiResponse<List<ProductVariety>>> getVarieties(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Varieties retrieved", catalogService.getVarieties(id)));
    }

    @GetMapping("/products/{id}/variants")
    @Operation(summary = "List sellable SKU variants for a product")
    public ResponseEntity<ApiResponse<List<ProductVariant>>> getVariants(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Variants retrieved", catalogService.getVariants(id)));
    }

    @GetMapping("/products/{id}/translations")
    @Operation(summary = "List multilingual translations (en, mr, hi) for a product")
    public ResponseEntity<ApiResponse<List<ProductTranslation>>> getTranslations(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Translations retrieved", catalogService.getTranslations(id)));
    }

    @GetMapping("/units")
    @Operation(summary = "List active measurement units")
    public ResponseEntity<ApiResponse<List<ProductUnit>>> getUnits() {
        return ResponseEntity.ok(ApiResponse.ok("Units retrieved", catalogService.getUnits()));
    }

    @GetMapping("/units/convert")
    @Operation(summary = "Convert quantity between units of the same category")
    public ResponseEntity<ApiResponse<Map<String, Object>>> convertUnit(
            @RequestParam String fromCode,
            @RequestParam String toCode,
            @RequestParam BigDecimal quantity) {
        return ResponseEntity.ok(ApiResponse.ok("Unit converted", catalogService.convertUnit(fromCode, toCode, quantity)));
    }
}
