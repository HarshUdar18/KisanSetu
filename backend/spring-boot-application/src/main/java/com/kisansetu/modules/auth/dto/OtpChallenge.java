package com.kisansetu.modules.auth.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class OtpChallenge {
    private String phone;
    private String message;
    private String developmentOtp; // Populated ONLY when dev or local profile is active
    private Integer expiresInSeconds;
    private Integer resendCooldownSeconds;

    public OtpChallenge() {}

    public OtpChallenge(String phone, String message, String developmentOtp) {
        this.phone = phone;
        this.message = message;
        this.developmentOtp = developmentOtp;
    }

    public OtpChallenge(String phone, String message, String developmentOtp, Integer expiresInSeconds, Integer resendCooldownSeconds) {
        this.phone = phone;
        this.message = message;
        this.developmentOtp = developmentOtp;
        this.expiresInSeconds = expiresInSeconds;
        this.resendCooldownSeconds = resendCooldownSeconds;
    }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getDevelopmentOtp() { return developmentOtp; }
    public void setDevelopmentOtp(String developmentOtp) { this.developmentOtp = developmentOtp; }

    public Integer getExpiresInSeconds() { return expiresInSeconds; }
    public void setExpiresInSeconds(Integer expiresInSeconds) { this.expiresInSeconds = expiresInSeconds; }

    public Integer getResendCooldownSeconds() { return resendCooldownSeconds; }
    public void setResendCooldownSeconds(Integer resendCooldownSeconds) { this.resendCooldownSeconds = resendCooldownSeconds; }
}
