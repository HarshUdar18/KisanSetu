package com.kisansetu.modules.auth.provider;

import com.kisansetu.modules.auth.dto.AuthResult;
import com.kisansetu.modules.auth.dto.OtpChallenge;
import com.kisansetu.modules.auth.dto.RegisterUserRequest;

public interface AuthenticationProvider {
    AuthResult registerUser(RegisterUserRequest request);
    AuthResult loginWithPassword(String identifier, String password);
    OtpChallenge sendOtp(String phone);
    AuthResult verifyOtp(String phone, String otp);
    AuthResult refreshToken(String refreshToken);
    void logout(String token);
}
