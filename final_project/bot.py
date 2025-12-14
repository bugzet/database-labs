import telebot
from telebot import types
import os
from datetime import datetime, timedelta
from dotenv import load_dotenv

from app import create_app
from extensions import db
from models import User, Room, Booking, Transaction, Payment

load_dotenv()
BOT_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN')

if not BOT_TOKEN:
    print("❌ Ошибка: Не найден TELEGRAM_BOT_TOKEN")
    exit()

bot = telebot.TeleBot(BOT_TOKEN)
app = create_app()

user_booking_steps = {}


# Главное меню

@bot.message_handler(commands=['start'])
def send_welcome(message):
    telegram_id = message.from_user.id

    with app.app_context():
        user = User.query.filter_by(telegram_id=telegram_id).first()

        if user:
            show_main_menu(message.chat.id, user.name)
        else:
            markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
            btn_phone = types.KeyboardButton(text="📱 Отправить номер телефона", request_contact=True)
            markup.add(btn_phone)

            bot.send_message(
                message.chat.id,
                "👋 Добро пожаловать!\nДля работы с ботом нужно авторизоваться.",
                reply_markup=markup
            )


def show_main_menu(chat_id, name):
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.add(types.KeyboardButton("🖥 Забронировать"), types.KeyboardButton("👤 Мой профиль"))
    bot.send_message(chat_id, f"Рад видеть, {name}! Что будем делать?", reply_markup=markup)


# Авторизация

@bot.message_handler(content_types=['contact'])
def handle_contact(message):
    if not message.contact: return

    telegram_id = message.from_user.id
    phone = message.contact.phone_number
    if not phone.startswith('+'): phone = '+' + phone

    with app.app_context():
        user = User.query.filter_by(phone=phone).first()
        if user:
            user.telegram_id = telegram_id
            db.session.commit()
            bot.send_message(message.chat.id, f"✅ Аккаунт {user.name} привязан!")
            show_main_menu(message.chat.id, user.name)
        else:
            bot.send_message(message.chat.id, "❌ Телефон не найден в базе. Зарегистрируйтесь на сайте.")


# ПРОФИЛЬ

@bot.message_handler(func=lambda message: message.text == "👤 Мой профиль")
def my_profile(message):
    with app.app_context():
        user = User.query.filter_by(telegram_id=message.from_user.id).first()
        if user:
            active_bookings = Booking.query.filter(
                Booking.user_id == user.id,
                Booking.end_time > datetime.utcnow(),
                Booking.status == 'paid'
            ).all()

            booking_info = ""
            if active_bookings:
                booking_info = "\n\n<b>Активные брони:</b>"
                for b in active_bookings:
                    start_fmt = b.start_time.strftime('%d.%m %H:%M')
                    booking_info += f"\n🖥 Комната #{b.room_id} | 🕒 {start_fmt}"

            bot.send_message(
                message.chat.id,
                f"👤 <b>{user.name}</b>\n💰 Баланс: {user.balance} ₽\n📱 {user.phone}{booking_info}",
                parse_mode='HTML'
            )
        else:
            bot.send_message(message.chat.id, "Сначала нажмите /start")


# Бронирование: 1. Выбор компьютера.

@bot.message_handler(func=lambda message: message.text == "🖥 Забронировать")
def start_booking(message):
    telegram_id = message.from_user.id

    with app.app_context():
        user = User.query.filter_by(telegram_id=telegram_id).first()
        if not user:
            bot.send_message(message.chat.id, "Сначала авторизуйтесь /start")
            return

        rooms = Room.query.order_by(Room.id).all()
        now = datetime.utcnow()

        # Исправленная логика: ищем тех, кто занят ИМЕННО СЕЙЧАС (start <= now < end)
        busy_bookings = Booking.query.filter(
            Booking.start_time <= now,
            Booking.end_time > now,
            Booking.status.in_(['paid', 'pending'])
        ).all()

        busy_ids = [b.room_id for b in busy_bookings]

        markup = types.ReplyKeyboardMarkup(resize_keyboard=True, row_width=3)
        buttons = []
        for room in rooms:
            status = "🔴" if room.id in busy_ids else "🟢"
            buttons.append(types.KeyboardButton(f"{status} {room.name}"))

        markup.add(*buttons)
        markup.add(types.KeyboardButton("🔙 Отмена"))

        bot.send_message(message.chat.id, "Выберите компьютер (🔴 - занят сейчас, 🟢 - свободен сейчас):",
                         reply_markup=markup)
        bot.register_next_step_handler(message, process_room_selection)


# Бронирование: 2. Выбор даты.

def process_room_selection(message):
    text = message.text
    if text == "🔙 Отмена":
        show_main_menu(message.chat.id, "Отмена")
        return

    room_name = text.split(" ", 1)[-1] if " " in text else text

    with app.app_context():
        room = Room.query.filter_by(name=room_name).first()
        if not room:
            bot.send_message(message.chat.id, "❌ Некорректный выбор.")
            return

        user_booking_steps[message.chat.id] = {'room': room}

        now = datetime.now()
        today_str = now.strftime("%d.%m")
        tomorrow_str = (now + timedelta(days=1)).strftime("%d.%m")

        markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.add(f"Сегодня ({today_str})", f"Завтра ({tomorrow_str})")
        markup.add("🔙 Отмена")

        bot.send_message(message.chat.id, f"Вы выбрали: <b>{room.name}</b>.\nНа какую дату?", parse_mode='HTML',
                         reply_markup=markup)
        bot.register_next_step_handler(message, process_date_selection)


# Бронирование: 3. Выбор времени.

