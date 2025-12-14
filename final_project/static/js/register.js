// Валидация формы регистрации
class FormValidator {
    static validateName(name) {
        const trimmed = name.trim();
        if (trimmed.length < 2) {
            return { isValid: false, message: 'Имя должно содержать минимум 2 символа' };
        }
        if (trimmed.length > 100) {
            return { isValid: false, message: 'Имя слишком длинное' };
        }
        return { isValid: true };
    }

    static validatePhone(phone) {
        const trimmed = phone.trim();
        if (!trimmed.startsWith('+')) {
            return { isValid: false, message: 'Телефон должен начинаться с +' };
        }
        if (trimmed.length < 10) {
            return { isValid: false, message: 'Телефон слишком короткий' };
        }
        if (!/^\+[0-9]{10,15}$/.test(trimmed)) {
            return { isValid: false, message: 'Неверный формат телефона' };
        }
        return { isValid: true };
    }

    static validatePassword(password) {
        if (password.length < 4) {
            return { isValid: false, message: 'Пароль должен содержать минимум 4 символа' };
        }
        if (password.length > 50) {
            return { isValid: false, message: 'Пароль слишком длинный' };
        }
        return { isValid: true };
    }
}

// Проверка существования телефона
async function checkPhoneExists(phone) {
    try {
        const response = await fetch(`/check-phone/${encodeURIComponent(phone)}`);
        const result = await response.json();
        return result;
    } catch (error) {
        console.error('Ошибка проверки телефона:', error);
        return { exists: false };
    }
}

// Показать сообщение об ошибке
function showError(input, message) {
    // Удаляем старые сообщения об ошибках
    const existingError = input.parentNode.querySelector('.error-message');
    if (existingError) {
        existingError.remove();
    }

    // Добавляем красную рамку
    input.style.borderColor = '#dc3545';

    // Создаем сообщение об ошибке
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.style.color = '#dc3545';
    errorDiv.style.fontSize = '0.85rem';
    errorDiv.style.marginTop = '5px';
    errorDiv.innerHTML = `❌ ${message}`;

    input.parentNode.appendChild(errorDiv);
}

// Убрать сообщение об ошибке
function clearError(input) {
    input.style.borderColor = '#e9ecef';
    const existingError = input.parentNode.querySelector('.error-message');
    if (existingError) {
        existingError.remove();
    }
}

// Валидация в реальном времени
function setupRealTimeValidation() {
    const nameInput = document.getElementById('name');
    const phoneInput = document.getElementById('phone');
    const passwordInput = document.getElementById('password');

    // Валидация имени
    nameInput.addEventListener('blur', function() {
        const validation = FormValidator.validateName(this.value);
        if (!validation.isValid) {
            showError(this, validation.message);
        } else {
            clearError(this);
        }
    });

    // Валидация телефона
    phoneInput.addEventListener('blur', async function() {
        const validation = FormValidator.validatePhone(this.value);
        if (!validation.isValid) {
            showError(this, validation.message);
            return;
        }

        clearError(this);

        // Проверка существования телефона
        const result = await checkPhoneExists(this.value);
        if (result.exists) {
            showError(this, result.message);
        }
    });

    // Валидация пароля
    passwordInput.addEventListener('blur', function() {
        const validation = FormValidator.validatePassword(this.value);
        if (!validation.isValid) {
            showError(this, validation.message);
        } else {
            clearError(this);
        }
    });

    // Очистка ошибок при вводе
    [nameInput, phoneInput, passwordInput].forEach(input => {
        input.addEventListener('input', function() {
            clearError(this);
        });
    });
}

// Основная функция регистрации
async function handleRegistration(formData) {
    // Валидация на стороне клиента
    const nameValidation = FormValidator.validateName(formData.name);
    if (!nameValidation.isValid) {
        throw new Error(nameValidation.message);
    }

    const phoneValidation = FormValidator.validatePhone(formData.phone);
    if (!phoneValidation.isValid) {
        throw new Error(phoneValidation.message);
    }

    const passwordValidation = FormValidator.validatePassword(formData.password_hash);
    if (!passwordValidation.isValid) {
        throw new Error(passwordValidation.message);
    }

    // Проверка существования телефона
    const phoneCheck = await checkPhoneExists(formData.phone);
    if (phoneCheck.exists) {
        throw new Error(phoneCheck.message);
    }

    // Отправка данных
    const response = await fetch('/users', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData)
    });

    const result = await response.json();

    if (!response.ok) {
        throw new Error(result.error);
    }

    return result;
}

// Инициализация при загрузке страницы
document.addEventListener('DOMContentLoaded', function() {
    const registerForm = document.getElementById('registerForm');

    if (registerForm) {
        // Настройка валидации в реальном времени
        setupRealTimeValidation();

        // Обработчик отправки формы
        registerForm.addEventListener('submit', async function(e) {
            e.preventDefault();

            const formData = {
                name: document.getElementById('name').value.trim(),
                phone: document.getElementById('phone').value.trim(),
                password_hash: document.getElementById('password').value
            };

            const submitBtn = document.querySelector('.submit-btn');
            const originalText = submitBtn.innerHTML;
            const messageDiv = document.getElementById('message');

            try {
                // Очистка предыдущих сообщений
                messageDiv.innerHTML = '';
                submitBtn.innerHTML = '⏳ Регистрация...';
                submitBtn.disabled = true;

                // Выполнение регистрации
                const result = await handleRegistration(formData);

                // Успешная регистрация
                messageDiv.innerHTML = `
                    <div class="form-message success-message">
                        ✅ Регистрация успешна!<br>
                        <strong>ID пользователя: ${result.user_id}</strong><br>
                        <small>Теперь вы можете бронировать игровые места</small>
                    </div>
                `;

                // Очистка формы
                registerForm.reset();

                // Автоматическое обновление списка пользователей через 2 секунды
                setTimeout(() => {
                    window.location.href = '/users.html';
                }, 2000);

            } catch (error) {
                // Показ ошибки
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
    }
});