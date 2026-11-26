package com.kisansetu.auth.repository;

import com.kisansetu.auth.entity.AuthRole;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuthRoleRepository extends JpaRepository<AuthRole, String> {}
