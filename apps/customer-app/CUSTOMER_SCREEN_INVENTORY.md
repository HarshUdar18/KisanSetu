# Kisan Setu — Customer Screen Inventory

Maps all **74 Stitch Screen Designs** (`customer_side/stitch_kisan_setu_mobile_app/<folder>`) and all **220 Feature Checklist Items** across Modules 1–14.

## Module 1 — Splash & Onboarding
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 1 | Splash Screen | `splash_screen` | `/splash` | Dedicated screen |
| 2 | Welcome Screen | `welcome_screen` | `/welcome` | Dedicated screen |
| 3 | Onboarding — Fresh Produce | `onboarding_fresh_produce` | `/onboarding?step=0` | `OnboardingFlowScreen` (Page 1) |
| 4 | Onboarding — Direct Farmer Connection | `onboarding_direct_farmer_connection` | `/onboarding?step=1` | `OnboardingFlowScreen` (Page 2) |
| 5 | Onboarding — Weekly Delivery Planning | `onboarding_weekly_delivery_planning` | `/onboarding?step=2` | `OnboardingFlowScreen` (Page 3) |
| 6 | Select Language | `select_language_screen` | `/select-language` | Dedicated screen |
| 7 | Get Started | `welcome_screen` | `/welcome` | CTA on Welcome / Onboarding |

## Module 2 — Location & Permissions
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 8–10 | Location Intro / Why Needed / Allow | `why_kisan_setu_needs_location` | `/location-primer` | `LocationPrimerScreen` |
| 11–14 | Granted / Denied / Permanently Denied / Settings Guidance | `location_permission_denied_settings_guidance` | `/location-permission-denied` | `LocationPermissionDeniedScreen` |
| 15–17 | Manual / Search / Recent Locations | `select_location_manually` | `/select-location` | `SelectLocationScreen` |
| 18–19 | Map Location Picker / Confirm | `map_location_picker` | `/map-picker` | `MapLocationPickerScreen` |
| 20 | Select Delivery Address | `saved_addresses` | `/addresses` | `AddressesScreen` |
| 21 | Serviceability Checking | `delivery_serviceability_checking` | `/serviceability-check` | `ServiceabilityStatusScreen` (loading) |
| 22 | Delivery Available | `delivery_available` | `/serviceability-check` | `ServiceabilityStatusScreen` (available) |
| 23 | Delivery Not Available | `delivery_not_available` | `/serviceability-check` | `ServiceabilityStatusScreen` (unavailable) |
| 24 | Change Delivery Location | `select_location_manually` | `/select-location` | Reuses `SelectLocationScreen` |

## Module 3 — Customer Authentication
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 25, 27 | Login / Mobile Number Entry | `login_screen` | `/login` | `LoginScreen` (OTP & Password modes) |
| 26, 35 | Customer Registration / Success | `customer_registration` | `/register` | `RegisterScreen` + Success dialog/view |
| 28–31 | OTP Verify / Invalid / Expired / Resend | `otp_verification`, `otp_incorrect_retry`, `otp_expired_resend_options` | `/otp-verify` | `OtpVerificationScreen` (state-driven) |
| 32–34 | Forgot / Reset / Create New Password | `forgot_password_verification` | `/forgot-password` | `ForgotPasswordScreen` (3-step flow) |
| 36–37 | Session Expired / Logout Confirmation | — | `/session-expired` / Dialog | `SystemStateScreen` & `ConfirmationDialog` |

## Module 4 — Home & Product Discovery
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 38 | Home Dashboard | `home_dashboard` | `/home` | `HomeScreen` |
| 39–45 | Product Categories & Subcategories | `product_categories` | `/categories` | `CategoriesScreen` |
| 46–47, 52–53 | Featured / Seasonal / Filter / Sort | `product_catalog_filters_sorting` | `/catalog` | `CatalogFilterScreen` |
| 48–51 | Search / Suggestions / Results / Empty | `empty_search_recommendations` | `/search` | `SearchScreen` |
| 54, 56–57 | Product Details / Availability / Similar | `product_details` | `/product/:id` | `ProductDetailScreen` |
| 55 | Farmer / Producer Information | `farmer_profile_origin_story`, `fpo_farmer_network_chronicles` | `/farmer/:id`, `/fpo-network` | `FarmerProfileScreen`, `FpoNetworkScreen` |
| Extra | Product Reviews & Farmer Feedback | `product_review_farmer_feedback` | `/product/:id/reviews` | `ProductReviewsScreen` |

