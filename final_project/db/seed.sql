--
-- PostgreSQL database dump
--

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.5

-- Started on 2025-12-16 16:25:51 +06

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

--
-- TOC entry 3760 (class 0 OID 25018)
-- Dependencies: 220
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, name, description, capacity, price_per_hour, status, created_at, updated_at) FROM stdin;
3	Кибер-арена 1	Зал_1	20	500.00	available	2025-11-10 15:13:20.302954	2025-11-10 15:13:20.302954
4	Кибер-арена 2	Зал_2	10	130.00	available	2025-11-10 15:26:15.261228	2025-11-10 15:26:15.261228
\.


--
-- TOC entry 3758 (class 0 OID 25002)
-- Dependencies: 218
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, phone, password_hash, balance, role, is_active, last_login, created_at, updated_at) FROM stdin;
1	Иван Иванов	+79991234567	123456	1000.00	client	t	\N	2025-11-10 11:31:39.211284	2025-11-10 11:31:39.211284
4	Администратор	+79999999999	admin	0.00	admin	t	\N	2025-11-10 11:44:48.394186	2025-11-10 11:44:48.394186
5	Менеджер	+78888888888	manager	0.00	manager	t	\N	2025-11-10 11:44:55.788579	2025-11-10 11:44:55.788579
6	Алтына	+0123123	123	0.00	client	t	\N	2025-11-11 14:32:16.183356	2025-11-11 14:32:16.183356
9	цйцуцйу	+996500552620	5421	0.00	client	t	\N	2025-11-13 10:56:58.658903	2025-11-13 10:56:58.658903
8	BOLOT	+996500532620	1234	0.00	client	t	2025-11-13 05:13:30.490639	2025-11-12 14:33:51.554221	2025-11-13 11:13:30.487386
3	ULUK ULUKBEKOV	+79252003337	123456	1000.00	client	t	2025-11-13 05:28:23.653666	2025-11-10 11:35:37.441083	2025-11-13 11:28:23.647415
10	Sharabidinova Aidai	+996553053969	parol	0.00	client	t	2025-11-18 11:14:25.142775	2025-11-18 17:13:06.500525	2025-11-18 17:14:25.13326
\.


--
-- TOC entry 3762 (class 0 OID 25033)
-- Dependencies: 222
-- Data for Name: booking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.booking (id, user_id, room_id, start_time, end_time, total_price, status, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 3766 (class 0 OID 25074)
-- Dependencies: 226
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipment (id, room_id, name, type, description, status, purchase_date, last_service_date, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 3768 (class 0 OID 25092)
-- Dependencies: 228
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transactions (id, user_id, amount, type, description, created_at) FROM stdin;
\.


--
-- TOC entry 3764 (class 0 OID 25055)
-- Dependencies: 224
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, booking_id, amount, method, status, transaction_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 3770 (class 0 OID 25164)
-- Dependencies: 230
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_sessions (id, user_id, session_token, expires_at, created_at) FROM stdin;
1	8	mgyo8uqAChVz3dWpJXudsJbc247jjX0Q-Rv-xvXU9fc	2025-11-20 05:13:30.490541	2025-11-13 11:13:30.487386
2	3	V8bbr6AH1iiQH2MjnVpFthMfwwvSa7H3Jbsdkhzp6oQ	2025-11-20 05:28:23.64867	2025-11-13 11:28:23.647415
\.


--
-- TOC entry 3776 (class 0 OID 0)
-- Dependencies: 221
-- Name: booking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.booking_id_seq', 1, false);


--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 225
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.equipment_id_seq', 1, false);


--
-- TOC entry 3778 (class 0 OID 0)
-- Dependencies: 223
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 1, false);


--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 219
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_id_seq', 4, true);


--
-- TOC entry 3780 (class 0 OID 0)
-- Dependencies: 227
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transactions_id_seq', 1, false);


--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 229
-- Name: user_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_sessions_id_seq', 3, true);


--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 217
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 10, true);


-- Completed on 2025-12-16 16:25:51 +06

--
-- PostgreSQL database dump complete
--

