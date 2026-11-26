-- V20: Email/Google Auth support, Customer Wallet & Ledger, Centralized Delivery Slots, Refunds

ALTER TABLE users ALTER COLUMN phone DROP NOT NULL;

CREATE TABLE IF NOT EXISTS wallets (
    wallet_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_wallets_user ON wallets(user_id);

CREATE TABLE IF NOT EXISTS wallet_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(wallet_id) ON DELETE CASCADE,
    transaction_type VARCHAR(30) NOT NULL,
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    reference_type VARCHAR(50),
    reference_id UUID,
    idempotency_key VARCHAR(100) UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'COMPLETED',
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_wallet_txns_wallet ON wallet_transactions(wallet_id, created_at DESC);

CREATE TABLE IF NOT EXISTS delivery_slots (
    slot_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slot_code VARCHAR(50) NOT NULL UNIQUE,
    slot_type VARCHAR(30) NOT NULL,
    fulfilment_type VARCHAR(30) NOT NULL,
    label VARCHAR(120) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    locality_id UUID,
    capacity INTEGER NOT NULL DEFAULT 50,
    remaining_capacity INTEGER NOT NULL DEFAULT 50,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS slot_reservations (
    reservation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slot_id UUID NOT NULL REFERENCES delivery_slots(slot_id),
    user_id UUID NOT NULL REFERENCES users(id),
    order_id UUID,
    subscription_id UUID,
    status VARCHAR(30) NOT NULL DEFAULT 'RESERVED',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_slot_reservations_slot ON slot_reservations(slot_id);

INSERT INTO delivery_slots (slot_code, slot_type, fulfilment_type, label, start_time, end_time, capacity, remaining_capacity, is_active)
VALUES
    ('SUB_MORNING_06_08', 'SUBSCRIPTION', 'SCHEDULED', 'Morning Harvest (06:00 AM - 08:00 AM)', '06:00:00', '08:00:00', 100, 100, true),
    ('SUB_MORNING_08_10', 'SUBSCRIPTION', 'SCHEDULED', 'Mid-Morning (08:00 AM - 10:00 AM)', '08:00:00', '10:00:00', 100, 100, true),
    ('EXPRESS_NEXT_AVAILABLE', 'FASTEST_DELIVERY', 'IMMEDIATE', 'Fastest Available (Next Dispatch Window)', '07:00:00', '10:00:00', 60, 60, true),
    ('EVENING_DISPATCH_17_19', 'FASTEST_DELIVERY', 'SCHEDULED', 'Evening Harvest (05:00 PM - 07:00 PM)', '17:00:00', '19:00:00', 80, 80, true)
ON CONFLICT (slot_code) DO NOTHING;

ALTER TABLE payments
    ADD COLUMN IF NOT EXISTS idempotency_key VARCHAR(100) UNIQUE,
    ADD COLUMN IF NOT EXISTS provider_signature VARCHAR(255);

CREATE TABLE IF NOT EXISTS refunds (
    refund_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES payments(id),
    order_id UUID NOT NULL REFERENCES orders(id),
    user_id UUID NOT NULL REFERENCES users(id),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    status VARCHAR(30) NOT NULL DEFAULT 'COMPLETED',
    reason TEXT,
    idempotency_key VARCHAR(100) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
