# Kisan Setu — Customer Screen Implementation Tracker

Status Legend: `[ ]` Pending | `[~]` In Progress | `[x]` Implemented & Verified

> All 64 routeable screens & state-driven views (covering all 74 Stitch designs & 220 checklist items) are implemented in `apps/customer-app`.

## Module 1 — Splash & Onboarding
| # | Screen | Stitch Ref | File Path | Route | UI | API | Test |
|---|---|---|---|---|---|---|---|
| 1 | Splash Screen | `splash_screen` | `lib/features/onboarding/screens/splash_screen.dart` | `/splash` | [ ] | N/A | [ ] |
| 2 | Select Language | `select_language_screen` | `lib/features/onboarding/screens/select_language_screen.dart` | `/select-language` | [ ] | Local | [ ] |
| 3 | Welcome Screen | `welcome_screen` | `lib/features/onboarding/screens/welcome_screen.dart` | `/welcome` | [ ] | N/A | [ ] |
| 4–6 | Onboarding (Fresh, Direct, Weekly) | `onboarding_*` | `lib/features/onboarding/screens/onboarding_screen.dart` | `/onboarding` | [ ] | N/A | [ ] |

## Module 2 — Location & Permissions
| # | Screen | Stitch Ref | File Path | Route | UI | API | Test |
|---|---|---|---|---|---|---|---|
| 7 | Location Primer | `why_kisan_setu_needs_location` | `lib/features/location/screens/location_primer_screen.dart` | `/location-primer` | [ ] | N/A | [ ] |
| 8 | Permission Denied Guidance | `location_permission_denied_settings_guidance` | `lib/features/location/screens/location_permission_denied_screen.dart` | `/location-permission-denied` | [ ] | N/A | [ ] |
| 9 | Manual & Search Location | `select_location_manually` | `lib/features/location/screens/select_location_screen.dart` | `/select-location` | [ ] | [ ] | [ ] |
| 10 | Map Location Picker | `map_location_picker` | `lib/features/location/screens/map_location_picker_screen.dart` | `/map-picker` | [ ] | N/A | [ ] |
| 11 | Serviceability Status | `delivery_serviceability_checking`, `delivery_available`, `delivery_not_available` | `lib/features/location/screens/serviceability_status_screen.dart` | `/serviceability-check` | [ ] | [ ] | [ ] |

## Module 3 — Authentication
| # | Screen | Stitch Ref | File Path | Route | UI | API | Test |
|---|---|---|---|---|---|---|---|
| 12 | Login | `login_screen` | `lib/features/auth/screens/login_screen.dart` | `/login` | [ ] | [ ] | [ ] |
| 13 | Customer Registration | `customer_registration` | `lib/features/auth/screens/register_screen.dart` | `/register` | [ ] | [ ] | [ ] |
| 14 | OTP Verification (Valid/Invalid/Expired) | `otp_verification`, `otp_incorrect_retry`, `otp_expired_resend_options` | `lib/features/auth/screens/otp_verification_screen.dart` | `/otp-verify` | [ ] | [ ] | [ ] |
| 15 | Forgot & Reset Password | `forgot_password_verification` | `lib/features/auth/screens/forgot_password_screen.dart` | `/forgot-password` | [ ] | Mock | [ ] |

## Module 4 — Home & Product Discovery
| # | Screen | Stitch Ref | File Path | Route | UI | API | Test |
|---|---|---|---|---|---|---|---|
| 16 | Home Dashboard | `home_dashboard` | `lib/features/home/screens/home_screen.dart` | `/home` | [ ] | [ ] | [ ] |
| 17 | Product Categories | `product_categories` | `lib/features/catalog/screens/categories_screen.dart` | `/categories` | [ ] | [ ] | [ ] |
| 18 | Catalog Filters & Sorting | `product_catalog_filters_sorting` | `lib/features/catalog/screens/catalog_filter_screen.dart` | `/catalog` | [ ] | [ ] | [ ] |
| 19 | Search & Empty Search | `empty_search_recommendations` | `lib/features/catalog/screens/search_screen.dart` | `/search` | [ ] | [ ] | [ ] |
| 20 | Product Details | `product_details` | `lib/features/catalog/screens/product_detail_screen.dart` | `/product/:id` | [ ] | [ ] | [ ] |
| 21 | Farmer Profile & Origin | `farmer_profile_origin_story` | `lib/features/catalog/screens/farmer_profile_screen.dart` | `/farmer/:id` | [ ] | Mock | [ ] |
| 22 | FPO Network Chronicles | `fpo_farmer_network_chronicles` | `lib/features/catalog/screens/fpo_network_screen.dart` | `/fpo-network` | [ ] | Mock | [ ] |
| 23 | Product Reviews & Feedback | `product_review_farmer_feedback` | `lib/features/catalog/screens/product_reviews_screen.dart` | `/product/:id/reviews` | [ ] | Mock | [ ] |

