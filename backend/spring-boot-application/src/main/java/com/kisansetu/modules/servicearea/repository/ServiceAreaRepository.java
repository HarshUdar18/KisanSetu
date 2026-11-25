package com.kisansetu.modules.servicearea.repository;

import com.kisansetu.modules.servicearea.entity.ServiceArea;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ServiceAreaRepository extends JpaRepository<ServiceArea, UUID> {
    List<ServiceArea> findByStatus(String status);
    Optional<ServiceArea> findByPincode(String pincode);
    Optional<ServiceArea> findByPincodeAndStatus(String pincode, String status);
    boolean existsByPincodeAndStatus(String pincode, String status);
}
