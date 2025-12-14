from flask import Blueprint, jsonify, request
from extensions import db
from models import User, Transaction
from utils import admin_required

admin_bp = Blueprint('admin', __name__)

@admin_bp.route('/api/admin/topup', methods=['POST'])
@admin_required
def admin_topup():
    """Пополнение баланса пользователю"""
    data = request.get_json()
    user_id = data.get('user_id')
    amount = float(data.get('amount', 0))

    if amount <= 0:
        return jsonify({"error": "Сумма должна быть положительной"}), 400

    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "Пользователь не найден"}), 404

    try:
        user.balance = float(user.balance) + amount

        tx = Transaction(
            user_id=user.id,
            amount=amount,
            type='deposit',
            description=f"Пополнение администратором"
        )

        db.session.add(tx)
        db.session.commit()

        return jsonify({
            "success": True,
            "new_balance": user.balance,
            "message": f"Баланс пользователя {user.name} пополнен на {amount} руб."
        })
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500