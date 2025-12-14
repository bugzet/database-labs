from flask import Blueprint, request, jsonify
from extensions import db
from models import User, UserSession
import secrets
from datetime import datetime, timedelta

auth_bp = Blueprint('auth', __name__)

# ======== АВТОРИЗАЦИЯ ==========

@auth_bp.route('/login', methods=['POST'])
def login():
    """Вход пользователя в систему"""
    try:
        data = request.get_json()
        print("🔐 Попытка входа:", data)

        if not data or 'phone' not in data or 'password_hash' not in data:
            return jsonify({"error": "Требуется телефон и пароль"}), 400

        # Ищем пользователя
        user = User.query.filter_by(phone=data['phone'].strip()).first()

        if not user:
            return jsonify({"error": "Пользователь с таким телефоном не найден"}), 404

        # Проверяем пароль
        if user.password_hash != data['password_hash']:
            return jsonify({"error": "Неверный пароль"}), 401

        # Проверяем активность
        if not user.is_active:
            return jsonify({"error": "Аккаунт деактивирован"}), 403

        # Создаем сессию
        session_token = secrets.token_urlsafe(32)
        expires_at = datetime.utcnow() + timedelta(days=7)

        # Удаляем старые сессии этого пользователя
        UserSession.query.filter_by(user_id=user.id).delete()

        # Создаем новую сессию
        new_session = UserSession(
            user_id=user.id,
            session_token=session_token,
            expires_at=expires_at
        )

        # Обновляем время последнего входа
        user.last_login = datetime.utcnow()

        db.session.add(new_session)
        db.session.commit()

        print(f"✅ Создана сессия для пользователя {user.id} ({user.name})")

        return jsonify({
            "success": True,
            "message": "Вход выполнен успешно",
            "session_token": session_token,
            "user": user.to_dict(),
            "expires_at": expires_at.isoformat()
        }), 200

    except Exception as e:
        print("❌ Ошибка при входе:", e)
        db.session.rollback()
        return jsonify({"error": f"Ошибка сервера: {str(e)}"}), 500


@auth_bp.route('/logout', methods=['POST'])
def logout():
    """Выход из системы"""
    try:
        data = request.get_json()

        if not data or 'session_token' not in data:
            return jsonify({"error": "Требуется токен сессии"}), 400

        session = UserSession.query.filter_by(session_token=data['session_token']).first()

        if session:
            db.session.delete(session)
            db.session.commit()
            return jsonify({"success": True, "message": "Выход выполнен успешно"}), 200

        return jsonify({"error": "Сессия не найдена"}), 404

    except Exception as e:
        print("❌ Ошибка при выходе:", e)
        return jsonify({"error": str(e)}), 500

@auth_bp.route('/profile', methods=['GET'])
def get_profile():
    """Получение профиля пользователя"""
    try:
        auth_header = request.headers.get('Authorization', '')

        if not auth_header.startswith('Bearer '):
            return jsonify({"error": "Требуется авторизация"}), 401

        session_token = auth_header.replace('Bearer ', '')

        # Ищем сессию
        session = UserSession.query.filter_by(session_token=session_token).first()

        if not session:
            return jsonify({"error": "Недействительная сессия"}), 401

        # Проверяем срок действия
        if session.expires_at < datetime.utcnow():
            db.session.delete(session)
            db.session.commit()
            return jsonify({"error": "Сессия истекла"}), 401

        # Получаем пользователя
        user = User.query.get(session.user_id)

        if not user:
            return jsonify({"error": "Пользователь не найден"}), 404

        print(f"✅ Профиль загружен для пользователя {user.id}")

        return jsonify({
            "success": True,
            "user": user.to_dict()
        }), 200

    except Exception as e:
        print("❌ Ошибка при загрузке профиля:", e)
        return jsonify({"error": str(e)}), 500

@auth_bp.route('/verify-session', methods=['POST'])
def verify_session():
    """Проверка валидности сессии"""
    try:
        data = request.get_json()

        if not data or 'session_token' not in data:
            return jsonify({"error": "Требуется токен сессии"}), 400

        session = UserSession.query.filter_by(session_token=data['session_token']).first()

        if not session:
            return jsonify({"error": "Недействительная сессия"}), 401

        # Проверяем срок действия
        if session.expires_at < datetime.utcnow():
            db.session.delete(session)
            db.session.commit()
            return jsonify({"error": "Сессия истекла"}), 401

        # Обновляем срок действия
        session.expires_at = datetime.utcnow() + timedelta(days=7)
        db.session.commit()

        return jsonify({
            "success": True,
            "valid": True,
            "user": session.user.to_dict(),
            "expires_at": session.expires_at.isoformat()
        }), 200

    except Exception as e:
        print("❌ Ошибка проверки сессии:", e)
        return jsonify({"error": str(e)}), 500