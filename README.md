# 🏠 SmartHome — дипломный проект

Кроссплатформенное приложение для управления виртуальным умным домом в реальном времени.  
Включает веб-интерфейс, мобильное приложение (Flutter) и REST API с WebSocket.

---

## 📋 Содержание

- [Описание](#описание)
- [Архитектура](#архитектура)
- [Стек технологий](#стек-технологий)
- [Структура проекта](#структура-проекта)
- [Быстрый старт](#быстрый-старт)
- [Деплой на сервер](#деплой-на-сервер)
- [Учётные записи](#учётные-записи)
- [API документация](#api-документация)
- [WebSocket](#websocket)
- [Модели данных](#модели-данных)
- [Симулятор датчиков](#симулятор-датчиков)

---

## Описание

SmartHome позволяет управлять виртуальными устройствами умного дома:

- 💡 **Освещение** — включение/выключение
- ❄️ **Кондиционер** — управление состоянием
- 🔌 **Розетки** — включение/выключение
- 📷 **Камеры** — включение/выключение записи
- 🌡️ **Датчики температуры** — показания обновляются автоматически
- 👁️ **Датчики движения** — срабатывание моделируется системой

Все события фиксируются в журнале действий. Изменения мгновенно отображаются у всех подключённых клиентов через WebSocket.

---

## Архитектура

```
┌─────────────────────────────────────────────┐
│               Клиенты                        │
│                                             │
│  Браузер (Web UI)    Мобильное (Flutter)    │
│  http://host:5555    iOS / Android          │
└────────────┬────────────────┬───────────────┘
             │  HTTP + WS     │  HTTP + WS
             ▼                ▼
┌─────────────────────────────────────────────┐
│           FastAPI Backend                    │
│                                             │
│  REST API /api/v1/...                       │
│  WebSocket /api/v1/ws                       │
│  Web UI    / /login /dashboard /history     │
│                                             │
│  Симулятор датчиков (asyncio, каждые 10с)  │
└──────────────────┬──────────────────────────┘
                   │ SQLAlchemy async
                   ▼
┌─────────────────────────────────────────────┐
│           PostgreSQL 16                      │
│  users · rooms · devices · action_logs      │
└─────────────────────────────────────────────┘
```

---

## Стек технологий

### Backend
| Компонент | Технология |
|-----------|-----------|
| Фреймворк | FastAPI 0.111 |
| ASGI-сервер | Uvicorn |
| ORM | SQLAlchemy 2.0 (async) |
| База данных | PostgreSQL 16 |
| Миграции | Alembic |
| Аутентификация | JWT (python-jose) + bcrypt |
| Real-time | WebSocket |
| Валидация | Pydantic v2 |
| Шаблоны (Web UI) | Jinja2 |

### Web UI (встроен в backend)
| Компонент | Технология |
|-----------|-----------|
| CSS | Tailwind CSS (CDN) |
| Реактивность | Alpine.js 3 (CDN) |
| Транспорт | Fetch API + WebSocket |

### Mobile
| Компонент | Технология |
|-----------|-----------|
| Фреймворк | Flutter / Dart |
| HTTP | Dio |
| WebSocket | web_socket_channel |
| State | Riverpod |
| Навигация | go_router |
| Хранилище | flutter_secure_storage |

### Инфраструктура
| Компонент | Технология |
|-----------|-----------|
| Контейнеризация | Docker + Docker Compose |

---

## Структура проекта

```
SmartHome/
├── backend/                    # FastAPI приложение
│   ├── app/
│   │   ├── api/v1/
│   │   │   └── endpoints/      # auth, rooms, devices, logs, ws
│   │   ├── core/               # config, security, deps
│   │   ├── db/                 # session, seed
│   │   ├── frontend/           # Jinja2 router (Web UI)
│   │   ├── models/             # SQLAlchemy модели
│   │   ├── schemas/            # Pydantic схемы
│   │   ├── services/           # websocket_manager, simulator
│   │   ├── templates/          # HTML шаблоны (login, dashboard, history)
│   │   └── main.py
│   ├── alembic/                # Миграции БД
│   ├── Dockerfile
│   └── requirements.txt
├── mobile/                     # Flutter приложение
│   ├── lib/
│   │   ├── core/               # router, api_client, auth_storage
│   │   ├── models/             # user, room, device, action_log
│   │   ├── providers/          # Riverpod провайдеры
│   │   ├── screens/            # login, home, room, history
│   │   └── widgets/
│   └── pubspec.yaml
├── docker-compose.yml
├── deploy.sh                   # Скрипт быстрого деплоя
└── .gitignore
```

---

## Быстрый старт

### Требования
- Docker 24+
- Docker Compose v2

### Запуск

```bash
# 1. Клонировать репозиторий
git clone <repo-url> SmartHome
cd SmartHome

# 2. Запустить одной командой
chmod +x deploy.sh && ./deploy.sh
```

Или вручную:

```bash
# Собрать и запустить контейнеры
docker compose up --build -d

# Применить миграции
docker compose exec backend alembic upgrade head

# Загрузить начальные данные (комнаты, устройства, пользователи)
docker compose exec backend python -m app.db.seed
```

После запуска:

| Интерфейс | URL |
|-----------|-----|
| Веб-панель | http://localhost:5555 |
| API документация (Swagger) | http://localhost:5555/docs |
| ReDoc | http://localhost:5555/redoc |

---

## Деплой на сервер

```bash
# На сервере
git clone <repo-url> SmartHome
cd SmartHome
chmod +x deploy.sh && ./deploy.sh

# Сайт будет доступен на:
# http://77.95.206.95:5555
```

Для остановки:
```bash
docker compose down
```

Для просмотра логов:
```bash
docker compose logs -f backend
```

---

## Учётные записи

| Пользователь | Пароль | Роль | Возможности |
|---|---|---|---|
| `admin` | `admin123` | Администратор | Полный доступ: CRUD комнат и устройств |
| `guest` | `guest123` | Гость | Просмотр и управление устройствами |

---

## API документация

Все эндпоинты находятся под префиксом `/api/v1`. Авторизация — Bearer JWT токен.

### Аутентификация

| Метод | URL | Описание |
|-------|-----|----------|
| `POST` | `/auth/register` | Регистрация нового пользователя |
| `POST` | `/auth/login` | Вход, возвращает JWT токен |
| `GET` | `/auth/me` | Данные текущего пользователя |

### Комнаты

| Метод | URL | Доступ | Описание |
|-------|-----|--------|----------|
| `GET` | `/rooms/` | Все | Список всех комнат |
| `GET` | `/rooms/{id}` | Все | Комната по ID |
| `GET` | `/rooms/{id}/devices` | Все | Устройства в комнате |
| `POST` | `/rooms/` | Админ | Создать комнату |
| `DELETE` | `/rooms/{id}` | Админ | Удалить комнату |

### Устройства

| Метод | URL | Доступ | Описание |
|-------|-----|--------|----------|
| `GET` | `/devices/` | Все | Список всех устройств |
| `GET` | `/devices/{id}` | Все | Устройство по ID |
| `POST` | `/devices/` | Админ | Создать устройство |
| `POST` | `/devices/{id}/toggle` | Все | Включить / выключить |
| `PATCH` | `/devices/{id}` | Все | Обновить состояние или значение |
| `DELETE` | `/devices/{id}` | Админ | Удалить устройство |

### Логи

| Метод | URL | Описание |
|-------|-----|----------|
| `GET` | `/logs/?limit=50&offset=0` | История действий (макс. 200 записей) |

### Пример запроса

```bash
# Получить токен
TOKEN=$(curl -s -X POST http://localhost:5555/api/v1/auth/login \
  -d "username=admin&password=admin123" | jq -r .access_token)

# Получить список комнат
curl http://localhost:5555/api/v1/rooms/ \
  -H "Authorization: Bearer $TOKEN"

# Переключить устройство
curl -X POST http://localhost:5555/api/v1/devices/1/toggle \
  -H "Authorization: Bearer $TOKEN"
```

---

## WebSocket

Подключение к `/api/v1/ws` — авторизация не требуется.

```javascript
const ws = new WebSocket("ws://localhost:5555/api/v1/ws");

ws.onmessage = (event) => {
  const msg = JSON.parse(event.data);
  // msg.type === "device_update"
  // msg.device — обновлённый объект устройства
  console.log(msg.device);
};
```

Формат сообщения:

```json
{
  "type": "device_update",
  "device": {
    "id": 1,
    "name": "Люстра",
    "type": "LIGHT",
    "is_on": true,
    "value": null,
    "room_id": 1
  }
}
```

---

## Модели данных

### User
| Поле | Тип | Описание |
|------|-----|----------|
| `id` | int | Первичный ключ |
| `username` | str | Уникальное имя пользователя |
| `email` | str | Email |
| `is_admin` | bool | Признак администратора |

### Room
| Поле | Тип | Описание |
|------|-----|----------|
| `id` | int | Первичный ключ |
| `name` | str | Название комнаты |
| `icon` | str | Иконка (home, sofa, bed, kitchen…) |

### Device
| Поле | Тип | Описание |
|------|-----|----------|
| `id` | int | Первичный ключ |
| `name` | str | Название устройства |
| `type` | enum | `LIGHT` `AC` `OUTLET` `CAMERA` `TEMP_SENSOR` `MOTION_SENSOR` |
| `is_on` | bool | Состояние (вкл/выкл) |
| `value` | float? | Значение датчика (температура °C) |
| `room_id` | int | Ссылка на комнату |

### ActionLog
| Поле | Тип | Описание |
|------|-----|----------|
| `id` | int | Первичный ключ |
| `device_id` | int | Ссылка на устройство |
| `user_id` | int? | Ссылка на пользователя (null = система) |
| `action` | str | Описание действия |
| `created_at` | datetime | Время события |

---

## Симулятор датчиков

Фоновая задача запускается при старте приложения и обновляет датчики каждые **10 секунд**:

- **Температурные датчики** — случайное изменение от −0.5 до +0.5 °C, диапазон 15–35 °C
- **Датчики движения** — 10% вероятность срабатывания при каждом тике

Каждое изменение записывается в `ActionLog` и рассылается всем WebSocket-клиентам.
