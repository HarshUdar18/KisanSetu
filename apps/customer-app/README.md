# Kisan Setu — Customer Mobile Application (Flutter)

Direct farm-to-kitchen agricultural marketplace connecting verified FPOs and farmers directly with household customers.

> **Exclusively for the Customer App** (`apps/customer-app`). Farmer App (`apps/farmer-app`) is untouched.

## Design System & Documentation
- [CUSTOMER_DESIGN_ANALYSIS.md](CUSTOMER_DESIGN_ANALYSIS.md)
- [CUSTOMER_DESIGN_SYSTEM.md](CUSTOMER_DESIGN_SYSTEM.md)
- [CUSTOMER_SCREEN_INVENTORY.md](CUSTOMER_SCREEN_INVENTORY.md)
- [CUSTOMER_NAVIGATION_FLOW.md](CUSTOMER_NAVIGATION_FLOW.md)
- [CUSTOMER_API_INTEGRATION.md](CUSTOMER_API_INTEGRATION.md)
- [CUSTOMER_SCREEN_IMPLEMENTATION_TRACKER.md](CUSTOMER_SCREEN_IMPLEMENTATION_TRACKER.md)

## Tech Stack
- **Flutter & Dart** (`sdk: ^3.10.4`) with Material Design 3
- **State Management**: `provider` (`MultiProvider` + `ChangeNotifier`)
- **Navigation**: `go_router` (5-tab `ShellRoute` + stack routes)
- **Networking**: `dio` with JWT Bearer interceptor (`/api/v1`)
- **Storage**: `flutter_secure_storage` (JWT tokens) & `shared_preferences` (language, theme, delivery location)

## Prerequisites & Setup
1. Start backend infrastructure & Spring Boot API (optional for local offline/mock fallback):
   ```powershell
   .\scripts\start-infra.bat
   .\scripts\start-backend.bat
   ```
2. Install Flutter dependencies:
   ```powershell
   cd apps\customer-app
   flutter pub get
   ```
3. Run static analysis & tests:
   ```powershell
   flutter analyze
   flutter test
   ```
4. Build & Run on Android:
   ```powershell
   flutter build apk --debug
   flutter run
   ```
   > On Android Emulator, `AppConfig.apiBaseUrl` automatically points to `http://10.0.2.2:8080/api/v1`.
