package com.kisansetu.modules.auth.controller;

import com.kisansetu.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/health")
@Tag(name = "Health", description = "Public health check endpoint for KisanSetu platform")
public class HealthController {

    @GetMapping
    @Operation(summary = "System status check", description = "Returns active platform metadata, version, and server timestamp.")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkHealth() {
        return ResponseEntity.ok(ApiResponse.ok("KisanSetu backend is healthy and running", Map.of(
                "status", "UP",
                "service", "kisansetu-backend",
                "phase", "PHASE_0",
                "version", "v1.0.0",
                "serverTime", Instant.now().toString()
        )));
    }
}
