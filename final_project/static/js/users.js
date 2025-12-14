// Функции для работы с пользователями
function getRoleBadge(role) {
    const badges = {
        'client': 'badge-client',
        'admin': 'badge-admin',
        'manager': 'badge-manager'
    };
    return badges[role] || 'badge-client';
}

function getRoleLabel(role) {
    const labels = {
        'client': 'Клиент',
        'admin': 'Администратор',
        'manager': 'Менеджер'
    };
    return labels[role] || role;
}

// Загрузка пользователей
async function loadUsers() {
    try {
        const response = await fetch('/users');
        const users = await response.json();

        const usersList = document.getElementById('usersList');
        const loading = document.getElementById('loading');

        usersList.innerHTML = '';

        if (users.length === 0) {
            usersList.innerHTML = '<div class="user-table">Пользователей нет</div>';
        } else {
            users.forEach(user => {
                const userTable = document.createElement('div');
                userTable.className = `user-table ${user.role}`;

                const regDate = user.created_at ?
                    new Date(user.created_at).toLocaleDateString('ru-RU') :
                    'Не указана';

                userTable.innerHTML = `
                    <div class="table-header">
                        <div class="table-id">ID: #${user.id}</div>
                        <div class="table-name">${user.name}</div>
                    </div>

                    <div class="table-body">
                        <div class="table-row">
                            <div class="table-label">Телефон:</div>
                            <div class="table-value">${user.phone}</div>
                        </div>

                        <div class="table-row">
                            <div class="table-label">Роль:</div>
                            <div class="table-value">
                                <span class="badge ${getRoleBadge(user.role)}">
                                    ${getRoleLabel(user.role)}
                                </span>
                            </div>
                        </div>

                        <div class="table-row">
                            <div class="table-label">Баланс:</div>
                            <div class="table-value">
                                <span class="badge badge-balance">
                                    ${user.balance} руб.
                                </span>
                            </div>
                        </div>

                        <div class="table-row">
                            <div class="table-label">Статус:</div>
                            <div class="table-value">
                                <span class="status ${user.is_active ? 'status-active' : 'status-inactive'}">
                                    ${user.is_active ? '✅ Активен' : '❌ Неактивен'}
                                </span>
                            </div>
                        </div>

                        <div class="table-row">
                            <div class="table-label">Регистрация:</div>
                            <div class="table-value">${regDate}</div>
                        </div>
                    </div>
                `;
                usersList.appendChild(userTable);
            });
        }

        loading.style.display = 'none';

    } catch (error) {
        console.error('Ошибка загрузки:', error);
        const usersList = document.getElementById('usersList');
        usersList.innerHTML = '<div class="message error">❌ Ошибка загрузки пользователей</div>';
    }
}

// Загрузка при готовности DOM
document.addEventListener('DOMContentLoaded', loadUsers);