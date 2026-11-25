-- V6: Seed Initial Foundation Roles, Service Areas, and Development Users

-- 1. Insert Standard Roles
INSERT INTO roles (id, description) VALUES
    ('ROLE_CUSTOMER', 'Retail Consumer accessing Customer Mobile App'),
    ('ROLE_FARMER', 'Agricultural Producer accessing Farmer Mobile App'),
    ('ROLE_ADMIN', 'Platform Administrator accessing Web Admin Panel'),
    ('ROLE_BULK_BUYER', 'Institutional & Wholesale B2B Buyer'),
    ('ROLE_DELIVERY_PARTNER', 'Last-mile logistics delivery rider'),
    ('ROLE_COLLECTION_OPERATOR', 'Village collection center operator'),
    ('ROLE_WAREHOUSE_OPERATOR', 'Cold storage warehouse operator'),
    ('ROLE_HUB_OPERATOR', 'Regional distribution hub operator'),
    ('ROLE_DELIVERY_STATION_OPERATOR', 'Local dark store and delivery station operator'),
    ('ROLE_FINANCE', 'Settlement and reconciliation manager'),
    ('ROLE_QUALITY', 'Quality testing and produce grading inspector'),
    ('ROLE_SUPPORT', 'Customer and farmer customer service agent')
ON CONFLICT (id) DO NOTHING;

-- 2. Insert Service Areas (Initial Deployment: Shivajinagar and Akurdi, Pune)
INSERT INTO service_areas (id, name, status, pincode, latitude, longitude, radius_km, city) VALUES
    ('c0000000-0000-0000-0000-000000000001', 'Shivajinagar', 'ACTIVE', '411005', 18.5314000, 73.8446000, 6.00, 'Pune'),
    ('c0000000-0000-0000-0000-000000000002', 'Akurdi', 'ACTIVE', '411035', 18.6496000, 73.7707000, 5.00, 'Pune')
ON CONFLICT (name) DO NOTHING;

-- 3. Insert Development Users (Password for all: password123)
-- BCrypt: $2a$10$e8pCgLgD0xkWc55eQ10p3ekq94.U6LqfPvZJm53l2i2YmR1wH1f1m
INSERT INTO users (id, phone, email, password_hash, status) VALUES
    ('a0000000-0000-0000-0000-000000000001', '9876543210', 'admin@kisansetu.com', '$2a$10$e8pCgLgD0xkWc55eQ10p3ekq94.U6LqfPvZJm53l2i2YmR1wH1f1m', 'ACTIVE'),
    ('a0000000-0000-0000-0000-000000000002', '9876543211', 'customer@kisansetu.com', '$2a$10$e8pCgLgD0xkWc55eQ10p3ekq94.U6LqfPvZJm53l2i2YmR1wH1f1m', 'ACTIVE'),
    ('a0000000-0000-0000-0000-000000000003', '9876543212', 'farmer@kisansetu.com', '$2a$10$e8pCgLgD0xkWc55eQ10p3ekq94.U6LqfPvZJm53l2i2YmR1wH1f1m', 'ACTIVE'),
    ('a0000000-0000-0000-0000-000000000004', '9876543213', 'hybrid@kisansetu.com', '$2a$10$e8pCgLgD0xkWc55eQ10p3ekq94.U6LqfPvZJm53l2i2YmR1wH1f1m', 'ACTIVE')
ON CONFLICT (phone) DO NOTHING;

-- 4. Assign Roles to Users
INSERT INTO user_roles (user_id, role_id) VALUES
    ('a0000000-0000-0000-0000-000000000001', 'ROLE_ADMIN'),
    ('a0000000-0000-0000-0000-000000000002', 'ROLE_CUSTOMER'),
    ('a0000000-0000-0000-0000-000000000003', 'ROLE_FARMER'),
    ('a0000000-0000-0000-0000-000000000004', 'ROLE_CUSTOMER'),
    ('a0000000-0000-0000-0000-000000000004', 'ROLE_FARMER')
ON CONFLICT (user_id, role_id) DO NOTHING;

-- 5. Insert Customer Profile
INSERT INTO customer_profiles (id, user_id, full_name, default_delivery_address, pincode, latitude, longitude) VALUES
    ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'Ananya Deshmukh (Customer)', 'Flat 304, Green Park Heights, Shivajinagar, Pune', '411005', 18.5314000, 73.8446000),
    ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000004', 'Hybrid User Profile', 'Sector 24, Pradhikaran, Akurdi, Pune', '411035', 18.6496000, 73.7707000)
ON CONFLICT (user_id) DO NOTHING;

-- 6. Insert Farmer Profile
INSERT INTO farmer_profiles (id, user_id, full_name, village, district, state, pincode, primary_crop_category) VALUES
    ('d0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003', 'Tukaram Patil (Farmer)', 'Khed Shivapur', 'Pune', 'Maharashtra', '412205', 'Organic Vegetables & Pomegranate'),
    ('d0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000004', 'Hybrid Producer Account', 'Dehu Gaon', 'Pune', 'Maharashtra', '412109', 'Leafy Greens')
ON CONFLICT (user_id) DO NOTHING;
