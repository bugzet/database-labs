# Документация базы данных - Система бронирования 

## Весь код в schema.sql!

##  Структура базы данных

### Таблица: `users` (Пользователи)
Хранит информацию о пользователях системы.

| Поле | Тип | Описание | Ограничения |
|------|-----|-----------|-------------|
| `id` | SERIAL | Уникальный идентификатор | PRIMARY KEY |
| `name` | VARCHAR(100) | Полное имя пользователя | NOT NULL |
| `phone` | VARCHAR(20) | Телефон для входа | UNIQUE, NOT NULL |
| `password_hash` | VARCHAR(255) | Хэш пароля | NOT NULL |
| `balance` | NUMERIC(10,2) | Баланс счета | DEFAULT 0.00, >= 0 |
| `role` | VARCHAR(20) | Роль пользователя | DEFAULT 'client' |
| `telegram_id` | BIGINT | Telegram ID пользователя | UNIQUE |
| `is_active` | BOOLEAN | Статус аккаунта | DEFAULT true |
| `last_login` | TIMESTAMP | Время последнего входа | |
| `created_at` | TIMESTAMP | Дата создания | DEFAULT CURRENT_TIMESTAMP |
| `updated_at` | TIMESTAMP | Дата обновления | DEFAULT CURRENT_TIMESTAMP |

**Роли пользователей:**
- `client` - Клиент (по умолчанию)
- `admin` - Администратор
- `manager` - Менеджер

### Таблица: `rooms` (Комнаты)
Хранит информацию о переговорных комнатах.

| Поле | Тип | Описание | Ограничения |
|------|-----|-----------|-------------|
| `id` | SERIAL | Уникальный идентификатор | PRIMARY KEY |
| `name` | VARCHAR(100) | Название комнаты | NOT NULL |
| `description` | TEXT | Описание комнаты | |
| `capacity` | INTEGER | Вместимость | > 0 |
| `price_per_hour` | NUMERIC(10,2) | Цена за час | NOT NULL, >= 0 |
| `status` | VARCHAR(20) | Статус доступности | DEFAULT 'available' |
| `created_at` | TIMESTAMP | Дата создания | DEFAULT CURRENT_TIMESTAMP |
| `updated_at` | TIMESTAMP | Дата обновления | DEFAULT CURRENT_TIMESTAMP |

**Статусы комнат:**
- `available` - Доступна для бронирования
- `unavailable` - Недоступна
- `maintenance` - На обслуживании

### Таблица: `equipment` (Оборудование)
Хранит оборудование, доступное в комнатах.

| Поле | Тип | Описание | Ограничения |
|------|-----|-----------|-------------|
| `id` | SERIAL | Уникальный идентификатор | PRIMARY KEY |
| `room_id` | INTEGER | ID связанной комнаты | FOREIGN KEY |
| `name` | VARCHAR(100) | Название оборудования | NOT NULL |
| `type` | VARCHAR(50) | Тип оборудования | NOT NULL |
| `description` | TEXT | Описание оборудования | |
| `status` | VARCHAR(20) | Состояние оборудования | DEFAULT 'working' |
| `purchase_date` | DATE | Дата покупки | |
| `last_service_date` | DATE | Дата последнего обслуживания | |
| `created_at` | TIMESTAMP | Дата создания | DEFAULT CURRENT_TIMESTAMP |
| `updated_at` | TIMESTAMP | Дата обновления | DEFAULT CURRENT_TIMESTAMP |

**Статусы оборудования:**
- `working` - Работает
- `maintenance` - На обслуживании
- `broken` - Сломано

### Таблица: `booking` (Бронирования)
Хранит бронирования комнат пользователями.

| Поле | Тип | Описание | Ограничения |
|------|-----|-----------|-------------|
| `id` | SERIAL | Уникальный идентификатор | PRIMARY KEY |
| `user_id` | INTEGER | Пользователь, сделавший бронирование | FOREIGN KEY |
| `room_id` | INTEGER | Забронированная комната | FOREIGN KEY |
| `start_time` | TIMESTAMP | Время начала бронирования | NOT NULL |
| `end_time` | TIMESTAMP | Время окончания бронирования | NOT NULL |
| `total_price` | NUMERIC(10,2) | Общая стоимость | NOT NULL, >= 0 |
| `status` | VARCHAR(20) | Статус бронирования | DEFAULT 'pending' |
| `created_at` | TIMESTAMP | Дата создания | DEFAULT CURRENT_TIMESTAMP |
| `updated_at` | TIMESTAMP | Дата обновления | DEFAULT CURRENT_TIMESTAMP |

