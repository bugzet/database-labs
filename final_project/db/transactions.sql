			

SELECT * FROM public.users ORDER BY id ASC
00:42:59
SELECT * FROM public.users ORDER BY id ASC
17:11:06
SELECT * FROM public.users ORDER BY id ASC
15:21:44
SELECT * FROM public.user_sessions ORDER BY id ASC
11:28:44
SELECT * FROM public.users ORDER BY id ASC
10:57:17
CREATE TABLE user_sessions ( id SERIAL PRIMARY KEY, user_id INTEGER NOT NULL, session_token VARCHAR(255) UNIQUE NOT NULL, expires_at TIMESTAMP NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE );
15:06:11
SELECT * FROM public.users ORDER BY id ASC
14:34:08
SELECT * FROM public.users ORDER BY id ASC
14:14:56
SELECT * FROM public.users ORDER BY id ASC
16:21:59
SELECT * FROM public.rooms ORDER BY id ASC
15:14:03
SELECT * FROM public.rooms ORDER BY id ASC
15:05:03
SELECT * FROM public.users ORDER BY id ASC
11:46:00
SELECT * FROM public.users ORDER BY id ASC
11:36:52
SELECT * FROM public.users ORDER BY id ASC
11:13:32
SELECT * FROM public.users ORDER BY id ASC
11:08:22
SELECT * FROM public.rooms ORDER BY id ASC
17:00:11

-- Проверим "битые" связи (если такие есть)
-- Booking с несуществующими room_id
SELECT 'booking' as table_name, count(*) as broken_links
FROM booking 
WHERE room_id NOT IN (SELECT id FROM rooms)

UNION ALL

-- Equipment с несуществующими room_id
SELECT 'equipment', count(*) 
FROM equipment 
WHERE room_id NOT IN (SELECT id FROM rooms)

UNION ALL

-- Payments с несуществующими booking_id
SELECT 'payments', count(*) 
FROM payments 
WHERE booking_id NOT IN (SELECT id FROM booking)

UNION ALL

-- Payments с несуществующими transaction_id
SELECT 'payments_transaction', count(*) 
FROM payments 
WHERE transaction_id NOT IN (SELECT id FROM transactions)

UNION ALL

-- Transactions с несуществующими user_id
SELECT 'transactions', count(*) 
FROM transactions 
WHERE user_id NOT IN (SELECT id FROM users)

UNION ALL

-- Booking с несуществующими user_id
SELECT 'booking_user', count(*) 
FROM booking 
WHERE user_id NOT IN (SELECT id FROM users);
16:48:53
-- Проверим поля, которые ВЫГЛЯДЯТ как внешние ключи, но не имеют constraints SELECT table_name, column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' AND table_name IN ('booking', 'equipment', 'payments', 'transactions') AND column_name LIKE '%_id' AND column_name NOT IN ('id') AND (table_name, column_name) NOT IN ( SELECT tc.table_name, kcu.column_name FROM information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public' );
-- Проверим поля, которые ВЫГЛЯДЯТ как внешние ключи, но не имеют constraints
SELECT 
    table_name, 
    column_name,
    data_type
FROM 
    information_schema.columns 
WHERE 
    table_schema = 'public'
    AND table_name IN ('booking', 'equipment', 'payments', 'transactions')
    AND column_name LIKE '%_id'
    AND column_name NOT IN ('id')
    AND (table_name, column_name) NOT IN (
        SELECT 
            tc.table_name, 
            kcu.column_name
        FROM 
            information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
        WHERE 
            tc.constraint_type = 'FOREIGN KEY'
            AND tc.table_schema = 'public'
    );
16:48:30


SELECT 
    tc.table_schema,
    tc.table_name, 
    kcu.column_name,
    tc.constraint_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name 
WHERE 
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY 
    tc.table_name, kcu.column_name;
SELECT tc.table_schema, tc.table_name, kcu.column_name, tc.constraint_name, ccu.table_name AS foreign_table_name, ccu.column_name AS foreign_column_name FROM information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public' ORDER BY tc.table_name, kcu.column_name;
16:48:05
SELECT * FROM public.rooms
ORDER BY id ASC 
Total rows:
LF
Ln 1, Col 1