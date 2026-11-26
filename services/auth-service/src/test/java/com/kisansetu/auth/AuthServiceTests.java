package com.kisansetu.auth;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles({"test", "local"})
class AuthServiceTests {

    @Autowired
    private MockMvc mockMvc;

    private final ObjectMapper mapper = new ObjectMapper();

    @Test
    void registerLoginDynamicOtpAndRefreshRotationFlow() throws Exception {
        // 1. Register
        String regJson = "{\"phone\":\"9876500001\",\"password\":\"Secret@123\",\"role\":\"CUSTOMER\"}";
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(regJson))
                .andExpect(status().isCreated());

        // 2. Request Dynamic OTP in local profile
        String otpRes = mockMvc.perform(post("/api/v1/auth/send-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"9876500001\"}"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        JsonNode otpNode = mapper.readTree(otpRes).get("data");
        String dynamicOtp = otpNode.get("developmentOtp").asText();
        assertTrue(dynamicOtp.matches("\\d{6}"));

        // 3. Verify Dynamic OTP -> receives JWT + refreshToken
        String verifyRes = mockMvc.perform(post("/api/v1/auth/verify-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"9876500001\",\"otp\":\"" + dynamicOtp + "\"}"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        JsonNode authData = mapper.readTree(verifyRes).get("data");
        String accessToken = authData.get("token").asText();
        String refreshToken = authData.get("refreshToken").asText();
        assertFalse(accessToken.isBlank());
        assertFalse(refreshToken.isBlank());

        // 4. Refresh token rotation -> old token invalidated, new token issued
        String refreshRes = mockMvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\":\"" + refreshToken + "\"}"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        String newRefresh = mapper.readTree(refreshRes).get("data").get("refreshToken").asText();
        assertNotEquals(refreshToken, newRefresh);

        // Reusing old refresh token must fail (401)
        mockMvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\":\"" + refreshToken + "\"}"))
                .andExpect(status().isUnauthorized());
    }
}
