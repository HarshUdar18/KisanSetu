# FARMER-TO-CUSTOMER AGRICULTURAL SUPPLY CHAIN PLATFORM (KisanSetu / KrishiConnect)

> **Phase 3 — Complete Customer Flutter App Complete**  
> Direct farm-to-consumer agricultural supply chain platform developed for single-laptop development. Complete customer journey from onboarding to order fulfillment, dynamic market pricing, weekly produce basket planning, mock payment, and 9-stage supply chain tracking connected to Spring Boot backend.  
> 
> 📋 **Comprehensive Inventory**: See [PROJECT_INVENTORY.md](file:///c:/Users/harsh/Downloads/KisanSetu/PROJECT_INVENTORY.md) for an exhaustive technical inventory of all frameworks, libraries, modules, database migrations, API contracts, and configs used in this repository.


---

## 🏛️ System Topology

```
                  CUSTOMER MOBILE APP (Flutter)
                               │
                               ▼
               SPRING BOOT MODULAR MONOLITH
              (/api/v1/ REST & Spring Security)
                               │
            ┌──────────────────┼──────────────────┐
            ▼                  ▼                  ▼
     PostgreSQL 16          Redis 7         RabbitMQ 3.13
    (PostGIS-Ready)     (Cache & Rate)     (Message Broker)
            ▲
            │
               SPRING BOOT MODULAR MONOLITH
                               ▲
                               │
                   FARMER MOBILE APP (Flutter)

                               ▲
                               │
                   ADMIN WEB PANEL (React)
```

**CRITICAL DECISION**:
- Two **completely separate** Flutter applications (`apps/customer-app` and `apps/farmer-app`). No single app with role switching.
- Both mobile apps and the Admin Web panel talk to the **same Spring Boot backend** and share the **same PostgreSQL database**.
- A single person can hold both `ROLE_CUSTOMER` and `ROLE_FARMER` on their unified `users` record.

---

## 📁 Repository Structure

```
KisanSetu/
├── apps/
│   ├── customer-app/                  # Separate Customer Flutter Application
│   │   ├── lib/
│   │   │   ├── core/                  # config, network, theme, storage
│   │   │   └── features/              # auth, home, profile (Riverpod + GoRouter)
│   │   └── pubspec.yaml
│   ├── farmer-app/                    # Separate Farmer Flutter Application
│   │   ├── lib/
│   │   │   ├── core/                  # config, network, theme, storage
│   │   │   └── features/              # auth, dashboard, profile, produce (skeletons)
│   │   └── pubspec.yaml
│   └── admin-panel/                   # React 19 + TypeScript + Vite + MUI Admin Web
│       ├── src/
│       │   ├── api/                   # Axios client with JWT interceptor
│       │   ├── context/               # AuthContext (token & user state)
│       │   ├── pages/                 # Login & Dashboard
│       │   └── theme/                 # Forest Green MUI theme
│       └── package.json
├── backend/
│   └── spring-boot-application/       # Spring Boot 3.3.5 Modular Monolith (Java 17)
│       ├── pom.xml
│       ├── mvnw / mvnw.cmd
│       └── src/
│           ├── main/java/com/kisansetu/platform/
│           │   ├── common/            # Abstractions (Auth, Payment, Location, Storage, Notification)
│           │   └── modules/           # 26 Domain Modules (auth, user, customer, farmer...)
│           └── main/resources/
│               ├── application.yml
│               └── db/migration/      # Flyway Migrations V1 -> V6
├── ai-service/                        # Python FastAPI AI / RAG Foundation
│   ├── app/main.py                    # FastAPI app with /health endpoint
│   └── requirements.txt
├── infrastructure/
│   ├── docker/
│   │   └── docker-compose.yml         # PostgreSQL 16 (PostGIS), Redis 7, RabbitMQ 3.13
│   └── nginx/
│       └── nginx.conf                 # Reverse proxy configuration
├── docs/                              # Comprehensive Platform Documentation
│   ├── ARCHITECTURE.md                # System topology and domain boundaries
│   ├── LOCAL_SETUP.md                 # Single-laptop launch runbook
│   ├── DATABASE.md                    # Database schema, entities, and Flyway migrations
│   ├── API.md                         # REST v1 contract specification
│   ├── SECURITY.md                    # Spring Security, RBAC, and audit trail
│   ├── BUSINESS_RULES.md              # Agricultural supply chain logic
│   └── PHASE_ROADMAP.md               # Milestones from Phase 0 to Phase 5
├── scripts/                           # Single-Laptop Windows Helper Scripts
│   ├── start-infra.bat                # Start Docker containers
│   ├── start-backend.bat              # Start Spring Boot Modular Monolith
│   ├── start-customer-app.bat         # Start Customer Flutter Mobile App
│   ├── start-farmer-app.bat           # Start Farmer Flutter Mobile App
│   ├── start-admin.bat                # Start Admin Web Portal
│   └── start-ai.bat                   # Start FastAPI AI Service
├── docker-compose.yml                 # Root Docker Compose link
├── PROJECT_INVENTORY.md               # Exhaustive project & tech stack inventory
├── .env.example                       # Documented environment template
└── .gitignore                         # Multi-stack git exclusions
```

---

## 🔌 Development Port Matrix

| Service | Port | Description |
|---|---|---|
| **Spring Boot API** | `8080` | Modular Monolith API (`/api/v1`) |
| **PostgreSQL** | `5432` | Primary ACID relational database |
| **Redis** | `6379` | Cache, session, and rate-limiting store |
| **RabbitMQ** | `5672` | Event exchange broker |
| **RabbitMQ Management** | `15672` | Management console (`guest` / `guest`) |
| **FastAPI AI Service** | `8000` | Machine learning & RAG microservice |
| **Admin React Panel** | `5173` | Management web portal |
| **Customer App** | Flutter port | Connected physical device or emulator |
| **Farmer App** | Flutter port | Connected physical device or emulator |

---

## ⚡ Quick Start (Single Laptop Developer Experience)

### 1. Start Infrastructure
```powershell
.\scripts\start-infra.bat
# Or: docker compose up -d
```

### 2. Start Backend Modular Monolith
```powershell
.\scripts\start-backend.bat
# Or: cd backend\spring-boot-application && .\mvnw.cmd spring-boot:run
```
Flyway migrations `V1`–`V6` run automatically on boot.
- Swagger UI: [http://localhost:8080/swagger-ui/index.html](http://localhost:8080/swagger-ui/index.html)
- Health API: [http://localhost:8080/api/v1/health](http://localhost:8080/api/v1/health)

### 3. Start Customer App (Separate Flutter App)
```powershell
.\scripts\start-customer-app.bat
# Or: cd apps\customer-app && flutter run
```

### 4. Start Farmer App (Separate Flutter App)
```powershell
.\scripts\start-farmer-app.bat
# Or: cd apps\farmer-app && flutter run
```

### 5. Start Admin Web Panel
```powershell
.\scripts\start-admin.bat
# Or: cd apps\admin-panel && npm run dev
```
Open [http://localhost:5173](http://localhost:5173) in your browser.

### 6. Start AI Service (Optional)
```powershell
.\scripts\start-ai.bat
# Or: cd ai-service && uvicorn app.main:app --reload --port 8000
```
Health Check: [http://localhost:8000/health](http://localhost:8000/health)

---

## 🔑 Seed Accounts & Test Credentials

All accounts share the default development password: `password123`.

| Role | Phone | Email | Default Scope |
|---|---|---|---|
| **Admin** | `9876543210` | `admin@kisansetu.local` | Platform-wide Admin access |
| **Customer** | `9876543211` | `customer@kisansetu.local` | Consumer shopping & delivery |
| **Farmer** | `9876543212` | `farmer@kisansetu.local` | Farm inventory & settlement |

### Mock OTP Fallback
For local development and testing, entering **`123456`** succeeds for any phone number. The generated 6-digit OTP is also output to the Spring Boot console.

---

## 🧪 Verification & Test Execution

- **Spring Boot Backend**:
  ```powershell
  cd backend\spring-boot-application
  .\mvnw.cmd test
  ```
  *Result: 5 tests passed (Context, JWT, BCrypt, ServiceArea check).*

- **Customer Flutter App**:
  ```powershell
  cd apps\customer-app
  flutter test
  flutter analyze
  ```
  *Result: 0 errors, 0 warnings.*

- **Farmer Flutter App**:
  ```powershell
  cd apps\farmer-app
  flutter test
  flutter analyze
  ```
  *Result: 0 errors, 0 warnings.*

- **Admin Web Panel**:
  ```powershell
  cd apps\admin-panel
  npm run build
  ```
  *Result: Vite production build completed with 0 errors.*
