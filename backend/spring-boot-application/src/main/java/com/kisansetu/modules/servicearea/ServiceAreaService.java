package com.kisansetu.modules.servicearea;

import com.kisansetu.modules.servicearea.entity.ServiceArea;
import com.kisansetu.modules.servicearea.repository.ServiceAreaRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ServiceAreaService {

    private final ServiceAreaRepository serviceAreaRepository;

    public ServiceAreaService(ServiceAreaRepository serviceAreaRepository) {
        this.serviceAreaRepository = serviceAreaRepository;
    }

    @Transactional(readOnly = true)
    @Cacheable(value = "serviceAreas", key = "'allActive'")
    public List<ServiceArea> getActiveServiceAreas() {
        return serviceAreaRepository.findByStatus("ACTIVE");
    }

    @Transactional(readOnly = true)
    public Map<String, Object> checkPincode(String pincode) {
        Map<String, Object> result = new HashMap<>();
        result.put("pincode", pincode);

        var areaOpt = serviceAreaRepository.findByPincodeAndStatus(pincode, "ACTIVE");
        if (areaOpt.isPresent()) {
            ServiceArea area = areaOpt.get();
            result.put("isServiceable", true);
            result.put("serviceAreaName", area.getName());
            result.put("city", area.getCity());
            result.put("radiusKm", area.getRadiusKm());
            result.put("deliveryTimelineHours", 24);
        } else {
            result.put("isServiceable", false);
            result.put("message", "Service area not yet launched in PIN " + pincode + ". Currently live in Shivajinagar (411005) & Akurdi (411035).");
        }
        return result;
    }
}
