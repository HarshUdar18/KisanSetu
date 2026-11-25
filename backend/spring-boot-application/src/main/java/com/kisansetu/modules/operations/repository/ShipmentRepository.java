package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.Shipment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface ShipmentRepository extends JpaRepository<Shipment, UUID> {
    Optional<Shipment> findByOrderId(UUID orderId);
}
