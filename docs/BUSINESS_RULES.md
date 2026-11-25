# BUSINESS_RULES.md — Kisan Setu Business Logic

**Date:** 2026-11-25

This document defines the business rules that must be enforced at the backend layer.

---

## 1. User & Authentication Rules

| Rule ID | Rule | Enforcement Point |
|---------|------|------------------|
| AUTH-01 | Phone number must be a valid 10-digit Indian mobile number | auth-service registration |
| AUTH-02 | Password must be minimum 8 characters | auth-service registration |
| AUTH-03 | OTP expires after 5 minutes | auth-service OTP flow |
| AUTH-04 | OTP is a 6-digit code (dev mode: 123456 always valid) | auth-service |
| AUTH-05 | User can register as CUSTOMER or FARMER only via app; ADMIN role assigned manually | auth-service |
| AUTH-06 | Duplicate phone number registration is rejected | auth-service |
| AUTH-07 | JWT access token expires in 24 hours | auth-service JWT issue |
| AUTH-08 | Refresh token expires in 30 days and is single-use | auth-service refresh |

---

## 2. KYC Rules

| Rule ID | Rule | Enforcement Point |
|---------|------|------------------|
| KYC-01 | Farmer must complete KYC before creating produce listings | produce-service |
| KYC-02 | KYC status transitions: `NOT_SUBMITTED → UNDER_REVIEW → VERIFIED / REJECTED` | kyc-service |
| KYC-03 | Rejected KYC can be resubmitted with corrected documents | kyc-service |
| KYC-04 | Admin must approve KYC before `VERIFIED` status is set | kyc-service |
| KYC-05 | Only one active KYC submission per farmer at a time | kyc-service |

---

## 3. Produce Listing Rules

| Rule ID | Rule | Enforcement Point |
|---------|------|------------------|
| PROD-01 | Only KYC-verified farmers can create listings | produce-service |
| PROD-02 | Listing quantity must be greater than 0 kg | produce-service |
| PROD-03 | Listing price must be greater than 0 | produce-service |
| PROD-04 | Harvest date cannot be more than 30 days in the future | produce-service |
| PROD-05 | Farmer can have maximum 50 active listings | produce-service |
| PROD-06 | Listing becomes inactive when quantity reaches 0 | inventory-service event |

---

## 4. Cart Rules

| Rule ID | Rule | Enforcement Point |
|---------|------|------------------|
| CART-01 | Maximum 50 items in a single cart | cart-service |
| CART-02 | Minimum order quantity per product: 0.25 kg | cart-service |
| CART-03 | Maximum order quantity per product: 50 kg per order | cart-service |
| CART-04 | Cart price is refreshed from product-service on checkout | order-service |
| CART-05 | Products not available (isAvailable=false) cannot be added to cart | cart-service |
| CART-06 | Weekly cart cannot have same product in overlapping days | cart-service |

---

## 5. Order Rules

| Rule ID | Rule | Enforcement Point |
|---------|------|------------------|
| ORD-01 | Customer must have at least one verified delivery address to checkout | order-service |
| ORD-02 | Delivery date must be minimum 1 day in the future | order-service |
| ORD-03 | Delivery slots: MORNING_6_9, MORNING_9_12, AFTERNOON_12_3, EVENING_3_6 | order-service |
| ORD-04 | Order status transitions: `PENDING_PAYMENT → CONFIRMED → PROCESSING → DISPATCHED → DELIVERED` | order-service |
| ORD-05 | Order cancellation allowed only in `PENDING_PAYMENT` or `CONFIRMED` status | order-service |
| ORD-06 | Cancelled order triggers inventory release event | order-service → RabbitMQ |
| ORD-07 | Minimum order value: ₹100 | order-service |
| ORD-08 | Platform fee: 5% of subtotal | order-service |
| ORD-09 | Free delivery for orders above ₹499; ₹20 delivery charge otherwise | order-service |
| ORD-10 | GST: 0% on fresh produce; 5% on processed products | order-service |

---

## 6. Payment Rules

| Rule ID | Rule | Enforcement Point |
|---------|------|------------------|
| PAY-01 | Payment must be completed within 15 minutes of order creation | payment-service (TTL) |
| PAY-02 | Failed payments auto-cancel the order after 3 retry attempts | payment-service |
| PAY-03 | Razorpay webhook signature must be verified before processing | payment-service |
| PAY-04 | Duplicate webhook events are idempotent (re-processing is a no-op) | payment-service |
| PAY-05 | Refund can only be initiated for DELIVERED orders within 24 hours | payment-service |
| PAY-06 | Partial refund not supported (full order refund only) | payment-service |

---

## 7. Settlement Rules

| Rule ID | Rule | Enforcement Point |
|---------|------|------------------|
| SET-01 | Settlement is created when order is marked DELIVERED | settlement-service (event) |
| SET-02 | Settlement amount = order item subtotal × farmer share (80%) | settlement-service |
| SET-03 | Platform retains 20% of produce value as commission | settlement-service |
| SET-04 | Settlement is released to farmer DBT only after Admin Finance authorization | settlement-service |
| SET-05 | Settlements are batched weekly (every Monday) for authorized DBT | settlement-service |
| SET-06 | Farmer must have verified bank account (from KYC) to receive settlement | settlement-service |
| SET-07 | Settlement status: `PENDING → AUTHORIZED → PAID / FAILED` | settlement-service |

---

## 8. Quality & Collection Rules

| Rule ID | Rule | Enforcement Point |
|---------|------|------------------|
| QC-01 | Quality grade: GRADE_A, GRADE_B, GRADE_C, REJECTED | quality-service |
| QC-02 | REJECTED produce does not enter inventory | quality-service → inventory |
| QC-03 | Settlement price adjusts based on grade: GRADE_A = full price, GRADE_B = 85%, GRADE_C = 70% | settlement-service |
| QC-04 | Collection requires a valid gate pass with vehicle number | collection-service |
| QC-05 | Weighbridge weight is authoritative over farmer-declared quantity | quality-service |

---

## 9. Subscription Rules

| Rule ID | Rule | Enforcement Point |
|---------|------|------------------|
| SUB-01 | Subscription can be DAILY, ALTERNATE_DAYS, WEEKLY | cart-service |
| SUB-02 | Minimum subscription duration: 7 days | cart-service |
| SUB-03 | Subscription can be paused for maximum 30 days | cart-service |
| SUB-04 | Paused subscription auto-resumes after pause duration | cart-service (scheduler) |
| SUB-05 | Subscription generates a standing order each delivery day | order-service (scheduler) |

---

## 10. Serviceability Rules

| Rule ID | Rule | Enforcement Point |
|---------|------|------------------|
| SVC-01 | Customer pincode must be in a served service area | order-service |
| SVC-02 | Service areas are managed by admin via /service-areas | product-service |
| SVC-03 | Products not available in a service area cannot be ordered | product-service |
| SVC-04 | Customer is shown "Not serviceable" if their pincode is out of coverage | customer-app (serviceability screen) |

---

## 11. Data Retention Rules

| Entity | Retention | Rule |
|--------|-----------|------|
| Orders | 7 years | Legal / GST compliance |
| Payments | 7 years | Financial audit |
| Audit logs | 3 years | Compliance |
| OTP sessions | 10 minutes | Privacy |
| Deleted user data | 30 days soft delete | DPDP Act (India) |
| Support tickets | 2 years | Quality assurance |
