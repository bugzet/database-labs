BEGIN;

-- Проверяем баланс
SELECT balance FROM users WHERE id = 1;

-- Списываем деньги
UPDATE users
SET balance = balance - 1000
WHERE id = 1;

-- Создаём транзакцию
INSERT INTO transactions (user_id, amount, type, description)
VALUES (1, -1000, 'withdraw', 'Room booking payment');

COMMIT;
