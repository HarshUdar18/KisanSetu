package com.kisansetu.pricing;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.catalog.entity.ProductCategory;
import com.kisansetu.modules.pricing.controller.PricingController;
import com.kisansetu.modules.pricing.dto.PriceDto;
import com.kisansetu.modules.pricing.entity.MarketPrice;
import com.kisansetu.modules.pricing.repository.MarketPriceRepository;
import com.kisansetu.modules.pricing.repository.PriceHistoryRepository;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.product.repository.ProductRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.http.ResponseEntity;

import java.math.BigDecimal;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

class PricingControllerTest {

    private MarketPriceRepository marketPriceRepository;
    private PriceHistoryRepository priceHistoryRepository;
    private ProductRepository productRepository;
    private PricingController pricingController;

    private Product product;
    private MarketPrice marketPrice;

    @BeforeEach
    void setUp() {
        marketPriceRepository = Mockito.mock(MarketPriceRepository.class);
        priceHistoryRepository = Mockito.mock(PriceHistoryRepository.class);
        productRepository = Mockito.mock(ProductRepository.class);

        pricingController = new PricingController(marketPriceRepository, priceHistoryRepository, productRepository);

        ProductCategory category = new ProductCategory("Vegetables", "VEGETABLES", "Fresh vegetables", null, 1);
        product = new Product(category, "Desi Tomato", "टोमॅटो", "Fresh tomatoes", "kg", null);
        product.setId(UUID.randomUUID());

        marketPrice = new MarketPrice(product, new BigDecimal("36.00"), new BigDecimal("34.00"));
        marketPrice.setId(UUID.randomUUID());
    }

    @Test
    @DisplayName("Retrieve current price returns active market price")
    void testGetCurrentPriceWithMarketPrice() {
        when(marketPriceRepository.findByProductId(product.getId()))
                .thenReturn(Optional.of(marketPrice));

        ResponseEntity<ApiResponse<PriceDto>> response = pricingController.getPriceByProductId(product.getId());

        assertNotNull(response.getBody());
        assertTrue(response.getBody().isSuccess());
        PriceDto dto = response.getBody().getData();
        assertEquals(product.getId(), dto.getProductId());
        assertEquals(new BigDecimal("36.00"), dto.getCurrentPrice());
        assertEquals("kg", dto.getUnit());
    }

    @Test
    @DisplayName("Retrieve current price provides default fallback when none explicitly set")
    void testGetCurrentPriceFallback() {
        when(marketPriceRepository.findByProductId(product.getId()))
                .thenReturn(Optional.empty());
        when(productRepository.findById(product.getId()))
                .thenReturn(Optional.of(product));

        ResponseEntity<ApiResponse<PriceDto>> response = pricingController.getPriceByProductId(product.getId());

        assertNotNull(response.getBody());
        PriceDto dto = response.getBody().getData();
        assertEquals(0, new BigDecimal("30.00").compareTo(dto.getCurrentPrice()));
    }

    @Test
    @DisplayName("Admin can update market price")
    void testUpdateMarketPriceSuccess() {
        Map<String, BigDecimal> request = Map.of("currentPrice", new BigDecimal("38.00"));

        when(productRepository.findById(product.getId())).thenReturn(Optional.of(product));
        when(marketPriceRepository.findByProductId(product.getId())).thenReturn(Optional.of(marketPrice));
        when(marketPriceRepository.save(any(MarketPrice.class))).thenAnswer(invocation -> invocation.getArgument(0));

        ResponseEntity<ApiResponse<PriceDto>> response = pricingController.updatePrice(product.getId(), request);

        assertNotNull(response.getBody());
        assertTrue(response.getBody().isSuccess());
        assertEquals(new BigDecimal("38.00"), response.getBody().getData().getCurrentPrice());
    }
}
