# Kisan Setu — Admin Web Panel (React + TypeScript + Vite)

Centralized administrative, operations, KYC audit, supply chain, and escrow governance portal for the Kisan Setu platform.

> **Exclusively for the Admin Web Panel** (`apps/admin-panel`). Mobile apps (`apps/customer-app` and `apps/farmer-app`) are completely separate and untouched.

## Documentation
- [ADMIN_DESIGN_ANALYSIS.md](ADMIN_DESIGN_ANALYSIS.md)
- [ADMIN_DESIGN_SYSTEM.md](ADMIN_DESIGN_SYSTEM.md)
- [ADMIN_SCREEN_INVENTORY.md](ADMIN_SCREEN_INVENTORY.md)
- [ADMIN_NAVIGATION_FLOW.md](ADMIN_NAVIGATION_FLOW.md)
- [ADMIN_API_INTEGRATION.md](ADMIN_API_INTEGRATION.md)
- [ADMIN_SCREEN_IMPLEMENTATION_TRACKER.md](ADMIN_SCREEN_IMPLEMENTATION_TRACKER.md)

## Tech Stack
- React 19 + TypeScript + Vite 8
- Material UI (`@mui/material` + `@mui/icons-material`) with Kisan Setu Stitch Design System (`#005128`, `#F2FCF2`, `#F4BF1B`)
- React Router (`react-router-dom`) with RBAC-protected routes
- Axios (`/api/v1` with JWT Bearer interceptor)

## Run, Lint & Build
```powershell
cd apps\admin-panel
npm install
npm run lint
npm run build
npm run dev
```
> Default dev admin credentials (when backend is offline): `9876543210` / `password123`.
