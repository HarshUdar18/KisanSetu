# EVENT_CONTRACTS.md — RabbitMQ Event Contracts

**Date:** 2026-11-25  
**Exchange:** `kisansetu.events` (Topic exchange, durable)  
**DLQ:** `kisansetu.dlq` (Dead letter queue for failed processing)

---

## Exchange Configuration

```java
// RabbitMQ Topology
Exchange: kisansetu.events (TOPIC, durable=true)
DLX:      kisansetu.dlx (DIRECT, durable=true)
DLQ:      kisansetu.dlq (durable=true)
```

---

## Event Schema Standards

All events follow this envelope:
```json
{
  "eventId": "uuid-v4",
  "eventType": "com.kisansetu.events.UserRegistered",
  "routingKey": "user.registered",
  "occurredAt": "2026-11-25T10:00:00Z",
  "version": "1.0",
  "payload": { }
}
```

---

## Event Catalog

### 1. `UserRegistered`
**Routing Key:** `user.registered`  
**Publisher:** auth-service  
**Consumers:** user-service, notification-service  
```json
{
  "eventType": "com.kisansetu.events.UserRegistered",
  "payload": {
    "userId": "uuid",
    "fullName": "Ananya Sharma",
    "phone": "9876543211",
    "email": "ananya@example.com",
    "role": "CUSTOMER",
    "registeredAt": "2026-11-25T10:00:00Z"
  }
}
```

### 2. `KycSubmitted`
**Routing Key:** `kyc.submitted`  
**Publisher:** kyc-service  
**Consumers:** notification-service (notify admin)  
```json
{
  "payload": {
    "submissionId": "uuid",
    "farmerId": "uuid",
    "farmerName": "Tukaram Patil",
    "documentType": "AADHAAR",
    "submittedAt": "2026-11-25T10:00:00Z"
  }
}
```

### 3. `KycApproved`
**Routing Key:** `kyc.approved`  
**Publisher:** kyc-service  
**Consumers:** farmer-service (unlock produce listing), notification-service  
```json
{
  "payload": {
    "submissionId": "uuid",
    "farmerId": "uuid",
    "reviewedBy": "admin-uuid",
    "approvedAt": "2026-11-25T12:00:00Z"
  }
}
```

### 4. `KycRejected`
**Routing Key:** `kyc.rejected`  
**Publisher:** kyc-service  
**Consumers:** notification-service  
```json
{
  "payload": {
    "submissionId": "uuid",
    "farmerId": "uuid",
    "rejectionReason": "Blurry Aadhaar image",
    "rejectedAt": "2026-11-25T12:00:00Z"
  }
}
```

### 5. `ProduceListed`
**Routing Key:** `produce.listed`  
**Publisher:** produce-service  
**Consumers:** demand-service (match demands), notification-service  
```json
{
  "payload": {
    "listingId": "uuid",
    "farmerId": "uuid",
    "farmerName": "Tukaram Patil",
    "productId": "uuid",
    "productName": "Desi Tomatoes",
    "quantityKg": 500.0,
    "pricePerKg": 28.00,
    "harvestDate": "2026-11-26",
    "pincode": "412205"
  }
}
```

### 6. `DemandCreated`
**Routing Key:** `demand.created`  
**Publisher:** demand-service  
**Consumers:** notification-service (notify matching farmers), produce-service  
```json
{
  "payload": {
    "demandId": "uuid",
    "requesterId": "uuid",
    "productId": "uuid",
    "productName": "Desi Tomatoes",
    "quantityKg": 100.0,
    "targetPricePerKg": 30.00,
    "requiredByDate": "2026-12-01"
  }
}
```

### 7. `DemandAccepted`
**Routing Key:** `demand.accepted`  
**Publisher:** demand-service  
**Consumers:** order-service (create demand order), notification-service  
```json
{
  "payload": {
    "demandId": "uuid",
    "farmerId": "uuid",
    "requesterId": "uuid",
    "listingId": "uuid",
    "agreedPricePerKg": 29.00,
    "confirmedQuantityKg": 80.0,
    "deliveryDate": "2026-11-28"
  }
}
```

### 8. `OrderCreated`
**Routing Key:** `order.created`  
**Publisher:** order-service  
**Consumers:** payment-service (prompt payment), inventory-service (reserve stock), notification-service  
```json
{
  "payload": {
    "orderId": "uuid",
    "orderNumber": "KS-2045",
    "customerId": "uuid",
    "totalAmount": 87.50,
    "currency": "INR",
    "items": [
      { "productId": "uuid", "quantity": 2.0, "unit": "kg", "pricePerUnit": 32.50 }
    ],
    "deliveryAddressId": "uuid",
    "deliveryDate": "2026-11-26",
    "createdAt": "2026-11-25T10:00:00Z"
  }
}
```

### 9. `PaymentInitiated`
**Routing Key:** `payment.initiated`  
**Publisher:** payment-service  
**Consumers:** order-service (update status to PENDING_PAYMENT)  
```json
{
  "payload": {
    "paymentId": "uuid",
    "orderId": "uuid",
    "amount": 87.50,
    "method": "UPI",
    "gatewayOrderId": "order_rzp_xxx",
    "initiatedAt": "2026-11-25T10:05:00Z"
  }
}
```

