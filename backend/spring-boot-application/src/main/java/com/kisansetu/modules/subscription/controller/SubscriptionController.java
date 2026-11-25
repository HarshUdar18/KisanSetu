package com.kisansetu.modules.subscription.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.subscription.dto.CreateSubscriptionRequest;
import com.kisansetu.modules.subscription.dto.SubscriptionDto;
import com.kisansetu.modules.subscription.service.SubscriptionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/subscriptions")
@Tag(name = "Customer Subscriptions", description = "Recurring agricultural produce fulfillment scheduling")
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    public SubscriptionController(SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    @GetMapping
    @Operation(summary = "Get user subscriptions")
    public ResponseEntity<ApiResponse<List<SubscriptionDto>>> getSubscriptions(@AuthenticationPrincipal UserPrincipal principal) {
        List<SubscriptionDto> subs = subscriptionService.getSubscriptions(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Subscriptions retrieved", subs));
    }

    @PostMapping
    @Operation(summary = "Create recurring produce subscription from weekly plan")
    public ResponseEntity<ApiResponse<SubscriptionDto>> createSubscription(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateSubscriptionRequest request) {
        SubscriptionDto sub = subscriptionService.createSubscription(principal.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Subscription confirmed", sub));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get subscription details")
    public ResponseEntity<ApiResponse<SubscriptionDto>> getSubscription(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        SubscriptionDto sub = subscriptionService.getSubscription(principal.getId(), id);
        return ResponseEntity.ok(ApiResponse.ok("Subscription retrieved", sub));
    }
}
