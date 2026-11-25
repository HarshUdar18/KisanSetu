package com.kisansetu.customer;

import com.kisansetu.modules.customer.repository.CustomerProfileRepository;
import com.kisansetu.modules.customer.service.CustomerService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class CustomerServiceTest {

    private CustomerProfileRepository profileRepository;
    private CustomerService customerService;

    @BeforeEach
    void setUp() {
        profileRepository = Mockito.mock(CustomerProfileRepository.class);
        customerService = new CustomerService(profileRepository);
    }

    @Test
    @DisplayName("Serviceability check returns true for valid 6-digit Indian PIN code")
    void testValidPincodeServiceability() {
        Map<String, Object> result = customerService.checkServiceability("560038");

        assertEquals(true, result.get("isServiceable"));
        assertEquals("560038", result.get("pincode"));
        assertEquals(24, result.get("estimatedDeliveryHours"));
        assertEquals("Central-Agri-Hub-01", result.get("hubAssigned"));
    }

    @Test
    @DisplayName("Serviceability check returns false for invalid PIN code")
    void testInvalidPincodeServiceability() {
        Map<String, Object> result = customerService.checkServiceability("123");

        assertEquals(false, result.get("isServiceable"));
        assertEquals("None", result.get("hubAssigned"));
    }
}
