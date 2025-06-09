-- Restore user
INSERT INTO users (user_id, username, email, password_hash, role, phone_number, first_name, last_name, created_at, updated_at, is_active)
SELECT user_id, username, email, password_hash, role, phone_number, first_name, last_name, created_at, updated_at, is_active
FROM users
WHERE user_id = 'USR090';

