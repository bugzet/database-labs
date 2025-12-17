--
-- PostgreSQL database dump
--

\restrict 0EwuE0boCScWda1rBKgZdEXopeb1MmiZ2q0oAKUmOkEMv2huS9A53svvtvyvh2U

-- Dumped from database version 17.7
-- Dumped by pg_dump version 17.7

-- Started on 2025-12-18 00:32:28

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 16501)
-- Name: booking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.booking (
    id integer NOT NULL,
    user_id integer,
    room_id integer,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    total_price numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT booking_status_check CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('paid'::character varying)::text, ('cancelled'::character varying)::text, ('completed'::character varying)::text]))),
    CONSTRAINT booking_total_price_check CHECK ((total_price >= (0)::numeric))
);


ALTER TABLE public.booking OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16509)
-- Name: booking_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.booking_id_seq OWNER TO postgres;

--
-- TOC entry 4954 (class 0 OID 0)
-- Dependencies: 218
-- Name: booking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.booking_id_seq OWNED BY public.booking.id;


--
-- TOC entry 219 (class 1259 OID 16510)
-- Name: equipment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipment (
    id integer NOT NULL,
    room_id integer,
    name character varying(100) NOT NULL,
    type character varying(50) NOT NULL,
    description text,
    status character varying(20) DEFAULT 'working'::character varying,
    purchase_date date,
    last_service_date date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT equipment_status_check CHECK (((status)::text = ANY (ARRAY[('working'::character varying)::text, ('maintenance'::character varying)::text, ('broken'::character varying)::text])))
);


ALTER TABLE public.equipment OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16519)
-- Name: equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.equipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipment_id_seq OWNER TO postgres;

--
-- TOC entry 4955 (class 0 OID 0)
-- Dependencies: 220
-- Name: equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.equipment_id_seq OWNED BY public.equipment.id;


--
-- TOC entry 221 (class 1259 OID 16520)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    booking_id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    method character varying(50) DEFAULT 'online'::character varying,
    status character varying(20) DEFAULT 'pending'::character varying,
    transaction_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT payments_amount_check CHECK ((amount >= (0)::numeric)),
    CONSTRAINT payments_method_check CHECK (((method)::text = ANY (ARRAY[('online'::character varying)::text, ('cash'::character varying)::text, ('balance'::character varying)::text]))),
    CONSTRAINT payments_status_check CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('success'::character varying)::text, ('failed'::character varying)::text, ('refunded'::character varying)::text])))
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16530)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO postgres;

--
-- TOC entry 4956 (class 0 OID 0)
-- Dependencies: 222
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- TOC entry 223 (class 1259 OID 16531)
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    capacity integer,
    price_per_hour numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'available'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT rooms_capacity_check CHECK ((capacity > 0)),
    CONSTRAINT rooms_hourly_rate_check CHECK ((price_per_hour >= (0)::numeric)),
    CONSTRAINT rooms_status_check CHECK (((status)::text = ANY (ARRAY[('available'::character varying)::text, ('unavailable'::character varying)::text, ('maintenance'::character varying)::text])))
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16542)
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rooms_id_seq OWNER TO postgres;

--
-- TOC entry 4957 (class 0 OID 0)
-- Dependencies: 224
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;


--
-- TOC entry 225 (class 1259 OID 16543)
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    type character varying(20),
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT transactions_type_check CHECK (((type)::text = ANY (ARRAY[('deposit'::character varying)::text, ('withdraw'::character varying)::text, ('refund'::character varying)::text])))
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16550)
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transactions_id_seq OWNER TO postgres;

--
-- TOC entry 4958 (class 0 OID 0)
-- Dependencies: 226
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- TOC entry 230 (class 1259 OID 16613)
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_sessions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    session_token character varying(255) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone
);


ALTER TABLE public.user_sessions OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16612)
-- Name: user_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_sessions_id_seq OWNER TO postgres;

--
-- TOC entry 4959 (class 0 OID 0)
-- Dependencies: 229
-- Name: user_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_sessions_id_seq OWNED BY public.user_sessions.id;


