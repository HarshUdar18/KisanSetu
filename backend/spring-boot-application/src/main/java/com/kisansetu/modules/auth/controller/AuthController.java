package com.kisansetu.modules.auth.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.common.security.UserPrincipal;
import com.kisansetu.modules.auth.dto.*;
import com.kisansetu.modules.auth.provider.AuthenticationProvider;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Authentication", description = "Registration, password login, mock OTP verification, and session logout")
public class AuthController {

    private final AuthenticationProvider authenticationProvider;

    public AuthController(AuthenticationProvider authenticationProvider) {
        this.authenticationProvider = authenticationProvider;
    }

    @PostMapping("/register")
    @Operation(summary = "Register user (Customer or Farmer)", description = "Creates a unified user account, assigns the specified role, and initializes the profile.")
    public ResponseEntity<ApiResponse<AuthResult>> register(@Valid @RequestBody RegisterUserRequest request) {
        AuthResult result = authenticationProvider.registerUser(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created("Registration successful", result));
    }

    @PostMapping("/login")
    @Operation(summary = "Login with phone/email and password", description = "Authenticates user credentials and issues a signed JWT token containing authorized roles.")
    public ResponseEntity<ApiResponse<AuthResult>> login(@Valid @RequestBody LoginRequest request) {
        AuthResult result = authenticationProvider.loginWithPassword(request.getIdentifier(), request.getPassword());
        return ResponseEntity.ok(ApiResponse.ok("Login successful", result));
    }

    @GetMapping("/capabilities")
    @Operation(summary = "Get supported authentication capabilities")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getCapabilities() {
        return ResponseEntity.ok(ApiResponse.ok("Auth capabilities retrieved", authenticationProvider.getCapabilities()));
    }

    @PostMapping({"/send-otp", "/request-otp"})
    @Operation(summary = "Send OTP to mobile phone or email")
    public ResponseEntity<ApiResponse<OtpChallenge>> sendOtp(@RequestBody SendOtpRequest request) {
        OtpChallenge challenge = authenticationProvider.sendOtp(request.resolveIdentifier());
        return ResponseEntity.ok(ApiResponse.ok("OTP dispatched", challenge));
    }

    @PostMapping("/verify-otp")
    @Operation(summary = "Verify OTP and login or auto-create account")
    public ResponseEntity<ApiResponse<AuthResult>> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        AuthResult result = authenticationProvider.verifyOtp(request.resolveIdentifier(), request.getOtp(), request.getRole());
        return ResponseEntity.ok(ApiResponse.ok("OTP verification successful", result));
    }

    @PostMapping("/google")
    @Operation(summary = "Verify Google ID token and login or auto-create customer account")
    public ResponseEntity<ApiResponse<AuthResult>> googleLogin(@RequestBody Map<String, String> body) {
        AuthResult result = authenticationProvider.loginWithGoogle(body.get("idToken"));
        return ResponseEntity.ok(ApiResponse.ok("Google authentication successful", result));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Rotate refresh token and issue new JWT access token")
    public ResponseEntity<ApiResponse<AuthResult>> refresh(@RequestBody java.util.Map<String, String> body) {
        String token = body.get("refreshToken");
        AuthResult result = authenticationProvider.refreshToken(token);
        return ResponseEntity.ok(ApiResponse.ok("Token refreshed successfully", result));
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout user session", description = "Invalidates the active user token and revokes refresh tokens.")
    public ResponseEntity<ApiResponse<Void>> logout(
            HttpServletRequest request,
            @RequestBody(required = false) Map<String, String> body) {
        String authHeader = request.getHeader("Authorization");
        String accessToken = (StringUtils.hasText(authHeader) && authHeader.startsWith("Bearer "))
                ? authHeader.substring(7)
                : null;
        String refreshToken = body != null ? body.get("refreshToken") : null;
        authenticationProvider.logout(accessToken, refreshToken);
        return ResponseEntity.ok(ApiResponse.ok("Logged out successfully", null));
    }

    @PostMapping("/forgot-password")
    @Operation(summary = "Initiate password reset", description = "Issues a short-lived single-use reset code without revealing account existence.")
    public ResponseEntity<ApiResponse<Map<String, Object>>> forgotPassword(@RequestBody Map<String, String> body) {
        String identifier = body.getOrDefault("identifier", body.getOrDefault("phone", body.getOrDefault("email", "")));
        return ResponseEntity.ok(ApiResponse.ok("Password reset request processed",
                authenticationProvider.forgotPassword(identifier)));
    }

    @PostMapping("/reset-password")
    @Operation(summary = "Reset password using single-use reset code")
    public ResponseEntity<ApiResponse<Void>> resetPassword(@RequestBody Map<String, String> body) {
        String identifier = body.getOrDefault("identifier", body.getOrDefault("phone", body.getOrDefault("email", "")));
        String token = body.getOrDefault("token", body.getOrDefault("otp", ""));
        String newPassword = body.getOrDefault("newPassword", "");
        authenticationProvider.resetPassword(identifier, token, newPassword);
        return ResponseEntity.ok(ApiResponse.ok("Password reset successful", null));
    }

    @PostMapping("/change-password")
    @Operation(summary = "Change password for authenticated user")
    public ResponseEntity<ApiResponse<Void>> changePassword(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody Map<String, String> body) {
        authenticationProvider.changePassword(
                principal.getId(),
                body.getOrDefault("currentPassword", ""),
                body.getOrDefault("newPassword", "")
        );
        return ResponseEntity.ok(ApiResponse.ok("Password changed successfully", null));
    }
}