## Module 5 — Shopping Cart
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 58, 60–61, 65–66 | Shopping Cart / Qty / Remove / Summary / Validation | `shopping_cart` | `/cart` | `CartScreen` |
| 59 | Empty Cart | `empty_cart` | `/cart` (empty state) | `EmptyCartView` inside `CartScreen` |
| 62–64 | Out of Stock / Insufficient Stock / Price Updated | `shopping_cart` | `/cart` | Inline stock & price-change banners |

## Module 6 — Address Management
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 67, 71 | Saved Addresses / Select Default | `saved_addresses` | `/addresses` | `AddressesScreen` |
| 68–69, 72–75 | Add/Edit Address & Types (Home/Work/Other) | `add_edit_address` | `/add-address` | `AddEditAddressScreen` |
| 70 | Delete Address Confirmation | `saved_addresses` | Dialog | `ConfirmationDialog` |
| 76–79 | Map Picker / Confirm Tagging / Saved / Serviceability | `confirm_delivery_address_tagging` | `/confirm-address` | `ConfirmAddressTaggingScreen` |

## Module 7 — Weekly Cart
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 80–83, 93–95, 100–101 | Weekly Cart Dashboard / Week / Calendar / Summary / History | `weekly_cart_planner` | `/weekly-planner` | `WeeklyPlannerScreen` |
| 84–92 | Day Plans (Mon–Sun) & Edit Day List | `weekly_cart_day_planner_monday_plan` | `/weekly-planner/day/:day` | `WeeklyDayPlannerScreen` |
| 96–99 | Submitted / Edit / Confirmation / Edit Limit Reached | `weekly_cart_submitted_edit_limit` | `/weekly-planner/submitted` | `WeeklySubmittedScreen` |

## Module 8 — Subscriptions
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 102–103, 116 | Subscription Overview / Plans / History | `subscription_overview` | `/subscriptions` | `SubscriptionsOverviewScreen` |
| 104–109 | Create Subscription / Frequency / Products / Schedule / Review | `create_subscription` | `/create-subscription` | `CreateSubscriptionScreen` |
| 110–111 | Active Subscription Details / Edit Schedule | `subscription_details_schedule`, `edit_delivery_schedule_frequency` | `/subscriptions/:id`, `/subscriptions/:id/edit` | `SubscriptionDetailsScreen`, `EditScheduleScreen` |
| 112–115 | Pause / Resume / Cancel / Confirmation | `pause_subscription_vacation_mode` | `/subscriptions/:id/pause` | `PauseSubscriptionScreen` |

## Module 9 — Checkout & Payment
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 117–121, 125 | Checkout Summary / Address / Date / Slot / Instructions | `checkout_flow` | `/checkout` | `CheckoutScreen` |
| 122–124 | Apply Coupon / Applied / Invalid | `apply_coupon_offers` | `/apply-coupon` | `ApplyCouponScreen` |
| 126–127 | Payment Method Selection / UPI | `select_payment_method_upi` | `/payment` | `PaymentMethodScreen` |
| 128–132 | Payment Processing / Success / Failed / Pending / Retry | `payment_processing`, `payment_failed_retry` | `/payment-processing`, `/payment-failed` | `PaymentProcessingScreen`, `PaymentFailedScreen` |
| 133–134 | Order Confirmation & Details | `order_confirmation_details` | `/order-confirmed` | `OrderConfirmedScreen` |

