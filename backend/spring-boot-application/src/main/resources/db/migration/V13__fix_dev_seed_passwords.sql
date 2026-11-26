-- V13: Ensure seeded development users have a valid BCrypt hash for 'password123'
UPDATE users
SET password_hash = '$2a$10$8HxY/u.tPJp68ImZfy6SFeiRiRPneYpVdTL2pyuE4Y8eKfkBiX1y.'
WHERE id IN (
    'a0000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000002',
    'a0000000-0000-0000-0000-000000000003',
    'a0000000-0000-0000-0000-000000000004'
)
  AND password_hash = '$2a$10$e8pCgLgD0xkWc55eQ10p3ekq94.U6LqfPvZJm53l2i2YmR1wH1f1m';
