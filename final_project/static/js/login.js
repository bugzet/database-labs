// Простой менеджер сессий
const SessionManager = {
    setSession: function(sessionData) {
        localStorage.setItem('cyberclub_session', JSON.stringify(sessionData));
        console.log('💾 Сессия сохранена:', sessionData);
    },

    getSession: function() {
        const session = localStorage.getItem('cyberclub_session');
        return session ? JSON.parse(session) : null;
    },

    clearSession: function() {
        localStorage.removeItem('cyberclub_session');
        console.log('🧹 Сессия очищена');
    }
};

// Обработчик формы входа
document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('loginForm');
    const messageDiv = document.getElementById('login-message');

    // Очищаем сообщения
    messageDiv.innerHTML = '';

    // Проверяем, не авторизованы ли мы уже
    const existingSession = SessionManager.getSession();
    if (existingSession) {
        console.log('✅ Уже авторизован:', existingSession);
        window.location.href = '/profile.html';
        return;
    }

    loginForm.addEventListener('submit', async function(e) {
        e.preventDefault();

        const phone = document.getElementById('login-phone').value.trim();
        const password = document.getElementById('login-password').value;

        console.log('📤 Попытка входа:', { phone, password });

        const submitBtn = document.querySelector('.submit-btn');
        const originalText = submitBtn.innerHTML;

        try {
            // Показываем загрузку
            submitBtn.innerHTML = '⏳ Вход...';
            submitBtn.disabled = true;
            messageDiv.innerHTML = '<div class="loading">Проверка данных...</div>';

            // Отправляем запрос
            const response = await fetch('/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    phone: phone,
                    password_hash: password
                })
            });

            console.log('📥 Ответ сервера:', response.status);

            const result = await response.json();
            console.log('📊 Данные ответа:', result);

            if (response.ok && result.success) {
                // Сохраняем сессию
                SessionManager.setSession({
                    session_token: result.session_token,
                    user: result.user
                });

                messageDiv.innerHTML = `
                    <div class="form-message success-message">
                        ✅ Вход выполнен!<br>
                        <small>Перенаправление...</small>
                    </div>
                `;

                // Переходим в профиль через 1 секунду
                setTimeout(() => {
                    window.location.href = '/profile.html';
                }, 1000);

            } else {
                throw new Error(result.error || 'Неизвестная ошибка');
            }

        } catch (error) {
            console.error('❌ Ошибка входа:', error);
            messageDiv.innerHTML = `
                <div class="form-message error-message">
                    ❌ ${error.message}
                </div>
            `;
        } finally {
            submitBtn.innerHTML = originalText;
            submitBtn.disabled = false;
        }
    });

    // Очистка сообщений при изменении полей
    document.getElementById('login-phone').addEventListener('input', () => {
        messageDiv.innerHTML = '';
    });
    document.getElementById('login-password').addEventListener('input', () => {
        messageDiv.innerHTML = '';
    });
});