## Module 10 — Orders & Tracking
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 135–138, 153 | My Orders (Active / Completed / Cancelled) & Reorder | `my_orders` | `/orders` | `OrdersScreen` |
| 139–149 | Order Details / Overview / 9-Stage Supply Chain / Live Detail | `order_tracking_overview`, `order_fulfillment_supply_chain_tracking`, `live_delivery_tracking_detail` | `/orders/:id`, `/tracking/:id`, `/tracking/:id/live` | `OrderDetailsScreen`, `TrackingScreen`, `LiveTrackingDetailScreen` |
| 150–152 | Cancel Order / Reason / Confirmation | `cancel_order`, `order_cancellation_confirmation` | `/orders/:id/cancel`, `/orders/:id/cancelled` | `CancelOrderScreen`, `OrderCancellationConfirmedScreen` |
| 154–155 | Invoice Details / Harvest Certificate / Download | `tax_invoice_harvest_certificate` | `/orders/:id/invoice` | `TaxInvoiceScreen` |

## Module 11 — Notifications
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 156–157 | Notification Permission Primer / Allow | `notification_permission_primer` | `/notification-primer` | `NotificationPrimerScreen` |
| 158–159 | Denied / Settings Guidance | `notification_settings_guidance` | `/notification-settings-guidance` | `NotificationSettingsGuidanceScreen` |
| 160–170 | Notification Centre (All types) | `notification_centre`, `empty_notifications` | `/notifications` | `NotificationCentreScreen` |
| 171 | Notification Preferences | `notification_preferences` | `/notification-preferences` | `NotificationPreferencesScreen` |

## Module 12 — Profile & Settings
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 172, 181, 183–187 | Customer Profile & Settings | `customer_profile` | `/profile` | `ProfileScreen` |
| 173–176 | Edit Profile / Personal Info / Mobile / Email | `edit_profile` | `/edit-profile` | `EditProfileScreen` |
| 177–180 | Change Password / Account Security / Active Sessions / Logout Others | `account_security` | `/account-security` | `AccountSecurityScreen` |
| 182 | Default Delivery & Harvest Preferences | `delivery_harvest_preferences` | `/delivery-preferences` | `DeliveryPreferencesScreen` |
| 188–191 | Data & Account / Delete Account Request & Confirmation | `delete_account_confirmation` | `/delete-account` | `DeleteAccountScreen` |
| Extra | Kisan Wallet & Passbook | `kisan_wallet_passbook` | `/wallet` | `KisanWalletScreen` |
| Extra | Harvest Impact & Payout Ledger | `harvest_impact_payout_ledger` | `/harvest-impact` | `HarvestImpactScreen` |
| Extra | Seasonal Farm Visit & Workshop | `seasonal_farm_visit_workshop` | `/farm-visits` | `FarmVisitScreen` |

## Module 13 — Help & Support
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 192, 194, 200–203 | Help & Support Center / Contact / Legal / Version | `help_support_center` | `/support` | `HelpSupportScreen` |
| 193 | FAQ & Sourcing Knowledge Base | `faq_sourcing_knowledge_base` | `/faq` | `FaqScreen` |
| 195–198 | Submit Support Request / Order / Payment / Delivery Issue | `raise_an_issue_ticket`, `live_farm_support_chat` | `/raise-ticket`, `/support-chat` | `RaiseTicketScreen`, `LiveSupportChatScreen` |
| 199 | Feedback & Rating | `product_review_farmer_feedback` | `/product/:id/reviews` | `ProductReviewsScreen` |

## Module 14 — System & Exception States
| # | Checklist Screen | Stitch Folder | Route | Implementation Mode |
|---|---|---|---|---|
| 204 | No Internet | `no_internet_connection` | `/error/no-internet` | `SystemStateScreen.noInternet` |
| 205 | Server Error | `server_error` | `/error/server` | `SystemStateScreen.serverError` |
| 206 | Maintenance | `maintenance_screen` | `/maintenance` | `SystemStateScreen.maintenance` |
| 207–208 | General Loading / Product Loading Skeleton | `product_loading_skeleton` | Widget & `/skeleton-demo` | `ProductLoadingSkeleton` |
| 209–214 | Empty Search / Cart / Orders / Notifications / Location / Area | Dedicated Stitch screens | Inline + routes | Reusable state views |
| 215–220 | Session Expired / Unauthorized / Payment Error / Success / Error / Retry | — | `/error/:type` | `SystemStateScreen` & dialogs |
