let currentRoom = null;

// При загрузке страницы
document.addEventListener('DOMContentLoaded', () => {
    loadMap();
    // Обновляем карту каждые 30 секунд
    setInterval(loadMap, 30000);
});

// Загрузка карты
async function loadMap() {
    try {
        const [roomsRes, bookingsRes] = await Promise.all([
            fetch('/rooms'),
            fetch('/api/bookings/availability')
        ]);

        const rooms = await roomsRes.json();
        const bookings = await bookingsRes.json();
        const map = document.getElementById('clubMap');
        map.innerHTML = '';

        // Текущее время для проверки "Занят прямо сейчас"
        const now = new Date();

        rooms.forEach(room => {
            // Проверяем, занят ли ПК прямо сейчас
            const isBusyNow = bookings.some(b => {
                const start = new Date(b.start_time);
                const end = new Date(b.end_time);
                return b.room_id === room.id && now >= start && now < end;
            });

            const pc = document.createElement('div');
            pc.className = `pc-station`;
            // Стили теперь берутся из style.css, но динамические цвета оставляем в JS
            pc.style.cssText = `
                padding: 20px;
                border-radius: 12px;
                text-align: center;
                cursor: pointer;
                color: white;
                font-weight: bold;
                background-color: ${isBusyNow ? '#dc3545' : '#28a745'};
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            `;

            // HTML карточки
            pc.innerHTML = `
                <div style="font-size: 2.5rem; margin-bottom: 10px;">🖥️</div>
                <div style="font-size: 1.2rem;">${room.name}</div>
                <div style="font-size: 0.9rem; opacity: 0.9;">${room.price_per_hour} ₽/ч</div>
                ${room.name.toLowerCase().includes('vip') ? '<div style="position:absolute; top:8px; right:8px; background:gold; color:black; font-size:0.7rem; padding:2px 6px; border-radius:4px; box-shadow:0 2px 4px rgba(0,0,0,0.2);">VIP</div>' : ''}
            `;

            // При клике открываем модальное окно
            pc.onclick = () => openModal(room);

            map.appendChild(pc);
        });
    } catch (e) {
        console.error("Ошибка загрузки карты:", e);
    }
}

// Открыть окно
function openModal(room) {
    currentRoom = room;

    // Заполняем данные
    document.getElementById('modalTitle').innerText = `Бронирование ${room.name}`;
    document.getElementById('modalInfo').innerText = `Тариф: ${room.price_per_hour} ₽/час`;

    // Устанавливаем текущее время как дефолтное
    const now = new Date();
    now.setMinutes(now.getMinutes() - now.getTimezoneOffset()); // Коррекция часового пояса
    document.getElementById('bookingStart').value = now.toISOString().slice(0, 16);

    calculateTotal();
    document.getElementById('bookingModal').style.display = 'flex';
}

// Закрыть окно
function closeModal() {
    document.getElementById('bookingModal').style.display = 'none';
    currentRoom = null;
}

// Пересчет цены
function calculateTotal() {
    if (!currentRoom) return;
    const hours = document.getElementById('bookingDuration').value;
    const total = hours * currentRoom.price_per_hour;
    document.getElementById('totalPrice').innerText = total;
}

// Отправка бронирования
async function confirmBooking() {
    if (!currentRoom) return;

    const tokenSession = JSON.parse(localStorage.getItem('cyberclub_session'));
    const token = tokenSession ? tokenSession.session_token : null;

    if (!token) {
        alert("Пожалуйста, войдите в аккаунт!");
        window.location.href = '/login.html';
        return;
    }

    const startTime = document.getElementById('bookingStart').value;
    const hours = document.getElementById('bookingDuration').value;

    if (!startTime) {
        alert("Выберите время начала!");
        return;
    }

    try {
        const response = await fetch('/api/bookings/create', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                room_id: currentRoom.id,
                hours: parseInt(hours),
                start_time: startTime
            })
        });

        const result = await response.json();

        if (result.success) {
            alert(`✅ Успешно! Компьютер забронирован.\nТекущий баланс: ${result.new_balance} ₽`);
            closeModal();
            loadMap(); // Обновляем цвета на карте
        } else {
            alert(`❌ Ошибка: ${result.error}`);
        }
    } catch (error) {
        console.error(error);
        alert("Ошибка сети");
    }
}

// Закрытие по клику вне окна
window.onclick = function(event) {
    const modal = document.getElementById('bookingModal');
    if (event.target == modal) {
        closeModal();
    }
}