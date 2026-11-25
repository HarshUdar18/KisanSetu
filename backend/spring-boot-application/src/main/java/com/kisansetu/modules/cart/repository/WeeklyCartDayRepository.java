package com.kisansetu.modules.cart.repository;

import com.kisansetu.modules.cart.entity.WeeklyCartDay;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface WeeklyCartDayRepository extends JpaRepository<WeeklyCartDay, UUID> {
    Optional<WeeklyCartDay> findByWeeklyCartIdAndDayOfWeek(UUID weeklyCartId, String dayOfWeek);
}
