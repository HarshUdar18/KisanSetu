# Security Architecture & Authorization

## Overview

The platform implements zero-trust defense-in-depth across API boundaries, relying on Spring Security, role-based access control (RBAC), stateless JWT authentication, and structured audit logs.

Clients (Customer App, Farmer App, Admin Web) connect to the identical Spring Boot backend over HTTPS/REST with role claims enforced on every HTTP call.

---

## Identity & Authentication

### 1. Unified Identity Model
All users authenticate via their phone number and/or email. User accounts exist only once in the `users` table, regardless of whether a user is a Customer, a Farmer, or an Admin.

### 2. Authentication Abstraction
Authentication is abstracted behind the `AuthenticationProvider` interface:
- **Phase 0**: `MockAuthenticationProvider` handles registrations, logins, and OTP simulations with console logging and dev fallbacks (`123456`).
- **Production Readiness**: Pluggable architecture ready for Firebase Phone Auth, AWS Cognito, or SMS gateway providers without altering controller contracts.

### 3. JWT Architecture
- **Stateless Tokens**: Issued upon successful authentication or OTP verification.
- **Payload**: Contains `sub` (User ID UUID), `phone` (Phone Number), and `roles` (Array of assigned role authorities).
- **Signature**: HMAC SHA-256 with key rotated through `JWT_SECRET` environment variable.
- **Expiration**: 24 hours standard validity.

---

## Authorization & Role Hierarchy

Role-based access control is enforced at both the filter chain level and the method security level via `@PreAuthorize`.

### Pre-defined Roles

| Role | Access Scope |
|---|---|
| `ROLE_CUSTOMER` | Browse catalog, place orders, view personal subscriptions & orders |
| `ROLE_FARMER` | List produce, view collection requests, check farm settlement ledgers |
| `ROLE_ADMIN` | Platform-wide management, service area configuration, user role assignment |
| `ROLE_COLLECTION_OPERATOR` | Manage collection center produce drop-offs |
| `ROLE_QUALITY` | Perform quality grades at collection points and warehouses |
| `ROLE_WAREHOUSE_OPERATOR` | Manage warehouse intake and cold storage sorting |
| `ROLE_HUB_OPERATOR` | Hub routing and dispatch sorting |
| `ROLE_DELIVERY_PARTNER` | Delivery routes and proof-of-delivery uploads |

### Critical Security Boundaries
- **Cross-Role Isolation**: Customer tokens cannot invoke Farmer-specific endpoints (`/api/v1/farmer/**`), and Farmer tokens cannot access Customer private data or Admin endpoints (`/api/v1/admin/**`).
- **Object-Level Protection**: Users can only read and mutate their own profile (`/api/v1/users/me`), orders, or farm records unless possessing elevated administrative privileges.
- **Backend Enforcement**: Flutter route guards exist solely for user navigation; all permissions are verified independently on the server side.

---

## Audit Logging

Every authentication, authorization, or administrative change is captured asynchronously through `AuditService` into `audit_logs`:
- Action names: `USER_REGISTERED`, `LOGIN_SUCCESS`, `LOGIN_FAILED`, `LOGOUT`, `ROLE_ASSIGNED`.
- Captured fields: User ID, Action, Entity Type, Entity ID, Timestamp, IP Address, and JSON metadata.
- **Credential Protection**: Passwords, OTP codes, and raw bearer tokens are strictly excluded from audit payloads.
