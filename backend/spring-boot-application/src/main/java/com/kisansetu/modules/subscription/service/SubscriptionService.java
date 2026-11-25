package com.kisansetu.modules.subscription.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.cart.entity.WeeklyCart;
import com.kisansetu.modules.cart.entity.WeeklyCartDay;
import com.kisansetu.modules.cart.entity.WeeklyCartItem;
import com.kisansetu.modules.cart.repository.WeeklyCartRepository;
import com.kisansetu.modules.customer.dto.AddressDto;
import com.kisansetu.modules.customer.entity.Address;
import com.kisansetu.modules.customer.repository.AddressRepository;
import com.kisansetu.modules.pricing.entity.MarketPrice;
import com.kisansetu.modules.pricing.repository.MarketPriceRepository;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.servicearea.entity.ServiceArea;
import com.kisansetu.modules.servicearea.repository.ServiceAreaRepository;
import com.kisansetu.modules.subscription.dto.CreateSubscriptionRequest;
import com.kisansetu.modules.subscription.dto.SubscriptionDto;
import com.kisansetu.modules.subscription.dto.SubscriptionItemDto;
import com.kisansetu.modules.subscription.entity.Subscription;
import com.kisansetu.modules.subscription.entity.SubscriptionItem;
import com.kisansetu.modules.subscription.repository.SubscriptionRepository;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class SubscriptionService {

    private final SubscriptionRepository subscriptionRepository;
    private final WeeklyCartRepository weeklyCartRepository;
    private final AddressRepository addressRepository;
    private final ServiceAreaRepository serviceAreaRepository;
    private final UserRepository userRepository;
    private final MarketPriceRepository marketPriceRepository;

    public SubscriptionService(SubscriptionRepository subscriptionRepository,
                               WeeklyCartRepository weeklyCartRepository,
                               AddressRepository addressRepository,
                               ServiceAreaRepository serviceAreaRepository,
                               UserRepository userRepository,
                               MarketPriceRepository marketPriceRepository) {
        this.subscriptionRepository = subscriptionRepository;
        this.weeklyCartRepository = weeklyCartRepository;
        this.addressRepository = addressRepository;
        this.serviceAreaRepository = serviceAreaRepository;
        this.userRepository = userRepository;
        this.marketPriceRepository = marketPriceRepository;
    }

    @Transactional(readOnly = true)
    public List<SubscriptionDto> getSubscriptions(UUID userId) {
        return subscriptionRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public SubscriptionDto getSubscription(UUID userId, UUID id) {
        Subscription subscription = subscriptionRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ApiException("SUBSCRIPTION_NOT_FOUND", "Subscription not found", HttpStatus.NOT_FOUND));
        return mapToDto(subscription);
    }

    @Transactional
    public SubscriptionDto createSubscription(UUID userId, CreateSubscriptionRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("USER_NOT_FOUND", "User not found", HttpStatus.NOT_FOUND));

        Address address = addressRepository.findByIdAndUserId(request.getAddressId(), userId)
                .orElseThrow(() -> new ApiException("ADDRESS_NOT_FOUND", "Address not found or unauthorized", HttpStatus.NOT_FOUND));

        ServiceArea serviceArea = serviceAreaRepository.findByPincode(address.getPincode())
                .orElseThrow(() -> new ApiException("OUTSIDE_SERVICE_AREA", "Delivery address pincode is outside active service zones (Shivajinagar/Akurdi)", HttpStatus.BAD_REQUEST));

        WeeklyCart weeklyCart = null;
        if (request.getWeeklyCartId() != null) {
            weeklyCart = weeklyCartRepository.findByIdAndUserId(request.getWeeklyCartId(), userId)
                    .orElse(null);
        }

        Subscription subscription = new Subscription(
                user,
                weeklyCart,
                serviceArea,
                address,
                request.getFrequency() != null ? request.getFrequency() : "WEEKLY",
                request.getStartDate(),
                request.getDeliveryPreferences()
        );

        if (weeklyCart != null && weeklyCart.getDays() != null) {
            for (WeeklyCartDay day : weeklyCart.getDays()) {
                for (WeeklyCartItem item : day.getItems()) {
                    SubscriptionItem subItem = new SubscriptionItem(subscription, item.getProduct(), day.getDayOfWeek(), item.getQuantity());
                    subscription.getItems().add(subItem);
                }
            }
        }

        Subscription saved = subscriptionRepository.save(subscription);
        return mapToDto(saved);
    }

    private SubscriptionDto mapToDto(Subscription s) {
        SubscriptionDto dto = new SubscriptionDto();
        dto.setId(s.getId());
        dto.setWeeklyCartId(s.getWeeklyCart() != null ? s.getWeeklyCart().getId() : null);
        dto.setFrequency(s.getFrequency());
        dto.setStartDate(s.getStartDate());
        dto.setStatus(s.getStatus());
        dto.setDeliveryPreferences(s.getDeliveryPreferences());

        if (s.getAddress() != null) {
            dto.setAddress(AddressDto.fromEntity(s.getAddress()));
        }

        List<SubscriptionItemDto> itemDtos = new ArrayList<>();
        if (s.getItems() != null) {
            for (SubscriptionItem item : s.getItems()) {
                Product p = item.getProduct();
                MarketPrice mp = marketPriceRepository.findByProductId(p.getId()).orElse(null);
                BigDecimal price = mp != null ? mp.getCurrentPrice() : BigDecimal.valueOf(30.0);

                itemDtos.add(new SubscriptionItemDto(
                        item.getId(),
                        p.getId(),
                        p.getName(),
                        p.getUnit(),
                        item.getDayOfWeek(),
                        item.getQuantity(),
                        price
                ));
            }
        }
        dto.setItems(itemDtos);
        return dto;
    }
}
