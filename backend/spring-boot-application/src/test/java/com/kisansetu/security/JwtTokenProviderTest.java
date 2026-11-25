package com.kisansetu.security;

import com.kisansetu.common.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class JwtTokenProviderTest {

    private JwtService jwtService;
    private BCryptPasswordEncoder passwordEncoder;

    private static final String TEST_SECRET = "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970";
    private static final long EXPIRATION_MS = 3600000; // 1 hour

    @BeforeEach
    void setUp() {
        jwtService = new JwtService(TEST_SECRET, EXPIRATION_MS);
        passwordEncoder = new BCryptPasswordEncoder();
    }

    @Test
    @DisplayName("Generate and validate JWT token successfully with multiple roles")
    void testGenerateAndValidateToken() {
        UUID userId = UUID.randomUUID();
        String phone = "9876543211";
        List<String> roles = List.of("ROLE_CUSTOMER", "ROLE_FARMER");

        String token = jwtService.generateToken(userId, phone, roles);

        assertNotNull(token);
        assertTrue(jwtService.isTokenValid(token));
        assertEquals(phone, jwtService.extractUsername(token));
        assertEquals(userId, jwtService.extractUserId(token));
        assertTrue(jwtService.extractRoles(token).contains("ROLE_CUSTOMER"));
        assertTrue(jwtService.extractRoles(token).contains("ROLE_FARMER"));
    }

    @Test
    @DisplayName("Verify password encoding and matching with BCrypt")
    void testPasswordEncoding() {
        String rawPassword = "password123";
        String encoded = passwordEncoder.encode(rawPassword);

        assertNotNull(encoded);
        assertTrue(passwordEncoder.matches(rawPassword, encoded));
        assertFalse(passwordEncoder.matches("wrongPassword", encoded));
    }
}
