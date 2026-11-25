package com.kisansetu.common.events;

import com.kisansetu.common.config.RabbitMqConfig;
import com.kisansetu.modules.operations.entity.NotificationRecord;
import com.kisansetu.modules.operations.entity.ProcessedEvent;
import com.kisansetu.modules.operations.repository.NotificationRecordRepository;
import com.kisansetu.modules.operations.repository.ProcessedEventRepository;
import com.kisansetu.modules.operations.service.StockConservationService;
import com.kisansetu.modules.settlement.entity.Settlement;
import com.kisansetu.modules.settlement.repository.SettlementRepository;
import com.kisansetu.modules.user.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@Component
@Profile("!test")
public class DomainEventConsumer {

    private static final Logger log = LoggerFactory.getLogger(DomainEventConsumer.class);

    private final ProcessedEventRepository processedEventRepo;
    private final NotificationRecordRepository notificationRepo;
    private final StockConservationService stockService;
    private final SettlementRepository settlementRepo;
    private final UserRepository userRepo;

    public DomainEventConsumer(ProcessedEventRepository processedEventRepo,
                               NotificationRecordRepository notificationRepo,
                               StockConservationService stockService,
                               SettlementRepository settlementRepo,
                               UserRepository userRepo) {
        this.processedEventRepo = processedEventRepo;
        this.notificationRepo = notificationRepo;
        this.stockService = stockService;
        this.settlementRepo = settlementRepo;
        this.userRepo = userRepo;
    }

    @RabbitListener(queues = RabbitMqConfig.QUEUE_DOMAIN_EVENTS)
    @Transactional
    public void handleDomainEvent(Map<String, Object> envelope) {
        if (envelope == null) return;
        String eventId = String.valueOf(envelope.getOrDefault("eventId", UUID.randomUUID().toString()));
        String routingKey = String.valueOf(envelope.getOrDefault("routingKey", ""));
        String eventType = String.valueOf(envelope.getOrDefault("eventType", routingKey));

        // Idempotency guard
        if (processedEventRepo.existsById(eventId)) {
            log.debug("Skipping already processed event {}", eventId);
            return;
        }

        @SuppressWarnings("unchecked")
        Map<String, Object> payload = (Map<String, Object>) envelope.get("payload");
        if (payload == null) payload = Map.of();

        processByRoutingKey(routingKey, payload);
        processedEventRepo.save(new ProcessedEvent(eventId, eventType));
    }

    @Transactional
    public void processByRoutingKey(String routingKey, Map<String, Object> payload) {
        switch (routingKey) {
            case "kyc.approved", "kyc.rejected" -> {
                String farmerIdStr = str(payload.get("farmerId"));
                if (farmerIdStr != null) {
                    NotificationRecord n = new NotificationRecord();
                    n.setUserId(UUID.fromString(farmerIdStr));
                    n.setType("KYC_UPDATE");
                    boolean approved = "kyc.approved".equals(routingKey);
                    n.setTitle(approved ? "KYC Verified" : "KYC Rejected");
                    n.setMessage(approved
                            ? "Your KYC verification is approved. You can now publish produce listings."
                            : "Your KYC submission was rejected. Please review remarks and resubmit.");
                    notificationRepo.save(n);
                }
            }
            case "order.created" -> {
                String customerIdStr = str(payload.get("customerId"));
                String orderNo = str(payload.get("orderNumber"));
                if (customerIdStr != null) {
                    NotificationRecord n = new NotificationRecord();
                    n.setUserId(UUID.fromString(customerIdStr));
                    n.setType("ORDER");
                    n.setTitle("Order Placed: " + (orderNo != null ? orderNo : ""));
                    n.setMessage("Your order has been created and stock is reserved.");
                    notificationRepo.save(n);
                }
            }
            case "payment.succeeded" -> {
                String customerIdStr = str(payload.get("customerId"));
                String orderIdStr = str(payload.get("orderId"));
                if (customerIdStr != null) {
                    NotificationRecord n = new NotificationRecord();
                    n.setUserId(UUID.fromString(customerIdStr));
                    n.setType("PAYMENT");
                    n.setTitle("Payment Confirmed");
                    n.setMessage("Payment verified for order " + orderIdStr);
                    notificationRepo.save(n);
                }
            }
            case "quality.completed" -> {
                String inspId = str(payload.get("inspectionId"));
                String prodId = str(payload.get("productId"));
                String acceptedStr = str(payload.get("acceptedKg"));
                if (inspId != null && prodId != null && acceptedStr != null) {
                    stockService.recordQualityInbound(UUID.fromString(inspId), UUID.fromString(prodId), new BigDecimal(acceptedStr));
                }
            }
            case "settlement.authorized" -> {
                String farmerIdStr = str(payload.get("farmerId"));
                String netAmount = str(payload.get("netAmount"));
                if (farmerIdStr != null) {
                    NotificationRecord n = new NotificationRecord();
                    n.setUserId(UUID.fromString(farmerIdStr));
                    n.setType("SETTLEMENT");
                    n.setTitle("Settlement Authorized");
                    n.setMessage("DBT settlement of INR " + (netAmount != null ? netAmount : "0") + " has been authorized.");
                    notificationRepo.save(n);
                }
            }
            case "demand.accepted", "collection.scheduled", "shipment.created", "inventory.updated" ->
                    log.info("Processed supply-chain event [{}]", routingKey);
            default -> log.debug("Unhandled domain event routingKey [{}]", routingKey);
        }
    }

    private String str(Object val) {
        return val != null ? val.toString() : null;
    }
}