--
-- TOC entry 227 (class 1259 OID 16551)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(20) NOT NULL,
    password_hash character varying(255) NOT NULL,
    balance numeric(10,2) DEFAULT 0.00,
    role character varying(20) DEFAULT 'client'::character varying,
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    telegram_id bigint,
    CONSTRAINT users_balance_check CHECK ((balance >= (0)::numeric)),
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('client'::character varying)::text, ('admin'::character varying)::text, ('manager'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16561)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 4960 (class 0 OID 0)
-- Dependencies: 228
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4725 (class 2604 OID 16562)
-- Name: booking id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking ALTER COLUMN id SET DEFAULT nextval('public.booking_id_seq'::regclass);


--
-- TOC entry 4729 (class 2604 OID 16563)
-- Name: equipment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment ALTER COLUMN id SET DEFAULT nextval('public.equipment_id_seq'::regclass);


--
-- TOC entry 4733 (class 2604 OID 16564)
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- TOC entry 4738 (class 2604 OID 16565)
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);


--
-- TOC entry 4742 (class 2604 OID 16566)
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- TOC entry 4750 (class 2604 OID 16616)
-- Name: user_sessions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions ALTER COLUMN id SET DEFAULT nextval('public.user_sessions_id_seq'::regclass);


--
-- TOC entry 4744 (class 2604 OID 16567)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4935 (class 0 OID 16501)
-- Dependencies: 217
-- Data for Name: booking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.booking (id, user_id, room_id, start_time, end_time, total_price, status, created_at, updated_at) FROM stdin;
1	1	1	2025-12-14 12:11:50.431351	2025-12-14 15:11:50.431351	300.00	paid	2025-12-14 17:11:50.422381	2025-12-14 17:11:50.422381
2	1	1	2025-12-15 18:36:00	2025-12-15 21:36:00	300.00	paid	2025-12-14 17:36:39.460729	2025-12-14 17:36:39.460729
3	1	1	2025-12-14 18:39:00	2025-12-14 21:39:00	300.00	paid	2025-12-14 17:39:14.153532	2025-12-14 17:39:14.153532
4	3	2	2025-12-15 18:43:00	2025-12-15 20:43:00	200.00	paid	2025-12-14 17:43:17.488978	2025-12-14 17:43:17.488978
5	3	11	2025-12-14 19:43:00	2025-12-14 21:43:00	500.00	paid	2025-12-14 17:43:35.386387	2025-12-14 17:43:35.386387
6	3	2	2025-12-14 18:44:00	2025-12-14 20:44:00	200.00	paid	2025-12-14 17:44:28.329761	2025-12-14 17:44:28.329761
7	3	3	2025-12-14 18:45:00	2025-12-14 20:45:00	200.00	paid	2025-12-14 17:45:17.865182	2025-12-14 17:45:17.865182
8	3	4	2025-12-17 18:45:00	2025-12-17 20:45:00	200.00	paid	2025-12-14 17:45:35.745117	2025-12-14 17:45:35.745117
9	3	4	2025-12-14 18:46:00	2025-12-14 20:46:00	200.00	paid	2025-12-14 17:46:05.960013	2025-12-14 17:46:05.960013
10	3	5	2025-12-14 18:46:00	2025-12-14 20:46:00	200.00	paid	2025-12-14 17:46:09.668937	2025-12-14 17:46:09.668937
11	1	6	2025-12-14 20:14:00	2025-12-14 22:14:00	200.00	paid	2025-12-14 19:14:51.913468	2025-12-14 19:14:51.913468
12	1	7	2025-12-14 20:14:00	2025-12-14 22:14:00	200.00	paid	2025-12-14 19:14:55.979014	2025-12-14 19:14:55.979014
13	1	8	2025-12-14 20:15:00	2025-12-14 20:15:00	0.00	paid	2025-12-14 19:15:10.891733	2025-12-14 19:15:10.891733
14	1	8	2025-12-14 20:15:00	2025-12-14 20:15:00	0.00	paid	2025-12-14 19:15:26.127015	2025-12-14 19:15:26.127015
15	1	8	2025-12-14 20:15:00	2025-12-14 20:15:00	0.00	paid	2025-12-14 19:15:31.497859	2025-12-14 19:15:31.497859
16	3	2	2025-12-14 21:29:00	2025-12-14 23:29:00	200.00	paid	2025-12-14 20:29:20.740665	2025-12-14 20:29:20.740665
17	3	3	2025-12-14 21:43:00	2025-12-14 23:43:00	200.00	paid	2025-12-14 20:43:48.263358	2025-12-14 20:43:48.263358
19	1	1	2025-12-14 23:05:00	2025-12-15 00:05:00	100.00	paid	2025-12-14 21:59:52.643653	2025-12-14 21:59:52.643653
20	1	8	2025-12-14 23:40:00	2025-12-15 01:40:00	200.00	paid	2025-12-14 22:34:31.616346	2025-12-14 22:34:31.616346
21	2	1	2025-12-16 12:45:00	2025-12-16 14:45:00	200.00	paid	2025-12-16 11:45:22.5807	2025-12-16 11:45:22.5807
22	1	1	2025-12-16 18:00:00	2025-12-16 19:00:00	100.00	paid	2025-12-16 11:48:05.791988	2025-12-16 11:48:05.791988
23	8	1	2025-12-17 22:00:00	2025-12-18 00:00:00	200.00	paid	2025-12-17 20:37:18.893137	2025-12-17 20:37:18.893137
24	9	2	2025-12-17 22:00:00	2025-12-18 00:00:00	200.00	paid	2025-12-17 20:42:52.295925	2025-12-17 20:42:52.295925
\.


