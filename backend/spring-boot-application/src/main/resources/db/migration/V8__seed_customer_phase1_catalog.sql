-- V8: Seed Customer Phase 1 Catalog, Dynamic Market Prices, and Initial Addresses

-- 1. Insert Categories
INSERT INTO product_categories (id, name, code, description, icon_url, display_order, is_active) VALUES
    ('e0000000-0000-0000-0000-000000000001', 'Fresh Vegetables', 'VEGETABLES', 'Farm-fresh daily harvested vegetables', 'vegetables.png', 1, TRUE),
    ('e0000000-0000-0000-0000-000000000002', 'Seasonal Fruits', 'FRUITS', 'Naturally ripened orchard fruits', 'fruits.png', 2, TRUE),
    ('e0000000-0000-0000-0000-000000000003', 'Pulses & Dal', 'PULSES', 'Unpolished protein-rich pulses', 'pulses.png', 3, TRUE),
    ('e0000000-0000-0000-0000-000000000004', 'Grains & Millets', 'GRAINS', 'Whole wheat, jowar and traditional millets', 'grains.png', 4, TRUE)
ON CONFLICT (code) DO NOTHING;

-- 2. Insert Products
INSERT INTO products (id, category_id, name, marathi_name, description, unit, image_url, is_available, stock_quantity) VALUES
    -- Vegetables
    ('f0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'Desi Tomato', 'टोमॅटो', 'Naturally grown juicy red desi tomatoes, rich in lycopene and flavor.', 'kg', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400', TRUE, 500.0),
    ('f0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'Nashik Red Onion', 'कांदा', 'Pungent, dry, medium-sized Nashik red onions with long shelf life.', 'kg', 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400', TRUE, 800.0),
    ('f0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000001', 'Fresh Potato', 'बटाटा', 'Clean, soil-free mountain potatoes ideal for boiling and curries.', 'kg', 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400', TRUE, 1000.0),
    ('f0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000001', 'Green Cabbage', 'कोबी', 'Crisp, dense, locally harvested green cabbage heads.', 'piece', 'https://images.unsplash.com/photo-1550081699-79c1c2e48a77?w=400', TRUE, 300.0),
    ('f0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000001', 'White Cauliflower', 'फ्लॉवर', 'Fresh white compact florets harvested early morning.', 'piece', 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ca3?w=400', TRUE, 250.0),
    ('f0000000-0000-0000-0000-000000000006', 'e0000000-0000-0000-0000-000000000001', 'Fresh Spinach (Palak)', 'पालक', 'Tender dark green organic spinach leaves, chemical-free.', 'bunch', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400', TRUE, 400.0),
    ('f0000000-0000-0000-0000-000000000007', 'e0000000-0000-0000-0000-000000000001', 'Green Capsicum (Shimla Mirch)', 'ढोबळी मिरची', 'Crunchy bell peppers harvested directly from polyhouse farms.', 'kg', 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400', TRUE, 200.0),
    ('f0000000-0000-0000-0000-000000000008', 'e0000000-0000-0000-0000-000000000001', 'Tender Ladyfinger (Bhindi)', 'भेंडी', 'Freshly plucked tender green okra with zero fibrous stringiness.', 'kg', 'https://images.unsplash.com/photo-1625944525533-473f1a3d54e7?w=400', TRUE, 350.0),

    -- Fruits
    ('f0000000-0000-0000-0000-000000000009', 'e0000000-0000-0000-0000-000000000002', 'Shimla Royal Delicious Apple', 'सफरचंद', 'Crisp, sweet, mountain orchard apples with natural red blush.', 'kg', 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400', TRUE, 300.0),
    ('f0000000-0000-0000-0000-000000000010', 'e0000000-0000-0000-0000-000000000002', 'Jalgaon Robusta Banana', 'केळी', 'Naturally ripened, nutrient-packed sweet golden bananas.', 'dozen', 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400', TRUE, 600.0),

    -- Grains & Millets
    ('f0000000-0000-0000-0000-000000000011', 'e0000000-0000-0000-0000-000000000004', 'Lokwan Sharbati Wheat', 'गहू', 'Golden bold grain wheat directly from MP & Maharashtra farmers.', 'kg', 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400', TRUE, 2000.0),
    ('f0000000-0000-0000-0000-000000000012', 'e0000000-0000-0000-0000-000000000004', 'Maldandi Jowar (Sorghum)', 'ज्वारी', 'Premium pearl-white sweet grain jowar for soft rotis.', 'kg', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400', TRUE, 1500.0),

    -- Pulses
    ('f0000000-0000-0000-0000-000000000013', 'e0000000-0000-0000-0000-000000000003', 'Organic Toor Dal (Arhar)', 'तूर डाळ', 'Unpolished desi toor dal, zero artificial color, quick cooking.', 'kg', 'https://images.unsplash.com/photo-1585994192701-f1a505c817ea?w=400', TRUE, 1200.0)
ON CONFLICT (id) DO NOTHING;

-- 3. Insert Authoritative Market Prices
INSERT INTO market_prices (id, product_id, current_price, previous_price) VALUES
    ('22000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 30.00, 28.00), -- Tomato: 30 (was 28)
    ('22000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000002', 35.00, 32.00), -- Onion: 35
    ('22000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000003', 25.00, 24.00), -- Potato: 25
    ('22000000-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000004', 30.00, 35.00), -- Cabbage: 30
    ('22000000-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000005', 40.00, 45.00), -- Cauliflower: 40
    ('22000000-0000-0000-0000-000000000006', 'f0000000-0000-0000-0000-000000000006', 20.00, 25.00), -- Spinach: 20
    ('22000000-0000-0000-0000-000000000007', 'f0000000-0000-0000-0000-000000000007', 50.00, 45.00), -- Capsicum: 50
    ('22000000-0000-0000-0000-000000000008', 'f0000000-0000-0000-0000-000000000008', 45.00, 40.00), -- Ladyfinger: 45
    ('22000000-0000-0000-0000-000000000009', 'f0000000-0000-0000-0000-000000000009', 140.00, 150.00), -- Apple: 140
    ('22000000-0000-0000-0000-000000000010', 'f0000000-0000-0000-0000-000000000010', 45.00, 50.00), -- Banana: 45
    ('22000000-0000-0000-0000-000000000011', 'f0000000-0000-0000-0000-000000000011', 48.00, 46.00), -- Wheat: 48
    ('22000000-0000-0000-0000-000000000012', 'f0000000-0000-0000-0000-000000000012', 55.00, 52.00), -- Jowar: 55
    ('22000000-0000-0000-0000-000000000013', 'f0000000-0000-0000-0000-000000000013', 165.00, 170.00) -- Toor Dal: 165
ON CONFLICT (product_id) DO NOTHING;

-- 4. Insert Price History (Dynamic price demonstration: yesterday vs today)
INSERT INTO price_history (id, product_id, price, effective_date) VALUES
    (gen_random_uuid(), 'f0000000-0000-0000-0000-000000000001', 28.00, CURRENT_TIMESTAMP - INTERVAL '1 day'),
    (gen_random_uuid(), 'f0000000-0000-0000-0000-000000000001', 30.00, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'f0000000-0000-0000-0000-000000000002', 32.00, CURRENT_TIMESTAMP - INTERVAL '1 day'),
    (gen_random_uuid(), 'f0000000-0000-0000-0000-000000000002', 35.00, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- 5. Seed Test Customer Address (Shivajinagar, Pune 411005)
INSERT INTO addresses (id, user_id, label, address_line1, address_line2, city, state, pincode, latitude, longitude, is_default) VALUES
    ('ad000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'Home', 'Flat 304, Green Park Heights', 'F.C. Road, Shivajinagar', 'Pune', 'Maharashtra', '411005', 18.5314000, 73.8446000, TRUE),
    ('ad000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002', 'Office', 'Tech Hub Tower B, 4th Floor', 'Senapati Bapat Road, Shivajinagar', 'Pune', 'Maharashtra', '411016', 18.5362000, 73.8300000, FALSE)
ON CONFLICT DO NOTHING;
