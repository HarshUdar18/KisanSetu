package com.kisansetu.modules.auth.dto;

import com.kisansetu.common.exception.BadRequestException;

public class SendOtpRequest {

    private String phone;
    private String countryCode;
    private String email;
    private String identifier;

    public SendOtpRequest() {}

    public SendOtpRequest(String phone) {
        this.phone = phone;
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
        return normalizePhone(trimmed, countryCode);
    }

    public static String normalizePhone(String rawPhone, String countryCode) {
        String compact = rawPhone.replaceAll("[\\s\\-()]", "");
        String cc = countryCode == null ? "+91" : countryCode.trim();
        if (cc.isEmpty() || "+91".equals(cc) || "91".equals(cc) || "IN".equalsIgnoreCase(cc)) {
            if (compact.startsWith("+91")) {
                compact = compact.substring(3);
            } else if (compact.startsWith("91") && compact.length() == 12) {
                compact = compact.substring(2);
            } else if (compact.startsWith("0") && compact.length() == 11) {
                compact = compact.substring(1);
            }
            if (compact.matches("^[6-9]\\d{9}$")) {
                return compact;
            }
            throw new BadRequestException("Please enter a valid 10-digit Indian mobile number.");
        }

        String normalizedCc = cc.startsWith("+") ? cc : "+" + cc;
        if (!normalizedCc.matches("^\\+[1-9]\\d{0,3}$")) {
            throw new BadRequestException("Invalid country code.");
        }
        String digits = compact.startsWith("+") ? compact.substring(1) : compact;
        String ccDigits = normalizedCc.substring(1);
        if (digits.startsWith(ccDigits) && digits.length() > ccDigits.length() + 5) {
            digits = digits.substring(ccDigits.length());
        }
        String full = normalizedCc + digits;
        if (full.matches("^\\+[1-9]\\d{6,14}$")) {
            return full;
        }
        throw new BadRequestException("Please enter a valid mobile number.");
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
}
