package com.kisansetu.modules.operations.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.operations.entity.*;
import com.kisansetu.modules.operations.repository.*;
import com.kisansetu.modules.subscription.dto.SubscriptionDto;
import com.kisansetu.modules.subscription.repository.SubscriptionRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Store, Schemes, Weather & Admin Governance", description = "Farmer Store, Govt Schemes, Weather abstraction, Admin Subscriptions/Coupons, Stock Movements")
public class PlatformCatalogAdminController {

    private final FarmerStoreProductRepository storeProductRepo;
    private final FarmerStoreOrderRepository storeOrderRepo;
    private final GovtSchemeRepository schemeRepo;
    private final SubscriptionRepository subscriptionRepo;
    private final CouponRepository couponRepo;
    private final StockMovementRepository stockMovementRepo;

    @Value("${OPENWEATHER_API_KEY:}")
    private String openWeatherApiKey;

    public PlatformCatalogAdminController(FarmerStoreProductRepository storeProductRepo,
                                          FarmerStoreOrderRepository storeOrderRepo,
                                          GovtSchemeRepository schemeRepo,
                                          SubscriptionRepository subscriptionRepo,
                                          CouponRepository couponRepo,
                                          StockMovementRepository stockMovementRepo) {
        this.storeProductRepo = storeProductRepo;
        this.storeOrderRepo = storeOrderRepo;
        this.schemeRepo = schemeRepo;
        this.subscriptionRepo = subscriptionRepo;
        this.couponRepo = couponRepo;
        this.stockMovementRepo = stockMovementRepo;
    }

    // --- Farmer Store ---
    @GetMapping("/farmer-store/products")
    public ResponseEntity<ApiResponse<List<FarmerStoreProduct>>> listStoreProducts() {
        return ResponseEntity.ok(ApiResponse.ok("Farmer store products retrieved", storeProductRepo.findByIsAvailableTrue()));
    }

    @PostMapping("/admin/farmer-store/products")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<FarmerStoreProduct>> createStoreProduct(@RequestBody FarmerStoreProduct p) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Store product created", storeProductRepo.save(p)));
    }

    @PostMapping("/farmer-store/orders")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<FarmerStoreOrder>> placeStoreOrder(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody Map<String, Object> body) {
        FarmerStoreOrder order = new FarmerStoreOrder();
        order.setFarmerId(principal != null ? principal.getId() : UUID.randomUUID());
        order.setTotalAmount(new BigDecimal(body.get("totalAmount").toString()));
        order.setItemsJson(body.getOrDefault("itemsJson", "[]").toString());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Store order placed", storeOrderRepo.save(order)));
    }

    @GetMapping("/farmer-store/orders")
    @PreAuthorize("hasRole('FARMER') or hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<FarmerStoreOrder>>> listStoreOrders(@AuthenticationPrincipal UserPrincipal principal) {
        List<FarmerStoreOrder> orders = principal != null
                ? storeOrderRepo.findByFarmerIdOrderByCreatedAtDesc(principal.getId())
                : storeOrderRepo.findAll();
        return ResponseEntity.ok(ApiResponse.ok("Store orders retrieved", orders));
    }

    // --- Government Schemes ---
    @GetMapping("/schemes")
    public ResponseEntity<ApiResponse<List<GovtScheme>>> listSchemes() {
        return ResponseEntity.ok(ApiResponse.ok("Government schemes retrieved", schemeRepo.findByIsActiveTrue()));
    }

    @PostMapping("/admin/schemes")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<GovtScheme>> createScheme(@RequestBody GovtScheme s) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Scheme created", schemeRepo.save(s)));
    }

    // --- Weather Abstraction (Never fabricates data when key is unconfigured) ---
    @GetMapping("/weather")
    @Operation(summary = "Get farm weather status (requires OPENWEATHER_API_KEY)")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getWeather(
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lon) {
        if (!StringUtils.hasText(openWeatherApiKey)) {
            return ResponseEntity.ok(ApiResponse.ok("External weather provider not configured", Map.of(
                    "available", false,
                    "reason", "OPENWEATHER_API_KEY is not configured on the backend."
            )));
        }
        return ResponseEntity.ok(ApiResponse.ok("Weather provider configured", Map.of(
                "available", true,
                "lat", lat != null ? lat : 0.0,
                "lon", lon != null ? lon : 0.0
        )));
    }

    // --- Admin Subscriptions, Coupons & Stock Movements ---
    @GetMapping("/admin/subscriptions")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<SubscriptionDto>>> adminListSubscriptions() {
        List<SubscriptionDto> list = subscriptionRepo.findAll().stream().map(s -> {
            SubscriptionDto dto = new SubscriptionDto();
            dto.setId(s.getId());
            dto.setFrequency(s.getFrequency());
            dto.setStartDate(s.getStartDate());
            dto.setStatus(s.getStatus());
            dto.setDeliveryPreferences(s.getDeliveryPreferences());
            return dto;
        }).toList();
        return ResponseEntity.ok(ApiResponse.ok("Subscriptions retrieved", list));
    }

    @PostMapping("/admin/coupons")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Coupon>> createCoupon(@RequestBody Coupon coupon) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Coupon created", couponRepo.save(coupon)));
    }

    @GetMapping("/inventory/movements")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<StockMovement>>> listStockMovements() {
        return ResponseEntity.ok(ApiResponse.ok("Stock movements retrieved", stockMovementRepo.findAllByOrderByCreatedAtDesc()));
    }
}
