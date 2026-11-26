package com.kisansetu.modules.auth.provider;

import com.kisansetu.modules.auth.dto.AuthResult;
import com.kisansetu.modules.auth.dto.OtpChallenge;
import com.kisansetu.modules.auth.dto.RegisterUserRequest;

import java.util.Map;
import java.util.UUID;

public interface AuthenticationProvider {
    AuthResult registerUser(RegisterUserRequest request);
    AuthResult loginWithPassword(String identifier, String password);
    OtpChallenge sendOtp(String identifier);
    AuthResult verifyOtp(String identifier, String otp);
    default AuthResult verifyOtp(String identifier, String otp, String requestedRole) {
        return verifyOtp(identifier, otp);
    }
    AuthResult loginWithGoogle(String idToken);
    Map<String, Object> getCapabilities();
    AuthResult refreshToken(String refreshToken);
    void logout(String token);
    default void logout(String token, String refreshToken) {
        logout(token);
    }
    Map<String, Object> forgotPassword(String identifier);
    void resetPassword(String identifier, String token, String newPassword);
    void changePassword(UUID userId, String currentPassword, String newPassword);
}