--
-- TOC entry 4937 (class 0 OID 16510)
-- Dependencies: 219
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipment (id, room_id, name, type, description, status, purchase_date, last_service_date, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4939 (class 0 OID 16520)
-- Dependencies: 221
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, booking_id, amount, method, status, transaction_id, created_at, updated_at) FROM stdin;
1	1	300.00	balance	success	\N	2025-12-14 17:11:50.422381	2025-12-14 17:11:50.422381
2	2	300.00	balance	success	\N	2025-12-14 17:36:39.460729	2025-12-14 17:36:39.460729
3	3	300.00	balance	success	\N	2025-12-14 17:39:14.153532	2025-12-14 17:39:14.153532
4	4	200.00	balance	success	\N	2025-12-14 17:43:17.488978	2025-12-14 17:43:17.488978
5	5	500.00	balance	success	\N	2025-12-14 17:43:35.386387	2025-12-14 17:43:35.386387
6	6	200.00	balance	success	\N	2025-12-14 17:44:28.329761	2025-12-14 17:44:28.329761
7	7	200.00	balance	success	\N	2025-12-14 17:45:17.865182	2025-12-14 17:45:17.865182
8	8	200.00	balance	success	\N	2025-12-14 17:45:35.745117	2025-12-14 17:45:35.745117
9	9	200.00	balance	success	\N	2025-12-14 17:46:05.960013	2025-12-14 17:46:05.960013
10	10	200.00	balance	success	\N	2025-12-14 17:46:09.668937	2025-12-14 17:46:09.668937
11	11	200.00	balance	success	\N	2025-12-14 19:14:51.913468	2025-12-14 19:14:51.913468
12	12	200.00	balance	success	\N	2025-12-14 19:14:55.979014	2025-12-14 19:14:55.979014
13	13	0.00	balance	success	\N	2025-12-14 19:15:10.891733	2025-12-14 19:15:10.891733
14	14	0.00	balance	success	\N	2025-12-14 19:15:26.127015	2025-12-14 19:15:26.127015
15	15	0.00	balance	success	\N	2025-12-14 19:15:31.497859	2025-12-14 19:15:31.497859
16	16	200.00	balance	success	\N	2025-12-14 20:29:20.740665	2025-12-14 20:29:20.740665
17	17	200.00	balance	success	\N	2025-12-14 20:43:48.263358	2025-12-14 20:43:48.263358
19	19	100.00	balance	success	\N	2025-12-14 21:59:52.643653	2025-12-14 21:59:52.643653
20	20	200.00	balance	success	\N	2025-12-14 22:34:31.616346	2025-12-14 22:34:31.616346
21	21	200.00	balance	success	\N	2025-12-16 11:45:22.5807	2025-12-16 11:45:22.5807
22	22	100.00	balance	success	\N	2025-12-16 11:48:05.791988	2025-12-16 11:48:05.791988
23	23	200.00	balance	success	\N	2025-12-17 20:37:18.893137	2025-12-17 20:37:18.893137
24	24	200.00	balance	success	\N	2025-12-17 20:42:52.295925	2025-12-17 20:42:52.295925
\.