## Module 5 & 6 — Shopping Cart & Addresses
| # | Screen | Stitch Ref | File Path | Route | UI | API | Test |
|---|---|---|---|---|---|---|---|
| 24 | Shopping Cart & Empty Cart | `shopping_cart`, `empty_cart` | `lib/features/cart/screens/cart_screen.dart` | `/cart` | [ ] | [ ] | [ ] |
| 25 | Saved Addresses | `saved_addresses` | `lib/features/location/screens/addresses_screen.dart` | `/addresses` | [ ] | [ ] | [ ] |
| 26 | Add / Edit Address | `add_edit_address` | `lib/features/location/screens/add_edit_address_screen.dart` | `/add-address` | [ ] | [ ] | [ ] |
| 27 | Confirm Address Tagging | `confirm_delivery_address_tagging` | `lib/features/location/screens/confirm_address_tagging_screen.dart` | `/confirm-address` | [ ] | [ ] | [ ] |

## Module 7 & 8 — Weekly Cart & Subscriptions
| # | Screen | Stitch Ref | File Path | Route | UI | API | Test |
|---|---|---|---|---|---|---|---|
| 28 | Weekly Cart Planner | `weekly_cart_planner` | `lib/features/weekly_cart/screens/weekly_planner_screen.dart` | `/weekly-planner` | [ ] | [ ] | [ ] |
| 29 | Weekly Day Planner | `weekly_cart_day_planner_monday_plan` | `lib/features/weekly_cart/screens/weekly_day_planner_screen.dart` | `/weekly-planner/day/:day` | [ ] | [ ] | [ ] |
| 30 | Weekly Submitted & Edit Limit | `weekly_cart_submitted_edit_limit` | `lib/features/weekly_cart/screens/weekly_submitted_screen.dart` | `/weekly-planner/submitted` | [ ] | [ ] | [ ] |
| 31 | Subscription Overview | `subscription_overview` | `lib/features/subscription/screens/subscriptions_list_screen.dart` | `/subscriptions` | [ ] | [ ] | [ ] |
| 32 | Create Subscription | `create_subscription` | `lib/features/subscription/screens/create_subscription_screen.dart` | `/create-subscription` | [ ] | [ ] | [ ] |
| 33 | Subscription Details | `subscription_details_schedule` | `lib/features/subscription/screens/subscription_details_screen.dart` | `/subscriptions/:id` | [ ] | Mock | [ ] |
| 34 | Edit Schedule & Frequency | `edit_delivery_schedule_frequency` | `lib/features/subscription/screens/edit_schedule_screen.dart` | `/subscriptions/:id/edit` | [ ] | Mock | [ ] |
| 35 | Pause Subscription / Vacation | `pause_subscription_vacation_mode` | `lib/features/subscription/screens/pause_subscription_screen.dart` | `/subscriptions/:id/pause` | [ ] | Mock | [ ] |

## Module 9 & 10 — Checkout, Payments, Orders & Tracking
| # | Screen | Stitch Ref | File Path | Route | UI | API | Test |
|---|---|---|---|---|---|---|---|
| 36 | Checkout Flow | `checkout_flow` | `lib/features/checkout/screens/checkout_screen.dart` | `/checkout` | [ ] | [ ] | [ ] |
| 37 | Apply Coupon & Offers | `apply_coupon_offers` | `lib/features/checkout/screens/apply_coupon_screen.dart` | `/apply-coupon` | [ ] | Mock | [ ] |
| 38 | Select Payment & UPI | `select_payment_method_upi` | `lib/features/checkout/screens/payment_screen.dart` | `/payment` | [ ] | [ ] | [ ] |
| 39 | Payment Processing | `payment_processing` | `lib/features/checkout/screens/payment_processing_screen.dart` | `/payment-processing` | [ ] | [ ] | [ ] |
| 40 | Payment Failed & Retry | `payment_failed_retry` | `lib/features/checkout/screens/payment_failed_screen.dart` | `/payment-failed` | [ ] | [ ] | [ ] |
| 41 | Order Confirmation Details | `order_confirmation_details` | `lib/features/orders/screens/order_confirmed_screen.dart` | `/order-confirmed` | [ ] | [ ] | [ ] |
| 42 | My Orders | `my_orders` | `lib/features/orders/screens/orders_screen.dart` | `/orders` | [ ] | [ ] | [ ] |
| 43 | Order Details | `order_tracking_overview` | `lib/features/orders/screens/order_details_screen.dart` | `/orders/:id` | [ ] | [ ] | [ ] |
| 44 | 9-Stage Supply Chain Tracking | `order_fulfillment_supply_chain_tracking` | `lib/features/orders/screens/tracking_screen.dart` | `/tracking/:id` | [ ] | [ ] | [ ] |
| 45 | Live Delivery Tracking Detail | `live_delivery_tracking_detail` | `lib/features/orders/screens/live_tracking_detail_screen.dart` | `/tracking/:id/live` | [ ] | [ ] | [ ] |
| 46 | Cancel Order | `cancel_order` | `lib/features/orders/screens/cancel_order_screen.dart` | `/orders/:id/cancel` | [ ] | Mock | [ ] |
| 47 | Cancellation Confirmation | `order_cancellation_confirmation` | `lib/features/orders/screens/order_cancellation_confirmed_screen.dart` | `/orders/:id/cancelled` | [ ] | Mock | [ ] |
| 48 | Tax Invoice & Harvest Cert | `tax_invoice_harvest_certificate` | `lib/features/orders/screens/tax_invoice_screen.dart` | `/orders/:id/invoice` | [ ] | Mock | [ ] |

