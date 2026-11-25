# Kisan Setu — Farmer Mobile Application (Flutter)

Direct farm-to-market agricultural producer & FPO mobile application.

> **Exclusively for the Farmer App** (`apps/farmer-app`). Customer App (`apps/customer-app`) is completely separate and untouched.

## Design & Architecture Documentation
- [FARMER_DESIGN_ANALYSIS.md](FARMER_DESIGN_ANALYSIS.md)
- [FARMER_DESIGN_SYSTEM.md](FARMER_DESIGN_SYSTEM.md)
- [FARMER_SCREEN_INVENTORY.md](FARMER_SCREEN_INVENTORY.md)
- [FARMER_NAVIGATION_FLOW.md](FARMER_NAVIGATION_FLOW.md)
- [FARMER_API_INTEGRATION.md](FARMER_API_INTEGRATION.md)
- [FARMER_SCREEN_IMPLEMENTATION_TRACKER.md](FARMER_SCREEN_IMPLEMENTATION_TRACKER.md)

## Tech Stack
- **Flutter & Dart** (`sdk: ^3.10.4`) with Material Design 3
- **State Management**: `provider` (`MultiProvider` + `ChangeNotifier`)
- **Navigation**: `go_router` (protected farmer routes + 5-tab `ShellRoute`)
- **Networking**: `dio` with JWT Bearer interceptor (`/api/v1`)
- **Storage**: `flutter_secure_storage` & `shared_preferences`
- **Media**: `image_picker`

## Build, Test & Run (Android)
```powershell
cd apps\farmer-app
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter run
```