--
-- TOC entry 4941 (class 0 OID 16531)
-- Dependencies: 223
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, name, description, capacity, price_per_hour, status, created_at, updated_at) FROM stdin;
1	PC-01	Standard Hall	\N	100.00	available	2025-12-14 17:11:22.409581	2025-12-14 17:11:22.409581
2	PC-02	Standard Hall	\N	100.00	available	2025-12-14 17:11:22.409581	2025-12-14 17:11:22.409581
3	PC-03	Standard Hall	\N	100.00	available	2025-12-14 17:11:22.409581	2025-12-14 17:11:22.409581
4	PC-04	Standard Hall	\N	100.00	available	2025-12-14 17:11:22.409581	2025-12-14 17:11:22.409581
5	PC-05	Standard Hall	\N	100.00	available	2025-12-14 17:11:22.409581	2025-12-14 17:11:22.409581
6	PC-06	Standard Hall	\N	100.00	available	2025-12-14 17:11:22.409581	2025-12-14 17:11:22.409581
7	PC-07	Standard Hall	\N	100.00	available	2025-12-14 17:11:22.409581	2025-12-14 17:11:22.409581
8	PC-08	Standard Hall	\N	100.00	available	2025-12-14 17:11:22.409581	2025-12-14 17:11:22.409581
9	PC-09	Standard Hall	\N	100.00	available	2025-12-14 17:11:22.409581	2025-12-14 17:11:22.409581
10	PC-10	Standard Hall	\N	100.00	available	2025-12-14 17:11:22.409581	2025-12-14 17:11:22.409581
11	VIP-1	VIP Room	\N	250.00	available	2025-12-14 17:29:18.611933	2025-12-14 17:29:18.611933
12	VIP-2	VIP Room	\N	250.00	available	2025-12-14 17:29:18.611933	2025-12-14 17:29:18.611933
13	VIP-3	VIP Room	\N	250.00	available	2025-12-14 17:29:18.611933	2025-12-14 17:29:18.611933
14	VIP-4	VIP Room	\N	250.00	available	2025-12-14 17:29:18.611933	2025-12-14 17:29:18.611933
15	VIP-5	VIP Room	\N	250.00	available	2025-12-14 17:29:18.611933	2025-12-14 17:29:18.611933
\.


