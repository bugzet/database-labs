// Простой менеджер сессий
const SessionManager = {
    setSession: function(sessionData) {
        localStorage.setItem('cyberclub_session', JSON.stringify(sessionData));
    },

    getSession: function() {
        const session = localStorage.getItem('cyberclub_session');
        return session ? JSON.parse(session) : null;
    },

    clearSession: function() {
        localStorage.removeItem('cyberclub_session');
        console.log('Сессия очищена');
    }
};

function updateSessionUser(user) {
    const session = SessionManager.getSession();
    if (session) {
        session.user = user;
        SessionManager.setSession(session);
        console.log('🔄 Данные сессии обновлены:', user.role);
    }
}

// Загрузка профиля
async function loadProfile() {
    const profileContent = document.getElementById('profile-content');
    const session = SessionManager.getSession();

    console.log('Загрузка профиля, сессия:', session);

    if (!session || !session.session_token) {
        profileContent.innerHTML = `
            <div class="form-message error-message">
                Вы не авторизованы<br>
                <a href="/login.html" style="color: #007bff;">Войдите в систему</a>
            </div>
        `;
        return;
    }

    try {
        const response = await fetch('/profile', {
            headers: {
                'Authorization': `Bearer ${session.session_token}`,
                'Content-Type': 'application/json'
            }
        });

        const result = await response.json();

        if (response.ok && result.success) {
            updateSessionUser(result.user);
            showProfile(result.user);
        } else {
            throw new Error(result.error || 'Ошибка загрузки профиля');
        }

    } catch (error) {
        console.error('Ошибка:', error);
        SessionManager.clearSession();
        profileContent.innerHTML = `
            <div class="form-message error-message">
                ❌ ${error.message}<br>
                <a href="/login.html" style="color: #007bff;">Войдите снова</a>
            </div>
        `;
    }
}

// Показать профиль
function showProfile(user) {
    const profileContent = document.getElementById('profile-content');

    profileContent.innerHTML = `
        <div style="text-align: center; margin-bottom: 20px;">
            <h2 style="color: #a0a0b0;">Добро пожаловать, ${user.name}!</h2>
        </div>

        <div class="user-table">
            <div class="table-header">
                <div class="table-name">${user.name}</div>
                <div class="table-id">ID: #${user.id}</div>
            </div>

            <div class="table-body">
                <div class="table-row">
                    <div class="table-label">Телефон:</div>
                    <div class="table-value">${user.phone}</div>
                </div>

                <div class="table-row">
                    <div class="table-label">Баланс:</div>
                    <div class="table-value">
                        <span class="badge badge-balance">${user.balance} руб.</span>
                    </div>
                </div>

                <div class="table-row">
                    <div class="table-label">Роль:</div>
                    <div class="table-value">
                        <span class="badge ${user.role === 'admin' ? 'badge-admin' : 'badge-client'}">
                            ${user.role === 'admin' ? 'Администратор' : 'Клиент'}
                        </span>
                    </div>
                </div>

                <div class="table-row">
                    <div class="table-label">Статус:</div>
                    <div class="table-value">
                        <span class="status status-active">✅ Активен</span>
                    </div>
                </div>
            </div>
        </div>

        <div style="display: flex; justify-content: center; gap: 15px; margin-top: 25px; flex-wrap: wrap;">
            <a href="/users.html" class="btn btn-primary">
                Все пользователи
            </a>
            <a href="/booking.html" class="btn btn-primary">
                🎮 Залы / Карта
            </a>
        </div>
    `;
}

// Инициализация
document.addEventListener('DOMContentLoaded', function() {
    loadProfile();

    // Кнопка выхода (находится в static HTML, не внутри profile-content)
    const logoutBtn = document.getElementById('logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', function() {
            SessionManager.clearSession();
            window.location.href = '/login.html';
        });
    }
    const cheatBtn = document.getElementById('admin-cheat-btn');
    if (cheatBtn) {
        cheatBtn.addEventListener('click', async function() {
            const session = SessionManager.getSession();
            if (!session) return;

            // Анимация загрузки на кнопке
            const originalText = cheatBtn.innerHTML;
            cheatBtn.innerHTML = '⏳ Магия...';
            cheatBtn.disabled = true;

            try {
                const response = await fetch('/users/become_admin', {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${session.session_token}`
                    }
                });

                const result = await response.json();

                if (result.success) {
                    alert(result.message);
                    loadProfile(); // Перезагружаем профиль, чтобы увидеть новую роль
                } else {
                    alert('Ошибка: ' + result.error);
                }
            } catch (e) {
                console.error(e);
                alert('Ошибка сети');
            } finally {
                cheatBtn.innerHTML = originalText;
                cheatBtn.disabled = false;
            }
        });
    }
});