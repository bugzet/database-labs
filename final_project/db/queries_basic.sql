-- 1. Все пользователи
SELECT * FROM users;

-- 2. Активные пользователи
SELECT id, name, phone
FROM users
WHERE is_active = true;

-- 3. Доступные комнаты
SELECT name, capacity, price_per_hour
FROM rooms
WHERE status = 'available';

-- 4. Бронирования пользователя
SELECT *
FROM booking
WHERE user_id = 1;
