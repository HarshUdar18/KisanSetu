package com.kisansetu.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.kisansetu.common.exception.ApiException;
import com.kisansetu.common.exception.BadRequestException;
import com.kisansetu.modules.auth.dto.OtpChallenge;
import com.kisansetu.modules.auth.dto.SendOtpRequest;
import com.kisansetu.modules.auth.provider.DevelopmentOtpProvider;
import com.kisansetu.modules.auth.provider.LocalSmsProvider;
import org.junit.jupiter.api.Test;
import org.springframework.mock.env.MockEnvironment;

import static org.junit.jupiter.api.Assertions.*;

class DevelopmentOtpProviderTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void devAndLocalProfilesGenerateDynamic6DigitOtpAndVerifyAgainstStoredOtp() {
        MockEnvironment localEnv = new MockEnvironment();
        localEnv.setActiveProfiles("local");
        DevelopmentOtpProvider provider = new DevelopmentOtpProvider(localEnv, new LocalSmsProvider());

        assertTrue(provider.isDevelopmentMode());
        var challenge = provider.generateOtp("9876543211");
        assertNotNull(challenge.developmentOtp());
        assertTrue(challenge.developmentOtp().matches("\\d{6}"), "Must be a 6-digit numeric OTP");
        assertEquals(300, challenge.expiresInSeconds());
        assertEquals(30, challenge.resendCooldownSeconds());

        // Must verify against the exact dynamically generated OTP
        assertDoesNotThrow(() -> provider.verifyOtp("9876543211", challenge.developmentOtp()));
    }

    @Test
    void prodProfileNeverReturnsOrSerializesOtpAndRejectsArbitraryCodes() throws Exception {
        MockEnvironment prodEnv = new MockEnvironment();
        prodEnv.setActiveProfiles("prod");
        DevelopmentOtpProvider provider = new DevelopmentOtpProvider(prodEnv, new LocalSmsProvider());

        assertFalse(provider.isDevelopmentMode());
        var challenge = provider.generateOtp("9876543211");
        assertNull(challenge.developmentOtp(), "Production must never return developmentOtp");

        OtpChallenge dto = new OtpChallenge(
                challenge.phone(),
                challenge.message(),
                challenge.developmentOtp(),
                challenge.expiresInSeconds(),
                challenge.resendCooldownSeconds()
        );
        String json = objectMapper.writeValueAsString(dto);
        assertFalse(json.contains("developmentOtp"), "JSON payload must omit developmentOtp in production");

        BadRequestException ex = assertThrows(BadRequestException.class,
                () -> provider.verifyOtp("9876543211", "000000"));
        assertTrue(ex.getMessage().contains("Invalid OTP"));
    }

    @Test
    void enforcesResendCooldownAndMaxVerificationAttempts() {
        MockEnvironment devEnv = new MockEnvironment();
        devEnv.setActiveProfiles("dev");
        DevelopmentOtpProvider provider = new DevelopmentOtpProvider(devEnv, new LocalSmsProvider());

        var challenge = provider.generateOtp("9876543212");

        // Resend within cooldown must fail
        BadRequestException cooldownEx = assertThrows(BadRequestException.class,
                () -> provider.generateOtp("9876543212"));
        assertTrue(cooldownEx.getMessage().contains("wait"));

        // 5 failed attempts invalidate the OTP
        String wrongOtp = challenge.developmentOtp().equals("000000") ? "999999" : "000000";
        for (int i = 0; i < 4; i++) {
            assertThrows(BadRequestException.class, () -> provider.verifyOtp("9876543212", wrongOtp));
        }
        BadRequestException maxEx = assertThrows(BadRequestException.class,
                () -> provider.verifyOtp("9876543212", wrongOtp));
        assertTrue(maxEx.getMessage().contains("Maximum"));

        // Even the originally generated OTP is now rejected because challenge was invalidated
        assertThrows(BadRequestException.class, () -> provider.verifyOtp("9876543212", challenge.developmentOtp()));
    }

    @Test
    void normalizesIndianPhoneNumbersAndRejectsInvalidInputs() {
        SendOtpRequest spaced = new SendOtpRequest("+91 98765 43211");
        spaced.setCountryCode("+91");
        assertEquals("9876543211", spaced.resolveIdentifier());

        SendOtpRequest zeroPrefix = new SendOtpRequest("09876543211");
        assertEquals("9876543211", zeroPrefix.resolveIdentifier());

        SendOtpRequest tooShort = new SendOtpRequest("98765");
        assertThrows(BadRequestException.class, tooShort::resolveIdentifier);

        SendOtpRequest arbitrary = new SendOtpRequest("hello-world");
        assertThrows(BadRequestException.class, arbitrary::resolveIdentifier);
    }

    @Test
    void rejectsDuplicateOtpReuseAndBlocksProdWithoutSmsCredentials() {
        MockEnvironment localEnv = new MockEnvironment();
        localEnv.setActiveProfiles("local");
        DevelopmentOtpProvider localProvider = new DevelopmentOtpProvider(localEnv, new LocalSmsProvider());
        var challenge = localProvider.generateOtp("9876543219");
        assertDoesNotThrow(() -> localProvider.verifyOtp("9876543219", challenge.developmentOtp()));
        assertThrows(BadRequestException.class, () -> localProvider.verifyOtp("9876543219", challenge.developmentOtp()));

        MockEnvironment prodEnv = new MockEnvironment();
        prodEnv.setActiveProfiles("prod");
        LocalSmsProvider blockingSms = new LocalSmsProvider("", "", true);
        DevelopmentOtpProvider prodProvider = new DevelopmentOtpProvider(prodEnv, blockingSms, false);
        ApiException blocked = assertThrows(ApiException.class, () -> prodProvider.generateOtp("9876543219"));
        assertEquals("SMS_PROVIDER_BLOCKED", blocked.getCode());
    }
}
