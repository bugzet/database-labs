from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os
from dotenv import load_dotenv

from extensions import db

# Импорт Blueprint-ов
from routes.auth import auth_bp
from routes.api import api_bp
from routes.admin import admin_bp
from routes.views import views_bp


def create_app():
    load_dotenv()
    app = Flask(__name__)

    app.config['JSON_AS_ASCII'] = False
    app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('SQLALCHEMY_DATABASE_URI')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    db.init_app(app)

    app.register_blueprint(views_bp)
    app.register_blueprint(auth_bp)
    app.register_blueprint(admin_bp)
    app.register_blueprint(api_bp)

    return app


if __name__ == '__main__':
    app = create_app()

    with app.app_context():
        try:
            db.create_all()
            print("✅ База данных инициализирована")
        except Exception as e:
            print(f"❌ Ошибка инициализации БД: {e}")

    print("🚀 Сервер запускается на http://127.0.0.1:5001")
    app.run(debug=True, host='127.0.0.1', port=5001)