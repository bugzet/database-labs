-- Индекс для входа по телефону
CREATE INDEX idx_users_phone ON users(phone);

-- Индекс для бронирований пользователя
CREATE INDEX idx_booking_user_id ON booking(user_id);

-- Индекс для бронирований комнаты
CREATE INDEX idx_booking_room_id ON booking(room_id);

-- Индекс для платежей
CREATE INDEX idx_payments_booking_id ON payments(booking_id);

-- Индекс для транзакций пользователя
CREATE INDEX idx_transactions_user_id ON transactions(user_id);