### 10. `PaymentSucceeded`
**Routing Key:** `payment.succeeded`  
**Publisher:** payment-service  
**Consumers:** order-service (confirm order), settlement-service (create settlement), notification-service  
```json
{
  "payload": {
    "paymentId": "uuid",
    "orderId": "uuid",
    "customerId": "uuid",
    "amount": 87.50,
    "gatewayTransactionId": "pay_rzp_xxx",
    "paidAt": "2026-11-25T10:06:00Z"
  }
}
```

### 11. `PaymentFailed`
**Routing Key:** `payment.failed`  
**Publisher:** payment-service  
**Consumers:** order-service (mark order PAYMENT_FAILED), inventory-service (release reservation), notification-service  
```json
{
  "payload": {
    "paymentId": "uuid",
    "orderId": "uuid",
    "reason": "Insufficient funds",
    "failedAt": "2026-11-25T10:06:00Z"
  }
}
```

### 12. `OrderConfirmed`
**Routing Key:** `order.confirmed`  
**Publisher:** order-service  
**Consumers:** logistics-service (create delivery), collection-service (notify collection center), notification-service  
```json
{
  "payload": {
    "orderId": "uuid",
    "orderNumber": "KS-2045",
    "customerId": "uuid",
    "farmerIds": ["uuid1", "uuid2"],
    "deliveryAddressId": "uuid",
    "deliveryDate": "2026-11-26",
    "confirmedAt": "2026-11-25T10:06:00Z"
  }
}
```

### 13. `OrderDispatched`
**Routing Key:** `order.dispatched`  
**Publisher:** logistics-service  
**Consumers:** notification-service  
```json
{
  "payload": {
    "orderId": "uuid",
    "deliveryPersonId": "uuid",
    "estimatedArrival": "2026-11-26T08:00:00Z",
    "dispatchedAt": "2026-11-26T06:00:00Z"
  }
}
```

### 14. `OrderDelivered`
**Routing Key:** `order.delivered`  
**Publisher:** logistics-service  
**Consumers:** order-service (mark DELIVERED), settlement-service (finalize settlement), notification-service  
```json
{
  "payload": {
    "orderId": "uuid",
    "customerId": "uuid",
    "deliveredAt": "2026-11-26T08:30:00Z",
    "proofOfDeliveryUrl": "https://..."
  }
}
```

### 15. `SettlementAuthorized`
**Routing Key:** `settlement.authorized`  
**Publisher:** settlement-service  
**Consumers:** notification-service (notify farmer of incoming payment)  
```json
{
  "payload": {
    "settlementId": "uuid",
    "farmerId": "uuid",
    "amount": 580.00,
    "bankAccount": "XXXX1234",
    "authorizedBy": "admin-uuid",
    "authorizedAt": "2026-11-27T09:00:00Z"
  }
}
```

### 16. `CollectionCreated`
**Routing Key:** `collection.created`  
**Publisher:** collection-service  
**Consumers:** inventory-service (add to warehouse stock), quality-service (trigger inspection)  
```json
{
  "payload": {
    "collectionId": "uuid",
    "farmerId": "uuid",
    "listingId": "uuid",
    "productId": "uuid",
    "quantityKg": 450.0,
    "collectionPointId": "uuid",
    "arrivedAt": "2026-11-25T07:00:00Z"
  }
}
```

### 17. `QualityInspected`
**Routing Key:** `quality.inspected`  
**Publisher:** quality-service  
**Consumers:** inventory-service (grade-based stock update), settlement-service (grade affects price)  
```json
{
  "payload": {
    "inspectionId": "uuid",
    "collectionId": "uuid",
    "farmerId": "uuid",
    "productId": "uuid",
    "gradeAssigned": "GRADE_A",
    "approvedQuantityKg": 440.0,
    "rejectedQuantityKg": 10.0,
    "inspectedAt": "2026-11-25T09:00:00Z"
  }
}
```

### 18. `InventoryUpdated`
**Routing Key:** `inventory.updated`  
**Publisher:** inventory-service  
**Consumers:** produce-service (sync availability), demand-service (check if demand can be fulfilled)  
```json
{
  "payload": {
    "productId": "uuid",
    "warehouseId": "uuid",
    "previousStockKg": 1000.0,
    "currentStockKg": 1440.0,
    "changeType": "INBOUND",
    "updatedAt": "2026-11-25T09:30:00Z"
  }
}
```

---

## Queue Bindings

```
Queue: auth.user.registered         → kisansetu.events # user.registered
Queue: farmer.kyc.approved          → kisansetu.events # kyc.approved
Queue: produce.kyc.approved         → kisansetu.events # kyc.approved
Queue: notification.all             → kisansetu.events # #
Queue: inventory.order.created      → kisansetu.events # order.created
Queue: order.payment.succeeded      → kisansetu.events # payment.succeeded
Queue: settlement.payment.succeeded → kisansetu.events # payment.succeeded
Queue: logistics.order.confirmed    → kisansetu.events # order.confirmed
Queue: settlement.order.delivered   → kisansetu.events # order.delivered
Queue: inventory.quality.inspected  → kisansetu.events # quality.inspected
```

---

## Dead Letter Queue Policy

Events that fail processing after 3 retries are routed to `kisansetu.dlq` with:
- Original routing key preserved
- Failure reason in headers
- Retry count in headers
- Original payload intact

An admin dashboard reads DLQ entries for manual investigation.
