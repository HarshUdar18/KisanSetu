# DEPLOYMENT_GUIDE.md — Kisan Setu Deployment Guide

**Date:** 2026-11-25

## Environments

| Environment | Purpose | URL |
|-------------|---------|-----|
| Local Dev | Individual developer machine | localhost:* |
| Staging | Pre-production testing | staging.kisansetu.in |
| Production | Live platform | kisansetu.in |

---

## Local Development Setup

### Prerequisites
```powershell
# Check versions
node --version        # Requires v20+
flutter --version     # Requires 3.10+
java --version        # Requires JDK 21
docker --version      # Requires 24+
mvn --version         # Requires Maven 3.9+
```

### Step 1: Clone and Setup
```powershell
git clone https://github.com/your-org/kisansetu.git
cd kisansetu

# Copy environment file
Copy-Item .env.example .env
# Edit .env with your values
```

### Step 2: Start Infrastructure
```powershell
docker-compose up -d
# Wait ~30 seconds for PostgreSQL to initialize
docker-compose ps
```

### Step 3: Start Backend
```powershell
cd backend\spring-boot-application
# Backend applies Flyway migrations automatically on startup
.\mvnw spring-boot:run
# Backend starts at http://localhost:8080
# Swagger UI: http://localhost:8080/swagger-ui.html
```

### Step 4: Start Admin Panel
```powershell
cd apps\admin-panel
npm install
npm run dev
# Admin Panel: http://localhost:5173
# Login: 9876543210 / password123
```

### Step 5: Run Flutter Apps
```powershell
# Customer App
cd apps\customer-app
flutter pub get
flutter run   # Select Android emulator/device
# Login: 9876543211 / password123

# Farmer App (separate terminal)
cd apps\farmer-app
flutter pub get
flutter run
# Login: 9876543212 / password123
```

---

## Backend Build & Run

```powershell
# Clean build
cd backend\spring-boot-application
.\mvnw clean package -DskipTests

# Run JAR directly
java -jar target\kisansetu-backend-1.0.0.jar

# Run with environment overrides
java -Dspring.profiles.active=prod \
     -DPOSTGRES_HOST=prod-db.kisansetu.in \
     -DJWT_SECRET=your-prod-secret \
     -jar target\kisansetu-backend-1.0.0.jar
```

---

## Admin Panel Build & Deploy

```powershell
cd apps\admin-panel
npm run build
# Output in dist/ directory
# Deploy dist/ to any static hosting (Nginx, CloudFront, Firebase Hosting)

# Update API base URL for production
# Edit src/api/client.ts: baseURL = 'https://api.kisansetu.in/api/v1'
```

---

## Flutter App Build

```powershell
# Customer App — Debug APK
cd apps\customer-app
flutter build apk --debug

# Customer App — Release APK
flutter build apk --release

# Farmer App
cd apps\farmer-app
flutter build apk --release

# APK location: build\app\outputs\flutter-apk\app-release.apk
```

---

## Production Deployment Checklist

### Backend
- [ ] Set `JWT_SECRET` to a strong random secret (never use default)
- [ ] Set `spring.jpa.hibernate.ddl-auto=validate`
- [ ] Set `spring.flyway.enabled=true`
- [ ] Configure production PostgreSQL host/credentials
- [ ] Configure production Redis host
- [ ] Configure production RabbitMQ host
- [ ] Enable HTTPS (TLS certificate)
- [ ] Update CORS to allow only production origins
- [ ] Set `logging.level.root=WARN` in production
- [ ] Configure Spring Boot Actuator with authentication

### Admin Panel
- [ ] Update `VITE_API_BASE_URL` to production API URL
- [ ] Enable CSP headers on the web server
- [ ] Deploy behind CDN with cache headers for static assets

### Flutter Apps
- [ ] Update `AppConfig.apiBaseUrl` to production API URL
- [ ] Sign Android APK with release keystore
- [ ] Configure Firebase for production FCM project
- [ ] Enable ProGuard/R8 minification

---

## Database Backup

```powershell
# Full backup
docker exec kisansetu-postgres pg_dump -U kisansetu_user kisansetu_db > backup_$(Get-Date -Format 'yyyyMMdd').sql

# Restore
docker exec -i kisansetu-postgres psql -U kisansetu_user kisansetu_db < backup_20261125.sql
```

---

## Monitoring

| Metric | Endpoint | Tool |
|--------|---------|------|
| Backend Health | GET /actuator/health | Spring Actuator |
| Backend Metrics | GET /actuator/metrics | Spring Actuator + Prometheus |
| API Docs | GET /swagger-ui.html | SpringDoc OpenAPI |
| RabbitMQ | http://localhost:15672 | RabbitMQ Management |
| PostgreSQL | pg_stat_activity | pgAdmin or Datadog |
