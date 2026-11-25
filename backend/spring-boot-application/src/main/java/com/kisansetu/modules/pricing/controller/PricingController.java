package com.kisansetu.modules.pricing.controller;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.pricing.dto.PriceDto;
import com.kisansetu.modules.pricing.entity.MarketPrice;
import com.kisansetu.modules.pricing.entity.PriceHistory;
import com.kisansetu.modules.pricing.repository.MarketPriceRepository;
import com.kisansetu.modules.pricing.repository.PriceHistoryRepository;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.product.repository.ProductRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/prices")
@Tag(name = "Market Pricing", description = "Current applicable agricultural market prices and historical price records")
public class PricingController {

    private final MarketPriceRepository marketPriceRepository;
    private final PriceHistoryRepository priceHistoryRepository;
    private final ProductRepository productRepository;

    public PricingController(MarketPriceRepository marketPriceRepository,
                             PriceHistoryRepository priceHistoryRepository,
                             ProductRepository productRepository) {
        this.marketPriceRepository = marketPriceRepository;
        this.priceHistoryRepository = priceHistoryRepository;
        this.productRepository = productRepository;
    }

    @GetMapping("/{productId}")
    @Operation(summary = "Retrieve current applicable market price for a product", description = "Returns the authoritative market rate, unit, and last price change.")
    public ResponseEntity<ApiResponse<PriceDto>> getPriceByProductId(@PathVariable UUID productId) {
        MarketPrice marketPrice = marketPriceRepository.findByProductId(productId)
                .orElseGet(() -> {
                    Product product = productRepository.findById(productId)
                            .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found: " + productId, HttpStatus.NOT_FOUND));
                    // Return a default price entry if none explicitly configured
                    return new MarketPrice(product, new BigDecimal("30.00"), new BigDecimal("28.00"));
                });

        return ResponseEntity.ok(ApiResponse.ok("Market price retrieved", PriceDto.fromEntity(marketPrice)));
    }

    @GetMapping
    @Operation(summary = "List all current applicable market prices")
    public ResponseEntity<ApiResponse<List<PriceDto>>> getAllPrices() {
        List<PriceDto> prices = marketPriceRepository.findAll().stream()
                .map(PriceDto::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok("All market prices retrieved", prices));
    }

    @PutMapping("/{productId}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update product market price (Admin only)", description = "Updates the authoritative market rate and appends a price history audit.")
    public ResponseEntity<ApiResponse<PriceDto>> updatePrice(
            @PathVariable UUID productId,
            @RequestBody Map<String, BigDecimal> request) {
        BigDecimal newPrice = request.get("currentPrice");
        if (newPrice == null || newPrice.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApiException("INVALID_PRICE", "currentPrice must be greater than zero", HttpStatus.BAD_REQUEST);
        }

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found: " + productId, HttpStatus.NOT_FOUND));

        MarketPrice marketPrice = marketPriceRepository.findByProductId(productId)
                .orElseGet(() -> new MarketPrice(product, newPrice, newPrice));

        BigDecimal oldPrice = marketPrice.getCurrentPrice();
        marketPrice.setPreviousPrice(oldPrice);
        marketPrice.setCurrentPrice(newPrice);
        marketPrice.setEffectiveFrom(Instant.now());
        MarketPrice saved = marketPriceRepository.save(marketPrice);

        // Record history
        priceHistoryRepository.save(new PriceHistory(product, newPrice, Instant.now()));

        return ResponseEntity.ok(ApiResponse.ok("Market price updated successfully", PriceDto.fromEntity(saved)));
    }
}