def process_date_selection(message):
    text = message.text
    if text == "🔙 Отмена":
        show_main_menu(message.chat.id, "Отмена")
        return

    chat_id = message.chat.id
    now = datetime.now()

    if "Сегодня" in text:
        selected_date = now.date()
    elif "Завтра" in text:
        selected_date = (now + timedelta(days=1)).date()
    else:
        bot.send_message(chat_id, "Используйте кнопки для выбора даты.")
        return

    user_booking_steps[chat_id]['date'] = selected_date

    markup = types.ReplyKeyboardRemove()
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.add("🔙 Отмена")

    bot.send_message(
        chat_id,
        "Введите время начала (в формате ЧЧ:ММ).\nПример: <b>14:00</b> или <b>21:30</b>",
        parse_mode='HTML',
        reply_markup=markup
    )
    bot.register_next_step_handler(message, process_time_selection)


# Бронирование: 4. Длительность сеанса.

def process_time_selection(message):
    text = message.text
    chat_id = message.chat.id
    if text == "🔙 Отмена":
        show_main_menu(chat_id, "Отмена")
        return

    try:
        # Пытаемся распарсить время
        valid_time = datetime.strptime(text, "%H:%M").time()

        # Собираем полную дату старта
        date_part = user_booking_steps[chat_id]['date']
        start_dt = datetime.combine(date_part, valid_time)

        # Проверка: не прошло ли это время?
        if start_dt < datetime.now():
            bot.send_message(chat_id, "❌ Это время уже прошло. Введите будущее время.")
            bot.register_next_step_handler(message, process_time_selection)
            return

        user_booking_steps[chat_id]['start_dt'] = start_dt

        # Спрашиваем длительность
        markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.add("1", "2", "3", "4", "5", "🔙 Отмена")

        bot.send_message(chat_id, "На сколько часов бронируем?", reply_markup=markup)
        bot.register_next_step_handler(message, process_duration_selection)

    except ValueError:
        bot.send_message(chat_id, "❌ Неверный формат. Попробуйте еще раз (например: 18:00).")
        bot.register_next_step_handler(message, process_time_selection)


# Бронирование: 5. Подтверждение.

def process_duration_selection(message):
    if message.text == "🔙 Отмена":
        show_main_menu(message.chat.id, "Отмена")
        return

    if not message.text.isdigit():
        bot.send_message(message.chat.id, "Введите число.")
        return

    hours = int(message.text)
    chat_id = message.chat.id
    booking_data = user_booking_steps.get(chat_id)

    room = booking_data['room']
    start_dt = booking_data['start_dt']
    end_dt = start_dt + timedelta(hours=hours)

    booking_data['hours'] = hours
    booking_data['end_dt'] = end_dt

    total_price = room.price_per_hour * hours

    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.add("✅ Оплатить", "🔙 Отмена")

    bot.send_message(
        chat_id,
        f"📋 <b>Проверка брони:</b>\n\n"
        f"🖥 Компьютер: {room.name}\n"
        f"📅 Начало: {start_dt.strftime('%d.%m в %H:%M')}\n"
        f"⏳ Длительность: {hours} ч.\n"
        f"🏁 Конец: {end_dt.strftime('%H:%M')}\n"
        f"💵 Сумма: <b>{total_price} ₽</b>",
        parse_mode='HTML',
        reply_markup=markup
    )
    bot.register_next_step_handler(message, process_final_payment)

def process_final_payment(message):
    if message.text != "✅ Оплатить":
        show_main_menu(message.chat.id, "Отменено")
        return

    chat_id = message.chat.id
    data = user_booking_steps.get(chat_id)

    with app.app_context():
        user = User.query.filter_by(telegram_id=message.from_user.id).first()
        room = Room.query.get(data['room'].id)

        start_dt = data['start_dt']
        end_dt = data['end_dt']

        total_price = room.price_per_hour * data['hours']

        # 1. Проверка баланса
        if user.balance < total_price:
            bot.send_message(chat_id, f"❌ Недостаточно средств! Баланс: {user.balance} ₽")
            show_main_menu(chat_id, "Главное меню")
            return

        # 2. Проверка пересечений
        overlapping = Booking.query.filter(
            Booking.room_id == room.id,
            Booking.status.in_(['paid', 'pending']),
            Booking.start_time < end_dt,
            Booking.end_time > start_dt
        ).first()

        if overlapping:
            busy_start = overlapping.start_time.strftime('%H:%M')
            busy_end = overlapping.end_time.strftime('%H:%M')
            bot.send_message(chat_id, f"❌ Ошибка! Компьютер занят в интервале {busy_start} - {busy_end}.")
            show_main_menu(chat_id, "Попробуйте другое время")
            return

        try:
            user.balance -= total_price

            # Запись брони
            new_booking = Booking(
                user_id=user.id,
                room_id=room.id,
                start_time=start_dt,
                end_time=end_dt,
                total_price=total_price,
                status='paid'
            )
            db.session.add(new_booking)
            db.session.flush()

            # Транзакция и платеж
            db.session.add(Transaction(
                user_id=user.id, amount=-total_price, type='withdraw',
                description=f"Bot: {room.name} ({start_dt.strftime('%d.%m %H:%M')})"
            ))
            db.session.add(Payment(
                booking_id=new_booking.id, amount=total_price,
                method='balance', status='success'
            ))

            db.session.commit()
            bot.send_message(chat_id, "✅ Бронирование успешно! Ждем вас в клубе.")
            show_main_menu(chat_id, "Меню")

        except Exception as e:
            db.session.rollback()
            bot.send_message(chat_id, f"Ошибка сервера: {e}")
            print(f"Error: {e}")


if __name__ == '__main__':
    print("🤖 Бот запущен...\nПолучите доступ по адресу https://t.me/db_project_booking_bot")
    bot.infinity_polling()