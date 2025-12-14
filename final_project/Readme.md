# CyberClub Management System

A full-stack web application for managing a computer club.  
The system features an interactive booking map, user balance management, a powerful administration dashboard, and a **Telegram Bot** for remote booking.

Built with **Flask**, **PostgreSQL**, and **Telebot**.

---

## Tech Stack

### Backend
- Python 3.10+
- Flask (Web Framework)
- SQLAlchemy (ORM)
- pyTelegramBotAPI (Telegram Bot)

### Database
- PostgreSQL

### Frontend
- HTML5  
- CSS3  
- JavaScript

---

## Key Features

- **Interactive Booking Map**  

- **Telegram Bot Booking**  

- **User System**  
  Single account for Website and Bot (linked via phone number).

- **Balance & Payments**  
  Internal wallet system.

- **Admin Dashboard**  
  User management and balance top-up functionality.

---

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/cyberclub-api.git
cd cyberclub-api
```

### 2. Configure Environment

Create a `.env` file in the root directory:

```ini
DB_USER=postgres
DB_PASSWORD=your_db_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cyberclub_db

# SQLAlchemy Connection String
SQLALCHEMY_DATABASE_URI=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}

# Telegram Bot Token (Get from @BotFather)
TELEGRAM_BOT_TOKEN=telegram_bot_token
```

---

### 3. Database Initialization (pgAdmin 4)

It is recommended to initialize the database manually using `schema.sql`.

1. Open **pgAdmin 4**
2. Right-click **Databases → Create → Database**
3. Name it `cyberclub_db` and click **Save**
4. Right-click on `cyberclub_db` → **Query Tool**
5. Open the `schema.sql` file from this project
6. Copy its contents and paste into the Query Tool
7. Click **Execute** to create all tables and constraints

---

### 4. Install Dependencies

```bash
pip install flask flask-sqlalchemy psycopg2-binary python-dotenv pytelegrambotapi
```

---

## Running the Project

You need to run the **Website** and the **Telegram Bot** in separate terminals.

### Terminal 1: Run Website

```bash
python app.py
```

Website will be available at:

```
http://127.0.0.1:5001
```

### Terminal 2: Run Telegram Bot

```bash
python bot.py
```

The bot will start polling for messages.

---

## Telegram Bot Guide & User Flow

The system is designed so that the **Website** is the primary place for registration and payments, while the **Bot** is a convenient tool for booking.

### Step 1: Registration (Website)

1. Open:  
   ```
   http://127.0.0.1:5001/register.html
   ```
2. Register a new account  
3. **Important:** Use the same phone number as in Telegram  
   (e.g. `+79991234567`)

---

### Step 2: Top Up Balance (Website / Admin)

The bot uses your **internal balance**.

1. Log in as an **Administrator**  
   (or use the *“Become Admin”* button in profile for testing)
2. Open **Admin Panel**
3. Find your user
4. Click **Top Up**

---

### Step 3: Link Telegram Account

1. Open your bot in Telegram
2. Send `/start`
3. Click **📱 Отправить номер телефона** (Share Contact)
4. The system will search for a user with this phone number:
   - ✅ **Found** → Telegram account is permanently linked
   - ❌ **Not found** → You will be asked to register on the website first

**WARNING! If you are unable to start the bot, your internet provider might be blocking the access. Consider using VPN.**

---

### Step 4: Booking via Bot

Once linked, use the bot menu:

- **🖥 Book**  
  Choose PC → Select Date (Today / Tomorrow) → Time → Duration

- **👤 Profile**  
  View current balance and active bookings

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|------|--------|-------------|
| POST | `/login` | User authentication |
| GET | `/users` | Get list of users |
| GET | `/rooms` | Get list of computers |
| GET | `/api/bookings/availability` | Get booked slots |
| POST | `/api/bookings/create` | Create a new booking (Web) |
| POST | `/api/admin/topup` | **Admin**: Top up user balance |

---
