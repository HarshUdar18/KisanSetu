package com.kisansetu.modules.auth.provider;

/**
 * Abstraction for SMS OTP delivery (e.g. MSG91, Twilio).
 */
public interface SmsProvider {
    void sendOtpSms(String phone, String message);

    default boolean isConfigured() {
        return false;
    }
}
