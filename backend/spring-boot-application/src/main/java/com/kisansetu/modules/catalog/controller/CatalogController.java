package com.kisansetu.modules.catalog.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.catalog.dto.CategoryDto;
import com.kisansetu.modules.catalog.service.CatalogService;
import com.kisansetu.modules.product.dto.ProductDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Catalog & Products", description = "Public catalog browsing, categories, search, and dynamic pricing inspection")
public class CatalogController {

    private final CatalogService catalogService;

    public CatalogController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping("/categories")
    @Operation(summary = "Get active product categories with item counts")
    public ResponseEntity<ApiResponse<List<CategoryDto>>> getCategories() {
        List<CategoryDto> categories = catalogService.getCategories();
        return ResponseEntity.ok(ApiResponse.ok("Categories retrieved", categories));
    }

    @GetMapping("/products")
    @Operation(summary = "Browse products with category filter and search")
    public ResponseEntity<ApiResponse<List<ProductDto>>> getProducts(
            @RequestParam(required = false) UUID categoryId,
            @RequestParam(required = false) String search) {
        List<ProductDto> products = catalogService.getProducts(categoryId, search);
        return ResponseEntity.ok(ApiResponse.ok("Products retrieved", products));
    }

    @GetMapping("/products/{id}")
    @Operation(summary = "Get single product detail with authoritative market price")
    public ResponseEntity<ApiResponse<ProductDto>> getProduct(@PathVariable UUID id) {
        ProductDto product = catalogService.getProduct(id);
        return ResponseEntity.ok(ApiResponse.ok("Product retrieved", product));
    }
}
