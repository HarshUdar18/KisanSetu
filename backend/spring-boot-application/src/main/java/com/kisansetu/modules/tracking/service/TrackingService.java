package com.kisansetu.modules.tracking.service;

import com.kisansetu.common.exception.ApiException;
import com.kisansetu.modules.order.entity.Order;
import com.kisansetu.modules.order.repository.OrderRepository;
import com.kisansetu.modules.tracking.dto.OrderTrackingTimelineDto;
import com.kisansetu.modules.tracking.dto.TrackingEventDto;
import com.kisansetu.modules.tracking.entity.TrackingEvent;
import com.kisansetu.modules.tracking.repository.TrackingEventRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class TrackingService {

    private final TrackingEventRepository trackingEventRepository;
    private final OrderRepository orderRepository;

    public TrackingService(TrackingEventRepository trackingEventRepository, OrderRepository orderRepository) {
        this.trackingEventRepository = trackingEventRepository;
        this.orderRepository = orderRepository;
    }

    @Transactional(readOnly = true)
    public OrderTrackingTimelineDto getOrderTracking(UUID userId, UUID orderId) {
        Order order = orderRepository.findByIdAndUserId(orderId, userId)
                .orElseThrow(() -> new ApiException("ORDER_NOT_FOUND", "Order not found or unauthorized", HttpStatus.NOT_FOUND));

        List<TrackingEvent> events = trackingEventRepository.findByOrderIdOrderByDisplayOrderAsc(order.getId());
        List<TrackingEventDto> eventDtos = events.stream()
                .map(TrackingEventDto::fromEntity)
                .collect(Collectors.toList());

        return new OrderTrackingTimelineDto(order.getId(), order.getOrderNumber(), order.getOrderStatus(), eventDtos);
    }

    /**
     * DEVELOPMENT ONLY: Simulates progression of tracking events along the supply chain.
     */
    @Transactional
    public OrderTrackingTimelineDto advanceTrackingStageDev(UUID orderId, int targetStageOrder) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ApiException("ORDER_NOT_FOUND", "Order not found", HttpStatus.NOT_FOUND));

        List<TrackingEvent> events = trackingEventRepository.findByOrderIdOrderByDisplayOrderAsc(order.getId());
        String newStatus = order.getOrderStatus();

        for (TrackingEvent event : events) {
            if (event.getDisplayOrder() <= targetStageOrder) {
                event.setCompleted(true);
                event.setOccurredAt(Instant.now());
                newStatus = event.getStatus();
            } else {
                event.setCompleted(false);
            }
        }

        order.setOrderStatus(newStatus);
        orderRepository.save(order);
        trackingEventRepository.saveAll(events);

        List<TrackingEventDto> eventDtos = events.stream()
                .map(TrackingEventDto::fromEntity)
                .collect(Collectors.toList());

        return new OrderTrackingTimelineDto(order.getId(), order.getOrderNumber(), newStatus, eventDtos);
    }
}
