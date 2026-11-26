package com.kisansetu.modules.auth.dto;

import com.kisansetu.common.exception.BadRequestException;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class VerifyOtpRequest {

    private String phone;
    private String countryCode;
    private String email;
    private String identifier;

    @NotBlank(message = "OTP is required")
    @Pattern(regexp = "^\\d{6}$", message = "OTP must be a 6-digit numeric code")
    private String otp;

    private String role;

    public VerifyOtpRequest() {}

    public VerifyOtpRequest(String phone, String otp) {
        this.phone = phone;
        this.otp = otp;
    }

    public String resolveIdentifier() {
        String raw = firstNonBlank(identifier, phone, email);
        if (raw == null) {
            throw new BadRequestException("Mobile number or email address is required");
        }
        String trimmed = raw.trim();
        if (trimmed.contains("@")) {
            if (trimmed.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
                return trimmed.toLowerCase();
            }
            throw new BadRequestException("Please provide a valid email address");
        }
        return SendOtpRequest.normalizePhone(trimmed, countryCode);
    }

    private String firstNonBlank(String... values) {
        for (String v : values) {
            if (v != null && !v.isBlank()) return v;
        }
        return null;
    }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getCountryCode() { return countryCode; }
    public void setCountryCode(String countryCode) { this.countryCode = countryCode; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getIdentifier() { return identifier; }
    public void setIdentifier(String identifier) { this.identifier = identifier; }
    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
