-- 5. JOIN: кто и какую комнату бронировал
SELECT u.name AS user_name,
       r.name AS room_name,
       b.start_time,
       b.end_time,
       b.total_price
FROM booking b
JOIN users u ON b.user_id = u.id
JOIN rooms r ON b.room_id = r.id;

-- 6. GROUP BY: доход по комнатам
SELECT r.name,
       SUM(b.total_price) AS total_income
FROM booking b
JOIN rooms r ON b.room_id = r.id
WHERE b.status = 'paid'
GROUP BY r.name;

-- 7. HAVING: пользователи с более чем 2 бронированиями
SELECT u.name,
       COUNT(b.id) AS bookings_count
FROM users u
JOIN booking b ON u.id = b.user_id
GROUP BY u.name
HAVING COUNT(b.id) > 2;

-- 8. Подзапрос: пользователи с платежами > 5000
SELECT name
FROM users
WHERE id IN (
    SELECT user_id
    FROM booking
    WHERE total_price > 5000
);
