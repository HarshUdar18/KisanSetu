package com.kisansetu.modules.servicearea;

import com.kisansetu.common.response.ApiResponse;
import com.kisansetu.modules.servicearea.entity.ServiceArea;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/service-areas")
@Tag(name = "Service Areas", description = "Regional delivery zones and serviceability verification (Shivajinagar, Akurdi)")
public class ServiceAreaController {

    private final ServiceAreaService serviceAreaService;

    public ServiceAreaController(ServiceAreaService serviceAreaService) {
        this.serviceAreaService = serviceAreaService;
    }

    @GetMapping
    @Operation(summary = "List all active service areas", description = "Returns active operational zones for farm-to-consumer delivery.")
    public ResponseEntity<ApiResponse<List<ServiceArea>>> getActiveAreas() {
        List<ServiceArea> areas = serviceAreaService.getActiveServiceAreas();
        return ResponseEntity.ok(ApiResponse.ok("Active service areas", areas));
    }

    @GetMapping("/check")
    @Operation(summary = "Check PIN code serviceability", description = "Determines whether direct supply chain delivery is supported for the given PIN code.")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkPincode(@RequestParam String pincode) {
        Map<String, Object> result = serviceAreaService.checkPincode(pincode);
        return ResponseEntity.ok(ApiResponse.ok("Serviceability check result", result));
    }

    @PostMapping("/check")
    @Operation(summary = "Check PIN code serviceability via POST body")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkPincodePost(@RequestBody Map<String, String> body) {
        String pincode = body.getOrDefault("pincode", "");
        Map<String, Object> result = serviceAreaService.checkPincode(pincode);
        return ResponseEntity.ok(ApiResponse.ok("Serviceability check result", result));
    }
}
