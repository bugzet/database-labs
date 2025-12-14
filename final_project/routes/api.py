from flask import Blueprint, jsonify, request
from extensions import db
from models import User, Room, Booking, Transaction, Payment
from utils import get_current_user
from datetime import datetime, timedelta

api_bp = Blueprint('api', __name__)

# ======== ПОЛЬЗОВАТЕЛИ ==========

@api_bp.route('/users', methods=['GET'])
def get_users():
    """Получить всех пользователей"""
    users = User.query.order_by(User.id).all()
    return jsonify([u.to_dict() for u in users])

@api_bp.route('/users', methods=['POST'])
def add_user():
    data = request.get_json()

    if not data or 'name' not in data or 'phone' not in data or 'password_hash' not in data:
        return jsonify({"error": "Отсутствуют обязательные поля: name, phone, password_hash"}), 400

    # Проверяем формат телефона
    phone = data['phone'].strip()
    if not phone.startswith('+') or len(phone) < 10:
        return jsonify({"error": "Неверный формат телефона. Используйте формат: +79991234567"}), 400

    # Проверяем существование пользователя
    existing_user = User.query.filter_by(phone=phone).first()
    if existing_user:
        return jsonify({"error": "Пользователь с таким телефоном уже существует"}), 400

    # Проверяем имя
    name = data['name'].strip()
    if len(name) < 2:
        return jsonify({"error": "Имя должно содержать минимум 2 символа"}), 400

    # Проверяем пароль
    password = data['password_hash']
    if len(password) < 4:
        return jsonify({"error": "Пароль должен содержать минимум 4 символа"}), 400

    try:
        new_user = User(
            name=name,
            phone=phone,
            password_hash=password,
            balance=data.get('balance', 0.00),
            role=data.get('role', 'client')
        )

        db.session.add(new_user)
        db.session.commit()

        return jsonify({
            "success": True,
            "message": "Пользователь успешно создан",
            "user_id": new_user.id,
            "user": new_user.to_dict()
        }), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": f"Ошибка базы данных: {str(e)}"}), 500

@api_bp.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """Получить пользователя по ID"""
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "Пользователь не найден"}), 404
    return jsonify(user.to_dict())

@api_bp.route('/check-phone/<phone>', methods=['GET'])
def check_phone(phone):
    """Проверить существует ли телефон"""
    user = User.query.filter_by(phone=phone).first()
    if user:
        return jsonify({"exists": True, "message": "Пользователь с таким телефоном уже существует"})
    return jsonify({"exists": False})


@api_bp.route('/users/become_admin', methods=['POST'])
def become_admin():
    """Секретный эндпоинт: делает текущего пользователя админом"""
    user = get_current_user()
    if not user:
        return jsonify({"error": "Необходима авторизация"}), 401

    try:
        user.role = 'admin'
        # Начисляем немного денег для тестов, если баланс пустой
        if float(user.balance) < 1000:
            user.balance = 5000.00

        db.session.commit()

        return jsonify({
            "success": True,
            "message": "👑 Вы теперь Администратор! Баланс пополнен."
        })
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

# ======== ЗАЛЫ ==========

@api_bp.route('/rooms', methods=['GET'])
def get_rooms():
    """Получить все залы"""
    rooms = Room.query.all()
    return jsonify([r.to_dict() for r in rooms])

@api_bp.route('/rooms/<int:room_id>', methods=['GET'])
def get_room(room_id):
    """Получить зал по ID"""
    room = Room.query.get_or_404(room_id)
    return jsonify(room.to_dict())

@api_bp.route('/rooms', methods=['POST'])
def add_room():
    data = request.get_json()

    if not data or 'name' not in data:
        return jsonify({"error": "Название зала обязательно"}), 400

    try:
        new_room = Room(
            name=data['name'],
            description=data.get('description', ''),
            capacity=data.get('capacity', 1),
            price_per_hour=data.get('price_per_hour', 0),
            status=data.get('status', 'active')
        )

        db.session.add(new_room)
        db.session.commit()

        return jsonify({"message": "Зал создан успешно", "room_id": new_room.id}), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": f"Ошибка базы данных: {str(e)}"}), 500

# ======== БРОНИРОВАНИЕ ==========

@api_bp.route('/api/bookings/availability', methods=['GET'])
def get_availability():
    """Получить занятые слоты для карты"""
    bookings = Booking.query.filter(
        Booking.status.in_(['paid', 'pending']),
        Booking.end_time > datetime.utcnow()
    ).all()
    return jsonify([b.to_dict() for b in bookings])

@api_bp.route('/api/bookings/create', methods=['POST'])
def create_booking():
    user = get_current_user()
    if not user:
        return jsonify({"error": "Необходима авторизация"}), 401

    data = request.get_json()
    room_id = data.get('room_id')
    hours = int(data.get('hours', 1))

    start_time_str = data.get('start_time')

    if start_time_str:
        try:
            start_time = datetime.fromisoformat(start_time_str)
        except ValueError:
            return jsonify({"error": "Неверный формат даты"}), 400
    else:
        start_time = datetime.utcnow()

    # Проверка: нельзя бронировать в прошлом
    if start_time < datetime.utcnow() - timedelta(minutes=5):
        return jsonify({"error": "Нельзя забронировать время в прошлом"}), 400

    end_time = start_time + timedelta(hours=hours)

    room = Room.query.get(room_id)
    if not room:
        return jsonify({"error": "Компьютер не найден"}), 404

    total_price = float(room.price_per_hour) * hours

    # Проверка баланса
    if float(user.balance) < total_price:
        return jsonify({"error": f"Недостаточно средств. Нужно {total_price}, у вас {user.balance}"}), 400

    # Проверка пересечений (Занят ли комп в этот интервал?)
    overlapping = Booking.query.filter(
        Booking.room_id == room_id,
        Booking.status.in_(['paid', 'pending']),
        Booking.start_time < end_time,  # Новая бронь начинается до конца старой
        Booking.end_time > start_time  # И заканчивается после начала старой
    ).first()

    if overlapping:
        return jsonify({"error": f"В это время компьютер занят (до {overlapping.end_time.strftime('%H:%M')})"}), 409

    try:
        # 1. Списание средств
        user.balance = float(user.balance) - total_price

        # 2. Транзакция
        tx = Transaction(
            user_id=user.id,
            amount=-total_price,
            type='withdraw',
            description=f"Бронь {room.name} на {hours}ч ({start_time.strftime('%d.%m %H:%M')})"
        )
        db.session.add(tx)
        db.session.flush()

        # 3. Бронь
        booking = Booking(
            user_id=user.id,
            room_id=room.id,
            start_time=start_time,
            end_time=end_time,
            total_price=total_price,
            status='paid'
        )
        db.session.add(booking)
        db.session.flush()

        # 4. Платеж
        payment = Payment(
            booking_id=booking.id,
            amount=total_price,
            method='balance',
            status='success'
        )
        db.session.add(payment)

        db.session.commit()
        return jsonify({"success": True, "message": "Успешно забронировано!", "new_balance": user.balance})

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500