--
-- TOC entry 4943 (class 0 OID 16543)
-- Dependencies: 225
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transactions (id, user_id, amount, type, description, created_at) FROM stdin;
1	1	1000.00	deposit	Пополнение администратором	2025-12-14 13:35:28.324097
2	2	500.00	deposit	Пополнение администратором	2025-12-14 13:35:34.767177
3	3	20000.00	deposit	Пополнение администратором	2025-12-14 13:35:41.660334
4	1	-300.00	withdraw	Бронь PC-01 на 3ч	2025-12-14 17:11:50.422381
5	1	-300.00	withdraw	Бронь PC-01 на 3ч (15.12 18:36)	2025-12-14 17:36:39.460729
6	1	-300.00	withdraw	Бронь PC-01 на 3ч (14.12 18:39)	2025-12-14 17:39:14.153532
7	3	-200.00	withdraw	Бронь PC-02 на 2ч (15.12 18:43)	2025-12-14 17:43:17.488978
8	3	-500.00	withdraw	Бронь VIP-1 на 2ч (14.12 19:43)	2025-12-14 17:43:35.386387
9	3	-200.00	withdraw	Бронь PC-02 на 2ч (14.12 18:44)	2025-12-14 17:44:28.329761
10	3	-200.00	withdraw	Бронь PC-03 на 2ч (14.12 18:45)	2025-12-14 17:45:17.865182
11	3	-200.00	withdraw	Бронь PC-04 на 2ч (17.12 18:45)	2025-12-14 17:45:35.745117
12	3	-200.00	withdraw	Бронь PC-04 на 2ч (14.12 18:46)	2025-12-14 17:46:05.960013
13	3	-200.00	withdraw	Бронь PC-05 на 2ч (14.12 18:46)	2025-12-14 17:46:09.668937
14	1	-200.00	withdraw	Бронь PC-06 на 2ч (14.12 20:14)	2025-12-14 19:14:51.913468
15	1	-200.00	withdraw	Бронь PC-07 на 2ч (14.12 20:14)	2025-12-14 19:14:55.979014
16	1	0.00	withdraw	Бронь PC-08 на 0ч (14.12 20:15)	2025-12-14 19:15:10.891733
17	1	0.00	withdraw	Бронь PC-08 на 0ч (14.12 20:15)	2025-12-14 19:15:26.127015
18	1	0.00	withdraw	Бронь PC-08 на 0ч (14.12 20:15)	2025-12-14 19:15:31.497859
19	1	200.00	deposit	Пополнение администратором	2025-12-14 20:19:15.010358
20	1	500.00	deposit	Пополнение администратором	2025-12-14 20:19:19.879754
21	3	-200.00	withdraw	Бронь PC-02 на 2ч (14.12 21:29)	2025-12-14 20:29:20.740665
22	3	-200.00	withdraw	Бронь PC-03 на 2ч (14.12 21:43)	2025-12-14 20:43:48.263358
23	1	-100.00	withdraw	Bot: PC-01 (14.12 23:05)	2025-12-14 21:59:52.643653
24	1	-200.00	withdraw	Bot: PC-08 (14.12 23:40)	2025-12-14 22:34:31.616346
25	2	-200.00	withdraw	Бронь PC-01 на 2ч (16.12 12:45)	2025-12-16 11:45:22.5807
26	6	500.00	deposit	Пополнение администратором	2025-12-16 11:46:40.451283
27	1	-100.00	withdraw	Bot: PC-01 (16.12 18:00)	2025-12-16 11:48:05.791988
28	8	-200.00	withdraw	Бронь PC-01 на 2ч (17.12 22:00)	2025-12-17 20:37:18.893137
29	1	1000.00	deposit	Пополнение администратором	2025-12-17 20:38:25.923399
30	9	200.00	deposit	Пополнение администратором	2025-12-17 20:39:52.684818
31	9	-200.00	withdraw	Bot: PC-02 (17.12 22:00)	2025-12-17 20:42:52.295925
32	9	1000.00	deposit	Пополнение администратором	2025-12-17 20:43:36.634305
\.


--
-- TOC entry 4948 (class 0 OID 16613)
-- Dependencies: 230
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_sessions (id, user_id, session_token, expires_at, created_at) FROM stdin;
8	1	7e2L_KcJrWl25f03W6CTJ-7SxF-2RTKckfALI1d_6-c	2025-12-21 14:13:14.232573	2025-12-14 19:13:14.234811
12	3	WWIKFKkiLAQG_P_aA2F2MT4IXTfBK5XB1Wtl9WFitww	2025-12-21 16:01:00.702307	2025-12-14 21:01:00.707479
16	2	3MldBDmZBQAj0JPsmS13bNDQS3KOz4uI09BBVhAIC0M	2025-12-21 16:09:44.495632	2025-12-14 21:09:44.494546
17	4	cfaBdW_5FSq6UX1wZsZCxjDHSLJUA690KdU9RiQF_Ww	2025-12-23 06:45:51.507158	2025-12-16 11:45:51.506415
18	8	GxobbMLQ5qXZjEECdyDbL1-X0Rflkny1fPTFNvKVc4c	2025-12-24 15:36:39.694769	2025-12-17 20:36:39.693501
\.


