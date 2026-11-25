CREATE SCHEMA IF NOT EXISTS auth_db;

CREATE TABLE IF NOT EXISTS auth_db.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS auth_db.roles (
    id VARCHAR(50) PRIMARY KEY,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS auth_db.user_roles (
    user_id UUID NOT NULL REFERENCES auth_db.users(id) ON DELETE CASCADE,
    role_id VARCHAR(50) NOT NULL REFERENCES auth_db.roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS auth_db.refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth_db.users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO auth_db.roles (id, description) VALUES
    ('ROLE_CUSTOMER', 'Registered Customer'),
    ('ROLE_FARMER', 'Registered Farmer'),
    ('ROLE_FPO', 'Farmer Producer Organization'),
    ('ROLE_ADMIN', 'Platform Administrator'),
    ('ROLE_SUPER_ADMIN', 'Super Administrator'),
    ('ROLE_OPERATIONS_ADMIN', 'Operations Administrator'),
    ('ROLE_FINANCE_ADMIN', 'Finance Administrator'),
    ('ROLE_SUPPORT_ADMIN', 'Support Administrator'),
    ('ROLE_LOGISTICS_ADMIN', 'Logistics Administrator')
ON CONFLICT (id) DO NOTHING;
