from flask import request, jsonify
from functools import wraps
from models import User, UserSession
from datetime import datetime

def get_current_user():
    auth_header = request.headers.get('Authorization', '')
    if not auth_header.startswith('Bearer '):
        return None
    token = auth_header.replace('Bearer ', '')
    session = UserSession.query.filter_by(session_token=token).first()
    if session and session.expires_at > datetime.utcnow():
        return User.query.get(session.user_id)
    return None

def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        user = get_current_user()
        if not user or user.role != 'admin':
            return jsonify({"error": "Доступ запрещен. Требуются права администратора"}), 403
        return f(*args, **kwargs)
    return decorated_function