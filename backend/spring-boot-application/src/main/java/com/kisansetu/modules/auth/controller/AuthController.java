package com.kisansetu.modules.auth.controller;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.auth.dto.*;
import com.kisansetu.modules.auth.provider.AuthenticationProvider;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping({"/send-otp", "/request-otp"})
    @Operation(summary = "Send OTP to mobile phone", description = "Simulates sending a 6-digit OTP to the Indian mobile number for passwordless authentication.")
    public ResponseEntity<ApiResponse<OtpChallenge>> sendOtp(@Valid @RequestBody SendOtpRequest request) {
        OtpChallenge challenge = authenticationProvider.sendOtp(request.getPhone());
        return ResponseEntity.ok(ApiResponse.ok("OTP dispatched", challenge));
    }

    @PostMapping("/verify-otp")
    @Operation(summary = "Verify OTP and obtain JWT", description = "Validates the OTP entered by the user against the backend challenge.")
    public ResponseEntity<ApiResponse<AuthResult>> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        AuthResult result = authenticationProvider.verifyOtp(request.getPhone(), request.getOtp());
        return ResponseEntity.ok(ApiResponse.ok("OTP verification successful", result));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Rotate refresh token and issue new JWT access token")
    public ResponseEntity<ApiResponse<AuthResult>> refresh(@RequestBody java.util.Map<String, String> body) {
        String token = body.get("refreshToken");
        AuthResult result = authenticationProvider.refreshToken(token);
        return ResponseEntity.ok(ApiResponse.ok("Token refreshed successfully", result));
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout user session", description = "Invalidates the active user token and logs an audit trail event.")
    public ResponseEntity<ApiResponse<Void>> logout(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (StringUtils.hasText(authHeader) && authHeader.startsWith("Bearer ")) {
            authenticationProvider.logout(authHeader.substring(7));
        }
        return ResponseEntity.ok(ApiResponse.ok("Logged out successfully", null));
    }
}
