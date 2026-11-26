package com.kisansetu.product.controller;

import com.kisansetu.product.entity.CategoryEntity;
import com.kisansetu.product.entity.MarketPriceEntity;
import com.kisansetu.product.entity.ProductEntity;
import com.kisansetu.product.repository.CategoryRepo;
import com.kisansetu.product.repository.MarketPriceRepo;
import com.kisansetu.product.repository.ProductRepo;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

@RestController
@RequestMapping("/api/v1")
public class ProductCatalogController {

    private final CategoryRepo categoryRepo;
    private final ProductRepo productRepo;
    private final MarketPriceRepo priceRepo;

    public ProductCatalogController(CategoryRepo categoryRepo, ProductRepo productRepo, MarketPriceRepo priceRepo) {
        this.categoryRepo = categoryRepo;
        this.productRepo = productRepo;
        this.priceRepo = priceRepo;
    }

    @GetMapping("/categories")
    public ResponseEntity<Map<String, Object>> listCategories() {
        return ResponseEntity.ok(Map.of("success", true, "data", categoryRepo.findByIsActiveTrueOrderByDisplayOrderAsc()));
    }

    @GetMapping("/admin/categories")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> adminCategories() {
        return ResponseEntity.ok(Map.of("success", true, "data", categoryRepo.findAll()));
    }

    @PostMapping("/admin/categories")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> createCategory(@RequestBody CategoryEntity cat) {
        CategoryEntity saved = categoryRepo.save(cat);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("success", true, "data", saved));
    }

    @GetMapping("/products")
    public ResponseEntity<Map<String, Object>> listProducts(@RequestParam(required = false) UUID categoryId) {
        List<ProductEntity> products = categoryId != null
                ? productRepo.findByCategoryIdAndIsAvailableTrue(categoryId)
                : productRepo.findByIsAvailableTrue();
        return ResponseEntity.ok(Map.of("success", true, "data", products));
    }

    @GetMapping("/products/{id}")
    public ResponseEntity<Map<String, Object>> getProduct(@PathVariable UUID id) {
        ProductEntity p = productRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));
        return ResponseEntity.ok(Map.of("success", true, "data", p));
    }

    @PostMapping("/admin/products")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> createProduct(@RequestBody Map<String, Object> body) {
        UUID catId = UUID.fromString(body.get("categoryId").toString());
        CategoryEntity cat = categoryRepo.findById(catId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found"));
        ProductEntity p = new ProductEntity();
        p.setCategory(cat);
        p.setName(body.get("name").toString());
        p.setUnit(body.getOrDefault("unit", "kg").toString());
        ProductEntity saved = productRepo.save(p);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("success", true, "data", saved));
    }

    @GetMapping("/prices/{productId}")
    public ResponseEntity<Map<String, Object>> getPrice(@PathVariable UUID productId) {
        MarketPriceEntity mp = priceRepo.findByProductId(productId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Price not found"));
        return ResponseEntity.ok(Map.of("success", true, "data", mp));
    }

    @PutMapping("/prices/{productId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> updatePrice(@PathVariable UUID productId, @RequestBody Map<String, Object> body) {
        BigDecimal newPrice = new BigDecimal(body.get("newPrice").toString());
        MarketPriceEntity mp = priceRepo.findByProductId(productId).orElseGet(() -> {
            MarketPriceEntity n = new MarketPriceEntity();
            n.setProductId(productId);
            return n;
        });
        mp.setPreviousPrice(mp.getCurrentPrice());
        mp.setCurrentPrice(newPrice);
        mp.setEffectiveFrom(Instant.now());
        return ResponseEntity.ok(Map.of("success", true, "data", priceRepo.save(mp)));
    }
}
