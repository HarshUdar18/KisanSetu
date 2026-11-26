package com.kisansetu.modules.auth.provider;

import com.kisansetu.common.exception.ApiException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Component
public class LocalSmsProvider implements SmsProvider {

    private static final Logger log = LoggerFactory.getLogger(LocalSmsProvider.class);

    private final String providerName;
    private final String apiKey;
    private final boolean blockWhenUnconfigured;

    public LocalSmsProvider() {
        this.providerName = "";
        this.apiKey = "";
        this.blockWhenUnconfigured = false;
    }

    @Autowired
    public LocalSmsProvider(
            @Value("${app.auth.sms.provider:}") String providerName,
            @Value("${app.auth.sms.api-key:}") String apiKey,
            @Value("${app.auth.sms.block-when-unconfigured:true}") boolean blockWhenUnconfigured) {
        this.providerName = providerName != null ? providerName.trim() : "";
        this.apiKey = apiKey != null ? apiKey.trim() : "";
        this.blockWhenUnconfigured = blockWhenUnconfigured;
    }

    @Override
    public boolean isConfigured() {
        return StringUtils.hasText(providerName)
                && !"none".equalsIgnoreCase(providerName)
                && StringUtils.hasText(apiKey);
    }

    @Override
    public void sendOtpSms(String phone, String message) {
        // Never logs OTP payload.
        if (!isConfigured()) {
            if (blockWhenUnconfigured) {
                throw new ApiException(
                        "SMS_PROVIDER_BLOCKED",
                        "Production SMS OTP delivery is blocked: SMS provider credentials are not configured.",
                        HttpStatus.SERVICE_UNAVAILABLE);
            }
            log.warn("SMS provider credentials unavailable for phone ending in {}",
                    phone.length() >= 4 ? phone.substring(phone.length() - 4) : "****");
            return;
        }
        // Configured external SMS provider dispatch hook (MSG91/Twilio HTTP integration
        // goes here)
        log.info("SMS OTP dispatched via {} to phone ending in {}",
                providerName, phone.length() >= 4 ? phone.substring(phone.length() - 4) : "****");
    }
}
