package com.kisansetu.modules.operations.repository;

import com.kisansetu.modules.operations.entity.GovtScheme;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface GovtSchemeRepository extends JpaRepository<GovtScheme, UUID> {
    List<GovtScheme> findByIsActiveTrue();
}
