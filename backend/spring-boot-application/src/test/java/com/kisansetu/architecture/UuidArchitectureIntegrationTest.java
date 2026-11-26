package com.kisansetu.architecture;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.kisansetu.modules.audit.entity.AuditLog;
import com.kisansetu.modules.catalog.entity.ProductCategory;
import com.kisansetu.modules.customer.entity.CustomerProfile;
import com.kisansetu.modules.farmer.entity.FarmerProfile;
import com.kisansetu.modules.hub.entity.Hub;
import com.kisansetu.modules.operations.entity.ProcessedEvent;
import com.kisansetu.modules.product.entity.Product;
import com.kisansetu.modules.user.entity.Role;
import com.kisansetu.modules.user.entity.User;
import com.kisansetu.modules.user.repository.RoleRepository;
import com.kisansetu.modules.user.repository.UserRepository;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider;
import org.springframework.core.type.filter.AnnotationTypeFilter;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.lang.reflect.Field;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
class UuidArchitectureIntegrationTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("Every JPA @Entity (except static Role and ProcessedEvent) uses java.util.UUID as @Id")
    void allBusinessEntitiesUseUuidPrimaryKey() throws Exception {
        ClassPathScanningCandidateComponentProvider scanner =
                new ClassPathScanningCandidateComponentProvider(false);
        scanner.addIncludeFilter(new AnnotationTypeFilter(Entity.class));

        Set<Class<?>> exceptions = Set.of(Role.class, ProcessedEvent.class);
        int checkedCount = 0;

        for (var bd : scanner.findCandidateComponents("com.kisansetu.modules")) {
            Class<?> clazz = Class.forName(bd.getBeanClassName());
            if (exceptions.contains(clazz)) {
                continue;
            }
            Field idField = null;
            for (Field f : clazz.getDeclaredFields()) {
                if (f.isAnnotationPresent(Id.class)) {
                    idField = f;
                    break;
                }
            }
            assertNotNull(idField, "Entity missing @Id: " + clazz.getName());
            assertEquals(UUID.class, idField.getType(),
                    "Entity @Id must be java.util.UUID: " + clazz.getName());
            checkedCount++;
        }
        assertTrue(checkedCount >= 20, "Expected at least 20 business entities checked, got " + checkedCount);
    }

    @Test
    @DisplayName("Generated UUIDv4 primary keys are unique, valid, immutable, and JSON-serializable")
    @Transactional
    void uuidGenerationPersistenceAndJsonSerialization() throws Exception {
        Role role = roleRepository.findById("ROLE_CUSTOMER")
                .orElseGet(() -> roleRepository.save(new Role("ROLE_CUSTOMER", "Customer")));

        Set<UUID> generatedIds = new HashSet<>();
        for (int i = 0; i < 25; i++) {
            User u = new User("9800000" + String.format("%03d", i), null, "hash");
            u.addRole(role);
            User saved = userRepository.save(u);
            assertNotNull(saved.getId());
            assertEquals(4, saved.getId().version(), "Expected UUIDv4");
            assertEquals(2, saved.getId().variant(), "Expected RFC 4122 variant");
            assertTrue(generatedIds.add(saved.getId()), "Duplicate UUID generated");
        }

        UUID sampleId = generatedIds.iterator().next();
        String json = objectMapper.writeValueAsString(sampleId);
        UUID deserialized = objectMapper.readValue(json, UUID.class);
        assertEquals(sampleId, deserialized);

        // Verify core domain entity IDs are UUID
        assertEquals(UUID.class, CustomerProfile.class.getDeclaredField("id").getType());
        assertEquals(UUID.class, FarmerProfile.class.getDeclaredField("id").getType());
        assertEquals(UUID.class, ProductCategory.class.getDeclaredField("id").getType());
        assertEquals(UUID.class, Product.class.getDeclaredField("id").getType());
        assertEquals(UUID.class, Hub.class.getDeclaredField("id").getType());
        assertEquals(UUID.class, AuditLog.class.getDeclaredField("id").getType());
    }
}
