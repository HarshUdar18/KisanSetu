package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.Warehouse;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface WarehouseRepository extends JpaRepository<Warehouse, UUID> {}
