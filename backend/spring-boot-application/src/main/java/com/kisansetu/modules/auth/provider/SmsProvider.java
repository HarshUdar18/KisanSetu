package com.kisansetu.modules.auth.provider;

/**
 * Abstraction for SMS OTP delivery (e.g. MSG91, Twilio).
 * Local/dev environments use a zero-credential implementation.
 */
public interface SmsProvider {
    void sendOtpSms(String phone, String message);
}
