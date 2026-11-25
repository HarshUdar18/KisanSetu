package com.kisansetu.modules.auth.dto;

import java.util.List;
import java.util.UUID;

public class AuthResult {
    private String token;
    private String refreshToken;
    private String type = "Bearer";
    private UUID userId;
    private String identifier;
    private List<String> roles;
    private long expiresInMs;

    public AuthResult() {}

    public AuthResult(String token, UUID userId, String identifier, List<String> roles, long expiresInMs) {
        this.token = token;
        this.userId = userId;
        this.identifier = identifier;
        this.roles = roles;
        this.expiresInMs = expiresInMs;
    }

    public AuthResult(String token, String refreshToken, UUID userId, String identifier, List<String> roles, long expiresInMs) {
        this(token, userId, identifier, roles, expiresInMs);
        this.refreshToken = refreshToken;
    }

    public String getRefreshToken() { return refreshToken; }
    public void setRefreshToken(String refreshToken) { this.refreshToken = refreshToken; }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public String getIdentifier() {
        return identifier;
    }

    public void setIdentifier(String identifier) {
        this.identifier = identifier;
    }

    public List<String> getRoles() {
        return roles;
    }

    public void setRoles(List<String> roles) {
        this.roles = roles;
    }

    public long getExpiresInMs() {
        return expiresInMs;
    }

    public void setExpiresInMs(long expiresInMs) {
        this.expiresInMs = expiresInMs;
    }
}
