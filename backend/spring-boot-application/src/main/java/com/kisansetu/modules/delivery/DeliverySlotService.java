package com.kisansetu.modules.delivery;

import com.kisansetu.common.exception.ApiException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class DeliverySlotService {

    private final JdbcTemplate jdbcTemplate;

    public DeliverySlotService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public record DeliverySlotDto(
            UUID slotId,
            String slotCode,
            String slotType,
            String fulfilmentType,
            String label,
            String startTime,
            String endTime,
            UUID localityId,
            int capacity,
            int remainingCapacity,
            boolean active
    ) {}

    @Transactional(readOnly = true)
    public List<DeliverySlotDto> listSlots(String slotType, UUID localityId) {
        StringBuilder sql = new StringBuilder("""
                SELECT slot_id, slot_code, slot_type, fulfilment_type, label,
                       start_time::text AS start_time, end_time::text AS end_time,
                       locality_id, capacity, remaining_capacity, is_active
                FROM delivery_slots
                WHERE is_active = true
                  AND remaining_capacity > 0
                """);
        if (slotType != null && !slotType.isBlank()) {
            sql.append(" AND slot_type = '").append(slotType.trim().toUpperCase().replace("'", "")).append("'");
        }
        if (localityId != null) {
            sql.append(" AND (locality_id IS NULL OR locality_id = '").append(localityId).append("')");
        }
        sql.append(" ORDER BY start_time ASC");

        return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
            String loc = rs.getString("locality_id");
            return new DeliverySlotDto(
                    UUID.fromString(rs.getString("slot_id")),
                    rs.getString("slot_code"),
                    rs.getString("slot_type"),
                    rs.getString("fulfilment_type"),
                    rs.getString("label"),
                    rs.getString("start_time"),
                    rs.getString("end_time"),
                    loc != null ? UUID.fromString(loc) : null,
                    rs.getInt("capacity"),
                    rs.getInt("remaining_capacity"),
                    rs.getBoolean("is_active")
            );
        });
    }

    @Transactional
    public UUID reserveSlot(UUID slotId, UUID userId, UUID orderId, UUID subscriptionId) {
        int updated = jdbcTemplate.update("""
                UPDATE delivery_slots
                SET remaining_capacity = remaining_capacity - 1, updated_at = NOW()
                WHERE slot_id = ? AND is_active = true AND remaining_capacity > 0
                """, slotId);
        if (updated == 0) {
            throw new ApiException("SLOT_UNAVAILABLE", "Selected delivery slot is full or inactive", HttpStatus.CONFLICT);
        }
        UUID reservationId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO slot_reservations (reservation_id, slot_id, user_id, order_id, subscription_id, status)
                VALUES (?, ?, ?, ?, ?, 'RESERVED')
                """, reservationId, slotId, userId, orderId, subscriptionId);
        return reservationId;
    }
}