--
-- TOC entry 4945 (class 0 OID 16551)
-- Dependencies: 227
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, phone, password_hash, balance, role, is_active, last_login, created_at, updated_at, telegram_id) FROM stdin;
9	Ivan Ivanovich	+79252003337	123123	1000.00	client	t	\N	2025-12-17 20:39:35.305148	2025-12-17 20:43:36.634305	921816687
5	asdasddas	+996708004415	вфывфыв	0.00	client	t	\N	2025-12-14 19:44:12.452737	2025-12-14 19:44:12.452737	\N
3	Кубат	+88567456456	asdasdasd	17900.00	admin	t	2025-12-14 16:01:00.702307	2025-12-14 13:11:32.279857	2025-12-14 21:01:00.707479	\N
7	Иван иванович	+996708004461	ьщещьщещ	0.00	client	t	\N	2025-12-16 11:44:42.833766	2025-12-16 11:44:42.833766	\N
2	Кубат	+996708004413	MOTOMTOO	4800.00	admin	t	2025-12-14 16:09:44.497644	2025-12-14 13:11:03.573228	2025-12-16 11:45:22.5807	\N
4	Super_idol	+8888888888	Super_idol	5000.00	admin	t	2025-12-16 06:45:51.520961	2025-12-14 19:13:36.404282	2025-12-16 11:46:09.845875	\N
6	motomoto	+88756445645	asdasd	500.00	client	t	\N	2025-12-14 19:44:28.0111	2025-12-16 11:46:40.451283	\N
8	Ivan Ivanov	+99677788877	123123	4800.00	admin	t	2025-12-17 15:36:39.709404	2025-12-17 20:36:12.853279	2025-12-17 20:37:18.893137	\N
1	Иван Иванов	+996708004412	motomoto	1500.00	client	t	2025-12-14 14:13:14.245298	2025-12-09 00:00:08.183694	2025-12-17 20:38:25.923399	628098140
\.


--
-- TOC entry 4961 (class 0 OID 0)
-- Dependencies: 218
-- Name: booking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.booking_id_seq', 24, true);


--
-- TOC entry 4962 (class 0 OID 0)
-- Dependencies: 220
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.equipment_id_seq', 1, false);


--
-- TOC entry 4963 (class 0 OID 0)
-- Dependencies: 222
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 24, true);


--
-- TOC entry 4964 (class 0 OID 0)
-- Dependencies: 224
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_id_seq', 15, true);


--
-- TOC entry 4965 (class 0 OID 0)
-- Dependencies: 226
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transactions_id_seq', 32, true);


--
-- TOC entry 4966 (class 0 OID 0)
-- Dependencies: 229
-- Name: user_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_sessions_id_seq', 18, true);


--
-- TOC entry 4967 (class 0 OID 0)
-- Dependencies: 228
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 9, true);


--
-- TOC entry 4764 (class 2606 OID 16569)
-- Name: booking booking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_pkey PRIMARY KEY (id);


--
-- TOC entry 4766 (class 2606 OID 16571)
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- TOC entry 4768 (class 2606 OID 16573)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 4770 (class 2606 OID 16575)
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- TOC entry 4772 (class 2606 OID 16577)
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- TOC entry 4780 (class 2606 OID 16618)
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 4782 (class 2606 OID 16620)
-- Name: user_sessions user_sessions_session_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_session_token_key UNIQUE (session_token);


--
-- TOC entry 4774 (class 2606 OID 16579)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 4776 (class 2606 OID 16581)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4778 (class 2606 OID 16627)
-- Name: users users_telegram_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_telegram_id_key UNIQUE (telegram_id);


--
-- TOC entry 4783 (class 2606 OID 16582)
-- Name: booking booking_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- TOC entry 4784 (class 2606 OID 16587)
-- Name: booking booking_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4785 (class 2606 OID 16592)
-- Name: equipment equipment_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE SET NULL;


--
-- TOC entry 4786 (class 2606 OID 16597)
-- Name: payments payments_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.booking(id) ON DELETE CASCADE;


--
-- TOC entry 4787 (class 2606 OID 16602)
-- Name: payments payments_transaction_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_transaction_fk FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE CASCADE;


--
-- TOC entry 4788 (class 2606 OID 16607)
-- Name: transactions transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4789 (class 2606 OID 16621)
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


-- Completed on 2025-12-18 00:32:28

--
-- PostgreSQL database dump complete
--

\unrestrict 0EwuE0boCScWda1rBKgZdEXopeb1MmiZ2q0oAKUmOkEMv2huS9A53svvtvyvh2U

