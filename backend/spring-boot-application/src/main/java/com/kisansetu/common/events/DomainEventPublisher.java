package com.kisansetu.common.events;

import com.kisansetu.common.config.RabbitMqConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
public class DomainEventPublisher {

    private static final Logger log = LoggerFactory.getLogger(DomainEventPublisher.class);
    private final Optional<RabbitTemplate> rabbitTemplate;

    public DomainEventPublisher(Optional<RabbitTemplate> rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    public void publish(String routingKey, String eventType, Map<String, Object> payload) {
        Map<String, Object> envelope = new HashMap<>();
        envelope.put("eventId", UUID.randomUUID().toString());
        envelope.put("eventType", eventType);
        envelope.put("routingKey", routingKey);
        envelope.put("occurredAt", Instant.now().toString());
        envelope.put("version", "1.0");
        envelope.put("payload", payload);

        rabbitTemplate.ifPresentOrElse(
                template -> {
                    try {
                        template.convertAndSend(RabbitMqConfig.EXCHANGE_KISANSETU_EVENTS, routingKey, envelope);
                        log.info("Published domain event [{}] to exchange [{}]", routingKey, RabbitMqConfig.EXCHANGE_KISANSETU_EVENTS);
                    } catch (Exception ex) {
                        log.warn("RabbitMQ unavailable, logged domain event [{}]: {}", routingKey, ex.getMessage());
                    }
                },
                () -> log.info("Test/Offline mode - domain event [{}] recorded: {}", routingKey, payload)
        );
    }
}
