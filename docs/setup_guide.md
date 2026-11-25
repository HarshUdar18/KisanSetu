# KisanSetu Single-Laptop Local Setup Guide

This guide describes how to run the complete KisanSetu platform on **ONE laptop**.

## Prerequisites Installed

* **Java**: OpenJDK 17 or higher
* **Flutter**: 3.38+ with Chrome / Android support
* **Docker & Docker Compose**: For PostgreSQL, Redis, and RabbitMQ
* **Maven Wrapper**: Bundled in `backend/mvnw.cmd` and `backend/mvnw`

---

## Step 1: Start Infrastructure via Docker Compose

In the root of the repository, execute:

```powershell
docker compose up -d postgres redis rabbitmq
```

To verify all 3 services are running and healthy:

```powershell
docker compose ps
```

* PostgreSQL: `localhost:5432` (database: `kisansetu_db`, user: `kisansetu_user`)
* Redis: `localhost:6379`
* RabbitMQ AMQP: `localhost:5672`
* RabbitMQ Management UI: [http://localhost:15672](http://localhost:15672) (user: `kisansetu`, pass: `kisansetu_secret`)

---

## Step 2: Start Spring Boot Backend

Open a terminal in `backend/` and execute:

```powershell
.\mvnw.cmd spring-boot:run
```

(On macOS/Linux: `./mvnw spring-boot:run`)

On startup:
* Flyway will automatically run migrations `V1__initial_schema.sql` and `V2__seed_initial_data.sql`.
* The server will start on port `8080`.
* Verify via browser or curl:
  * Health check: [http://localhost:8080/api/v1/health](http://localhost:8080/api/v1/health)
  * Swagger UI: [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
  * OpenAPI JSON: [http://localhost:8080/v3/api-docs](http://localhost:8080/v3/api-docs)

---

## Step 3: Run Flutter Application

Open a second terminal in `frontend/kisansetu_app` and execute:

```powershell
flutter run -d chrome
```

Or for Android Emulator:
```powershell
flutter run -d android
```

The Flutter app will open showing the KisanSetu Customer login/registration screen, live backend health monitoring pill, delivery PIN code verification, and Phase 1 customer catalog shell.

---

## Run Automated Test Suites

### Backend Unit & Integration Tests:
```powershell
cd backend
.\mvnw.cmd test
```
*(Runs completely in-memory using H2 test profile, passing without requiring external Docker services to be up).*

### Frontend Flutter Widget Tests & Linter:
```powershell
cd frontend\kisansetu_app
flutter test
flutter analyze
```
