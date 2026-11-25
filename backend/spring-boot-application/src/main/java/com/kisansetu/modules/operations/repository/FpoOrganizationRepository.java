package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.FpoOrganization;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface FpoOrganizationRepository extends JpaRepository<FpoOrganization, UUID> {}
