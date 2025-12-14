(function checkAdminAccess() {
    const session = JSON.parse(localStorage.getItem('cyberclub_session'));
    const isAdmin = session && session.user && session.user.role === 'admin';

    if (!isAdmin) {
        document.body.innerHTML = `
            <div class="container" style="display: flex; height: 100vh; align-items: center; justify-content: center;">
                <div class="form-container" style="text-align: center; border-color: var(--accent-danger);">
                    <h1 style="color: var(--accent-danger); font-size: 3rem; margin-bottom: 10px;">⛔</h1>
                    <h2 style="margin-bottom: 15px;">Доступ запрещен</h2>
                    <p style="color: var(--text-secondary); margin-bottom: 25px;">
                        Эта страница доступна только администраторам.
                    </p>
                    <a href="/" class="btn btn-primary">Вернуться на главную</a>
                </div>
            </div>
        `;
        throw new Error("Access Denied: Admin role required");
    }
})();


let selectedUserId = null;
let allUsers = []; // Храним всех пользователей для поиска

async function loadAdminUsers() {
    try {
        const response = await fetch('/users'); // API теперь сортирует по ID
        allUsers = await response.json();
        renderUsers(allUsers);
    } catch (error) {
        console.error("Ошибка загрузки пользователей:", error);
    }
}

function renderUsers(users) {
    const container = document.getElementById('adminUsersList');
    container.innerHTML = '';

    if (users.length === 0) {
        container.innerHTML = '<p style="text-align:center; color: var(--text-secondary);">Пользователи не найдены</p>';
        return;
    }

    users.forEach(user => {
        const div = document.createElement('div');
        div.className = 'user-table'; // Используем стили карточек из style.css
        // Добавляем класс admin/manager для цветной рамки, если нужно
        if (user.role !== 'client') div.classList.add(user.role);

        div.innerHTML = `
            <div class="table-header">
                <div class="table-name">${user.name} <span style="font-size:0.8em; opacity:0.7">(${getRoleLabel(user.role)})</span></div>
                <div class="table-id">${user.phone}</div>
            </div>
            <div class="table-body" style="text-align:center; padding: 20px;">
                <div style="font-size: 1.2rem; margin-bottom: 15px; color: var(--text-primary);">
                    Баланс: <span class="badge badge-balance">${user.balance} ₽</span>
                </div>
                <button onclick="openTopUp(${user.id}, '${user.name}')" class="btn btn-success" style="width: 100%;">
                    ➕ Пополнить
                </button>
            </div>
        `;
        container.appendChild(div);
    });
}

function getRoleLabel(role) {
    if (role === 'admin') return 'Админ';
    if (role === 'manager') return 'Менеджер';
    return 'Клиент';
}

// Поиск по пользователям
const searchInput = document.getElementById('adminSearch');
if (searchInput) {
    searchInput.addEventListener('input', (e) => {
        const term = e.target.value.toLowerCase();
        const filtered = allUsers.filter(u =>
            u.name.toLowerCase().includes(term) ||
            u.phone.includes(term) ||
            u.id.toString().includes(term)
        );
        renderUsers(filtered);
    });
}

// УПРАВЛЕНИЕ МОДАЛЬНЫМ ОКНОМ
function openTopUp(id, name) {
    selectedUserId = id;
    document.getElementById('topupUserName').innerText = `Пользователь: ${name}`;
    document.getElementById('topupModal').style.display = 'flex'; // Flex для центровки
}

function closeModal() {
    document.getElementById('topupModal').style.display = 'none';
    document.getElementById('topupAmount').value = '';
    selectedUserId = null;
}

// Отправка пополнения
async function submitTopUp() {
    const amountInput = document.getElementById('topupAmount');
    const amount = amountInput.value;

    if (!amount || amount <= 0) {
        alert("Введите корректную сумму");
        return;
    }

    const token = JSON.parse(localStorage.getItem('cyberclub_session'))?.session_token;

    try {
        const response = await fetch('/api/admin/topup', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({ user_id: selectedUserId, amount: amount })
        });

        const result = await response.json();

        if (result.success) {
            alert(`✅ ${result.message}`);
            closeModal();
            loadAdminUsers(); // Обновляем список, чтобы увидеть новый баланс
        } else {
            alert(`❌ Ошибка: ${result.error}`);
        }
    } catch (e) {
        alert("Ошибка соединения с сервером");
    }
}

// Закрытие по клику вне окна
window.onclick = function(event) {
    const modal = document.getElementById('topupModal');
    if (event.target == modal) {
        closeModal();
    }
}

// Запуск при загрузке
document.addEventListener('DOMContentLoaded', loadAdminUsers);