**Статусы бронирований:**
- `pending` - Ожидает оплаты
- `paid` - Подтверждено и оплачено
- `cancelled` - Отменено
- `completed` - Успешно завершено

### Таблица: `payments` (Платежи)
Хранит информацию о платежах за бронирования.

| Поле | Тип | Описание | Ограничения |
|------|-----|-----------|-------------|
| `id` | SERIAL | Уникальный идентификатор | PRIMARY KEY |
| `booking_id` | INTEGER | Связанное бронирование | FOREIGN KEY, NOT NULL |
| `amount` | NUMERIC(10,2) | Сумма платежа | NOT NULL, >= 0 |
| `method` | VARCHAR(50) | Способ оплаты | DEFAULT 'online' |
| `status` | VARCHAR(20) | Статус платежа | DEFAULT 'pending' |
| `transaction_id` | INTEGER | Связанная транзакция | FOREIGN KEY |
| `created_at` | TIMESTAMP | Дата создания | DEFAULT CURRENT_TIMESTAMP |
| `updated_at` | TIMESTAMP | Дата обновления | DEFAULT CURRENT_TIMESTAMP |

**Способы оплаты:**
- `online` - Онлайн оплата
- `cash` - Наличными
- `balance` - С баланса пользователя

**Статусы платежей:**
- `pending` - В обработке
- `success` - Успешно завершен
- `failed` - Не удался
- `refunded` - Возвращен

### Таблица: `transactions` (Транзакции)
Хранит операции с балансом пользователей.

| Поле | Тип | Описание | Ограничения |
|------|-----|-----------|-------------|
| `id` | SERIAL | Уникальный идентификатор | PRIMARY KEY |
| `user_id` | INTEGER | ID пользователя | FOREIGN KEY, NOT NULL |
| `amount` | NUMERIC(10,2) | Сумма транзакции | NOT NULL |
| `type` | VARCHAR(20) | Тип транзакции | |
| `description` | TEXT | Описание транзакции | |
| `created_at` | TIMESTAMP | Дата создания | DEFAULT CURRENT_TIMESTAMP |

**Типы транзакций:**
- `deposit` - Пополнение баланса
- `withdraw` - Списание с баланса
- `refund` - Возврат платежа

##  Связи между таблицами
- users (1) ←→ (many) booking
- rooms (1) ←→ (many) booking
- rooms (1) ←→ (many) equipment
- booking (1) ←→ (1) payments
- users (1) ←→ (many) transactions
- transactions (1) ←→ (1) payments

## Создание бронирования:
INSERT INTO booking (user_id, room_id, start_time, end_time, total_price)
VALUES (1, 1, '2024-01-20 10:00:00', '2024-01-20 12:00:00', 2000.00);

## Оформление платежа(пока не трогал толком)
INSERT INTO payments (booking_id, amount, method, status)
VALUES (1, 2000.00, 'online', 'success');


///////////////////////////////////////////////////////////

### Пользователи (users)
- Регистрируются по номеру телефона
- Имеют роль (клиент, менеджер, администратор)
- Могут иметь баланс для оплаты бронирований

### Комнаты (rooms)
- Имеют различную вместимость
- Разную стоимость аренды в час
- Могут быть в разных статусах доступности

### Бронирования (booking)
- Связывают пользователей и комнаты
- Имеют временные интервалы
- Проходят через различные статусы

### Платежи (payments)
- Привязаны к бронированиям
- Поддерживают различные способы оплаты
- Отслеживают статус оплаты

## Типичные сценарии использования

### Бронирование комнаты:
1. Пользователь выбирает комнату и время
2. Создается запись в `booking` со статусом `pending`
3. Пользователь оплачивает бронирование
4. Создается запись в `payments`
5. Статус бронирования меняется на `paid`

### Пополнение баланса:
1. Пользователь вносит средства
2. Создается транзакция типа `deposit`
3. Баланс пользователя увеличивается

### Отмена бронирования:
1. Пользователь отменяет бронирование
2. Статус меняется на `cancelled`
3. Если была оплата - создается возврат