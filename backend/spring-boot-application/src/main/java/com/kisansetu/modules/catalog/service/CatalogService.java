package com.kisansetu.modules.catalog.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.catalog.dto.CategoryDto;
import com.kisansetu.modules.catalog.entity.ProductCategory;
import com.kisansetu.modules.catalog.repository.ProductCategoryRepository;
import com.kisansetu.modules.pricing.entity.MarketPrice;
import com.kisansetu.modules.pricing.repository.MarketPriceRepository;
import com.kisansetu.modules.product.dto.ProductDto;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.product.repository.ProductRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class CatalogService {

    private final ProductCategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final MarketPriceRepository marketPriceRepository;

    public CatalogService(ProductCategoryRepository categoryRepository,
                          ProductRepository productRepository,
                          MarketPriceRepository marketPriceRepository) {
        this.categoryRepository = categoryRepository;
        this.productRepository = productRepository;
        this.marketPriceRepository = marketPriceRepository;
    }

    @Transactional(readOnly = true)
    public List<CategoryDto> getCategories() {
        return categoryRepository.findByIsActiveTrueOrderByDisplayOrderAsc()
                .stream()
                .map(category -> {
                    long count = productRepository.findByCategoryIdAndIsAvailableTrue(category.getId()).size();
                    return CategoryDto.fromEntity(category, count);
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ProductDto> getProducts(UUID categoryId, String query) {
        List<Product> products;
        if (query != null && !query.trim().isEmpty()) {
            products = productRepository.searchProducts(query.trim());
        } else if (categoryId != null) {
            products = productRepository.findByCategoryIdAndIsAvailableTrue(categoryId);
        } else {
            products = productRepository.findByIsAvailableTrue();
        }

        return products.stream().map(this::mapProductWithPrice).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ProductDto getProduct(UUID productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new ApiException("PRODUCT_NOT_FOUND", "Product not found", HttpStatus.NOT_FOUND));
        return mapProductWithPrice(product);
    }

    private ProductDto mapProductWithPrice(Product product) {
        MarketPrice mp = marketPriceRepository.findByProductId(product.getId()).orElse(null);
        BigDecimal currentPrice = mp != null ? mp.getCurrentPrice() : BigDecimal.valueOf(30.0);
        BigDecimal prevPrice = mp != null ? mp.getPreviousPrice() : null;
        return ProductDto.fromEntity(product, currentPrice, prevPrice);
    }
}
