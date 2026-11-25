package com.kisansetu.modules.cart.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.cart.dto.*;
import com.kisansetu.modules.cart.service.WeeklyCartService;
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
@RequestMapping("/api/v1/weekly-carts")
@Tag(name = "Weekly Planner Carts", description = "Multi-day meal and vegetable planning with strictly enforced single modification rule")
public class WeeklyCartController {

    private final WeeklyCartService weeklyCartService;

    public WeeklyCartController(WeeklyCartService weeklyCartService) {
        this.weeklyCartService = weeklyCartService;
    }

    @GetMapping
    @Operation(summary = "Get user weekly carts")
    public ResponseEntity<ApiResponse<List<WeeklyCartDto>>> getWeeklyCarts(@AuthenticationPrincipal UserPrincipal principal) {
        List<WeeklyCartDto> carts = weeklyCartService.getWeeklyCarts(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Weekly carts retrieved", carts));
    }

    @PostMapping
    @Operation(summary = "Create new weekly produce plan")
    public ResponseEntity<ApiResponse<WeeklyCartDto>> createWeeklyCart(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateWeeklyCartRequest request) {
        WeeklyCartDto cart = weeklyCartService.createWeeklyCart(principal.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Weekly cart created", cart));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get weekly cart details by ID")
    public ResponseEntity<ApiResponse<WeeklyCartDto>> getWeeklyCart(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        WeeklyCartDto cart = weeklyCartService.getWeeklyCart(principal.getId(), id);
        return ResponseEntity.ok(ApiResponse.ok("Weekly cart retrieved", cart));
    }

    @PutMapping("/{id}/days")
    @Operation(summary = "Assign or update items for a specific day of the week")
    public ResponseEntity<ApiResponse<WeeklyCartDto>> assignDayItems(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @Valid @RequestBody AssignWeeklyCartDayRequest request) {
        WeeklyCartDto cart = weeklyCartService.assignDayItems(principal.getId(), id, request);
        return ResponseEntity.ok(ApiResponse.ok("Day schedule updated", cart));
    }

    @PostMapping("/{id}/submit")
    @Operation(summary = "Submit weekly cart (locks initial draft and initializes modification count to 0)")
    public ResponseEntity<ApiResponse<WeeklyCartDto>> submitWeeklyCart(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id) {
        WeeklyCartDto cart = weeklyCartService.submitWeeklyCart(principal.getId(), id);
        return ResponseEntity.ok(ApiResponse.ok("Weekly cart submitted successfully", cart));
    }

    @PostMapping("/{id}/modify")
    @Operation(summary = "Modify submitted weekly cart (ONLY ONCE allowed; subsequent requests rejected with 409)")
    public ResponseEntity<ApiResponse<WeeklyCartDto>> modifyWeeklyCart(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable UUID id,
            @RequestBody List<AssignWeeklyCartDayRequest> dayRequests) {
        WeeklyCartDto cart = weeklyCartService.modifyWeeklyCart(principal.getId(), id, dayRequests);
        return ResponseEntity.ok(ApiResponse.ok("Weekly cart modified and permanently locked", cart));
    }
}
