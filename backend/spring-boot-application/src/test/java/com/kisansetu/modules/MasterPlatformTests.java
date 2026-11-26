package com.kisansetu.modules;

import com.kisansetu.common.exception.BadRequestException;
import com.kisansetu.modules.auth.provider.DevelopmentOtpProvider;
import com.kisansetu.modules.auth.provider.SmsProvider;
import org.junit.jupiter.api.Test;
import org.springframework.mock.env.MockEnvironment;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mock;

class MasterPlatformTests {

    @Test
    void developmentOtp_isHiddenWhenExposeFlagFalse() {
        MockEnvironment env = new MockEnvironment().withProperty("spring.profiles.active", "dev");
        env.setActiveProfiles("dev");
        DevelopmentOtpProvider provider = new DevelopmentOtpProvider(env, mock(SmsProvider.class), false);
        var challenge = provider.generateOtp("9876543210");
        assertNull(challenge.developmentOtp(), "OTP must not be exposed when flag is false");
    }

    @Test
    void developmentOtp_isExposedAndVerifiedInDevWhenFlagTrue() {
        MockEnvironment env = new MockEnvironment();
        env.setActiveProfiles("dev");
        DevelopmentOtpProvider provider = new DevelopmentOtpProvider(env, mock(SmsProvider.class), true);
        var challenge = provider.generateOtp("customer@example.com");
        assertNotNull(challenge.developmentOtp());
        assertEquals(6, challenge.developmentOtp().length());

        assertThrows(BadRequestException.class, () -> provider.verifyOtp("customer@example.com", "000000"));
        assertDoesNotThrow(() -> provider.verifyOtp("customer@example.com", challenge.developmentOtp()));
        assertThrows(BadRequestException.class, () -> provider.verifyOtp("customer@example.com", challenge.developmentOtp()));
    }
}
