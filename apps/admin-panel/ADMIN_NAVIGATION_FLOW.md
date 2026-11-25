# Kisan Setu — Admin Navigation Flow

```
/login
  ├── (optional 2FA) ─► /2fa ─► /dashboard
  ├── (forgot pass) ──► /forgot-password ─► /login
  └── (authenticated ROLE_ADMIN) ─► AdminLayout (Collapsible Sidebar + Header)
        ├── /dashboard
        ├── /customers
        ├── /farmers & /farmers/:id
        ├── /fpos
        ├── /kyc
        ├── /products
        ├── /produce
        ├── /demand
        ├── /orders
        ├── /collections
        ├── /quality
        ├── /warehouses
        ├── /inventory
        ├── /logistics
        ├── /payments & /settlements
        ├── /subscriptions
        ├── /farmer-store
        ├── /promotions
        ├── /notifications
        ├── /support
        ├── /analytics
        ├── /admin-users
        ├── /settings
        └── /profile
```
All protected routes verify `isAuthenticated` and `ROLE_ADMIN` + granular RBAC permissions (`view_finance`, `approve_kyc`, `manage_users`, etc.).