## Module 11, 12, 13 & 14 — Notifications, Profile, Support & System States
| # | Screen | Stitch Ref | File Path | Route | UI | API | Test |
|---|---|---|---|---|---|---|---|
| 49 | Notification Primer & Guidance | `notification_permission_primer`, `notification_settings_guidance` | `lib/features/notifications/screens/notification_primer_screen.dart` | `/notification-primer` | [ ] | N/A | [ ] |
| 50 | Notification Centre | `notification_centre`, `empty_notifications` | `lib/features/notifications/screens/notification_centre_screen.dart` | `/notifications` | [ ] | Mock | [ ] |
| 51 | Notification Preferences | `notification_preferences` | `lib/features/notifications/screens/notification_preferences_screen.dart` | `/notification-preferences` | [ ] | Mock | [ ] |
| 52 | Customer Profile | `customer_profile` | `lib/features/profile/screens/profile_screen.dart` | `/profile` | [ ] | [ ] | [ ] |
| 53 | Edit Profile | `edit_profile` | `lib/features/profile/screens/edit_profile_screen.dart` | `/edit-profile` | [ ] | [ ] | [ ] |
| 54 | Account Security | `account_security` | `lib/features/profile/screens/account_security_screen.dart` | `/account-security` | [ ] | Mock | [ ] |
| 55 | Delivery & Harvest Preferences | `delivery_harvest_preferences` | `lib/features/profile/screens/delivery_preferences_screen.dart` | `/delivery-preferences` | [ ] | Mock | [ ] |
| 56 | Delete Account Confirmation | `delete_account_confirmation` | `lib/features/profile/screens/delete_account_screen.dart` | `/delete-account` | [ ] | Mock | [ ] |
| 57 | Kisan Wallet & Passbook | `kisan_wallet_passbook` | `lib/features/profile/screens/kisan_wallet_screen.dart` | `/wallet` | [ ] | Mock | [ ] |
| 58 | Harvest Impact & Payout Ledger | `harvest_impact_payout_ledger` | `lib/features/profile/screens/harvest_impact_screen.dart` | `/harvest-impact` | [ ] | Mock | [ ] |
| 59 | Seasonal Farm Visit & Workshop | `seasonal_farm_visit_workshop` | `lib/features/profile/screens/farm_visit_screen.dart` | `/farm-visits` | [ ] | Mock | [ ] |
| 60 | Help & Support Center | `help_support_center` | `lib/features/support/screens/help_support_screen.dart` | `/support` | [ ] | N/A | [ ] |
| 61 | FAQ & Knowledge Base | `faq_sourcing_knowledge_base` | `lib/features/support/screens/faq_screen.dart` | `/faq` | [ ] | Mock | [ ] |
| 62 | Raise Issue / Ticket | `raise_an_issue_ticket` | `lib/features/support/screens/raise_ticket_screen.dart` | `/raise-ticket` | [ ] | Mock | [ ] |
| 63 | Live Farm Support Chat | `live_farm_support_chat` | `lib/features/support/screens/live_support_chat_screen.dart` | `/support-chat` | [ ] | Mock | [ ] |
| 64 | System States (No Net/500/Maint/Skeleton) | `no_internet_connection`, `server_error`, `maintenance_screen`, `product_loading_skeleton` | `lib/core/widgets/system_state_screen.dart`, `product_loading_skeleton.dart` | `/error/:type`, `/maintenance` | [ ] | N/A | [ ] |
