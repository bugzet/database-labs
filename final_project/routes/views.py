from flask import Blueprint, render_template

views_bp = Blueprint('views', __name__)

@views_bp.route('/')
@views_bp.route('/index.html')
def index():
    return render_template('index.html')


@views_bp.route('/register.html')
def register_page():
    return render_template('register.html')

@views_bp.route('/login.html')
def login_page():
    return render_template('login.html')


@views_bp.route('/users.html')
def users_page():
    return render_template('users.html')


@views_bp.route('/profile.html')
def profile_page():
    return render_template('profile.html')

@views_bp.route('/booking.html')
def booking_page():
    return render_template('booking.html')

@views_bp.route('/admin.html')
def admin_page():
    return render_template('admin.html')