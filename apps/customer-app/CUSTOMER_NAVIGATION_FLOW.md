# Kisan Setu — Customer Navigation Flow

## 1. Entry & Onboarding Flow
```
/splash
  ├── (authenticated) ──────────────────────────► /home
  ├── (language not chosen) ────────────────────► /select-language ─► /welcome
  └── (returning guest) ────────────────────────► /welcome
                                                    ├── "Get Started" ─► /onboarding?step=0..2 ─► /location-primer
                                                    └── "Login" ───────► /login
```

## 2. Authentication Flow
```
/login
  ├── "Send OTP" ──────► /otp-verify (valid | invalid | expired states) ─► /home
  ├── "Password Login" ─► (inline password field) ────────────────────────► /home
  ├── "Forgot Password" ► /forgot-password (mobile -> OTP -> new pass) ─► /login
  └── "Create Account" ─► /register ─► /otp-verify ──────────────────────► /home
```

## 3. Location & Serviceability Flow
```
/location-primer
  ├── "Allow Location" ─► (granted) ─► /serviceability-check ─► /home
  │                    └─ (denied)  ─► /location-permission-denied ─► /select-location
  └── "Enter Manually" ─► /select-location ─► /map-picker ─► /confirm-address ─► /serviceability-check
```

## 4. Main Bottom Navigation Shell (`StatefulShellRoute` / 5 Tabs)
| Tab | Label | Icon | Root Route |
|---|---|---|---|
| 0 | Home | `home` | `/home` |
| 1 | Categories | `grid_view` | `/categories` |
| 2 | Weekly Cart | `calendar_month` | `/weekly-planner` |
| 3 | Orders | `receipt_long` | `/orders` |
| 4 | Profile | `person` | `/profile` |

## 5. Shopping & Checkout Flow
```
/home ──► /search
      ──► /catalog (filters & sort)
      ──► /product/:id ──► /farmer/:id
                       ──► /product/:id/reviews
      ──► /cart ──► /checkout
                      ├── /addresses ─► /add-address ─► /map-picker ─► /confirm-address
                      ├── /apply-coupon
                      └── /payment (UPI / Card / COD)
                            └── /payment-processing
                                  ├── (success) ─► /order-confirmed ─► /tracking/:id
                                  └── (failed)  ─► /payment-failed ─► (retry) /payment
```

## 6. Weekly Cart & Subscriptions Flow
```
/weekly-planner
  ├── Tap Day (Mon–Sun) ──► /weekly-planner/day/:day
  └── Submit / Modify ────► /weekly-planner/submitted (shows edit count 0/1 or locked)

/subscriptions
  ├── "Create Plan" ──────► /create-subscription ─► /checkout or /order-confirmed
  └── Tap Active Plan ────► /subscriptions/:id
                              ├── /subscriptions/:id/edit
                              └── /subscriptions/:id/pause
```

## 7. Orders, Tracking & Support Flow
```
/orders
  └── Tap Order ─► /orders/:id
                     ├── /tracking/:id ─► /tracking/:id/live
                     ├── /orders/:id/invoice
                     ├── /orders/:id/cancel ─► /orders/:id/cancelled
                     └── /raise-ticket ─► /support-chat
```

## 8. Profile, Notifications & Settings Flow
```
/profile
  ├── /edit-profile
  ├── /account-security ─► /delete-account
  ├── /addresses
  ├── /delivery-preferences
  ├── /notifications ─► /notification-preferences
  │                  └─ /notification-primer ─► /notification-settings-guidance
  ├── /wallet
  ├── /harvest-impact
  ├── /fpo-network
  ├── /farm-visits
  ├── /select-language
  └── /support ─► /faq, /raise-ticket, /support-chat
```
