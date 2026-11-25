package com.kisansetu.modules.auth.provider;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class LocalSmsProvider implements SmsProvider {

    private static final Logger log = LoggerFactory.getLogger(LocalSmsProvider.class);

    @Override
    public void sendOtpSms(String phone, String message) {
        // Intentionally never logs OTP payload; safe placeholder until MSG91/Twilio is configured.
        log.debug("SMS dispatch queued for phone ending in {}", phone.length() >= 4 ? phone.substring(phone.length() - 4) : "****");
    }
}
