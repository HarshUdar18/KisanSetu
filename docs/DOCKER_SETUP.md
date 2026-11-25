# DOCKER_SETUP.md — Docker Infrastructure Guide

**Date:** 2026-11-25

## Overview

Kisan Setu uses Docker and Docker Compose for local development. The infrastructure consists of:
- PostgreSQL 16 (PostGIS) — primary database
- Redis 7 — caching and session management
- RabbitMQ 3.13 — event-driven messaging
- Spring Boot monolith (backend)

---

## Quick Start

```powershell
# 1. Start all infrastructure services
docker-compose up -d

# 2. Wait for services to be healthy
docker-compose ps

# 3. Start the backend (from backend directory)
cd backend\spring-boot-application
mvnw spring-boot:run

# 4. Start Admin Panel (from admin-panel directory)
cd apps\admin-panel
npm run dev

# 5. Start Customer App (Android)
cd apps\customer-app
flutter run

# 6. Start Farmer App (Android)
cd apps\farmer-app
flutter run
```

---

## docker-compose.yml (Root — Infrastructure Only)

The root `docker-compose.yml` runs infrastructure services only:

```yaml
version: '3.8'

services:
  postgres:
    image: postgis/postgis:16-3.4-alpine
    container_name: kisansetu-postgres
    ports: ["5432:5432"]
    environment:
      POSTGRES_DB: kisansetu_db
      POSTGRES_USER: kisansetu_user
      POSTGRES_PASSWORD: kisansetu_secret
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U kisansetu_user -d kisansetu_db"]
      interval: 10s; timeout: 5s; retries: 5

  redis:
    image: redis:7-alpine
    container_name: kisansetu-redis
    ports: ["6379:6379"]
    volumes: [redis_data:/data]

  rabbitmq:
    image: rabbitmq:3.13-management-alpine
    container_name: kisansetu-rabbitmq
    ports: ["5672:5672", "15672:15672"]
    environment:
      RABBITMQ_DEFAULT_USER: kisansetu
      RABBITMQ_DEFAULT_PASS: kisansetu_secret

volumes:
  postgres_data:
  redis_data:
  rabbitmq_data:
```

---

## Full Platform Docker Compose (Future)

Located at `infrastructure/docker/docker-compose.yml` — runs all services including the backend:

```yaml
version: '3.8'

services:
  # Infrastructure
  postgres: ...
  redis: ...
  rabbitmq: ...

  # Backend (Monolith)
  backend:
    build: ../../backend/spring-boot-application
    container_name: kisansetu-backend
    ports: ["8080:8080"]
    environment:
      POSTGRES_HOST: postgres
      POSTGRES_PORT: 5432
      POSTGRES_DB: kisansetu_db
      POSTGRES_USER: kisansetu_user
      POSTGRES_PASSWORD: kisansetu_secret
      REDIS_HOST: redis
      RABBITMQ_HOST: rabbitmq
      JWT_SECRET: 404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
    depends_on:
      postgres: { condition: service_healthy }
      redis: { condition: service_healthy }
      rabbitmq: { condition: service_healthy }
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s; timeout: 10s; retries: 3
```

---

## Environment Variables

Create `.env` file at workspace root (do not commit to git):

```dotenv
# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=kisansetu_db
POSTGRES_USER=kisansetu_user
POSTGRES_PASSWORD=kisansetu_secret

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# RabbitMQ
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USER=kisansetu
RABBITMQ_PASSWORD=kisansetu_secret
RABBITMQ_MGMT_PORT=15672

# JWT
JWT_SECRET=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
JWT_EXPIRATION_MS=86400000

# Backend
BACKEND_PORT=8080
```

---

## Service URLs (Local Development)

| Service | URL | Credentials |
|---------|-----|-------------|
| Backend API | http://localhost:8080/api/v1 | JWT auth |
| Swagger UI | http://localhost:8080/swagger-ui.html | None |
| Admin Panel | http://localhost:5173 | admin/password123 |
| PostgreSQL | localhost:5432 | kisansetu_user/kisansetu_secret |
| Redis | localhost:6379 | No auth |
| RabbitMQ Management | http://localhost:15672 | kisansetu/kisansetu_secret |

---

## Useful Commands

```powershell
# View logs for a service
docker-compose logs -f postgres
docker-compose logs -f rabbitmq

# Reset all data (WARNING: destructive)
docker-compose down -v

# Connect to PostgreSQL
docker exec -it kisansetu-postgres psql -U kisansetu_user -d kisansetu_db

# Connect to Redis CLI
docker exec -it kisansetu-redis redis-cli

# RabbitMQ management
# Open browser: http://localhost:15672 (kisansetu/kisansetu_secret)

# View all Flyway migrations applied
docker exec -it kisansetu-postgres psql -U kisansetu_user -d kisansetu_db \
  -c "SELECT version, description, installed_on, success FROM flyway_schema_history ORDER BY installed_rank;"
```

---

## Backend Dockerfile

Located at `backend/spring-boot-application/Dockerfile`:

```dockerfile
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY target/kisansetu-backend.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Build the JAR first:
```powershell
cd backend\spring-boot-application
mvnw clean package -DskipTests
docker build -t kisansetu-backend .
```

---

## Health Checks

```powershell
# Backend health
Invoke-WebRequest http://localhost:8080/actuator/health | ConvertFrom-Json

# PostgreSQL
docker exec kisansetu-postgres pg_isready -U kisansetu_user

# Redis
docker exec kisansetu-redis redis-cli ping

# RabbitMQ
docker exec kisansetu-rabbitmq rabbitmq-diagnostics ping
```
