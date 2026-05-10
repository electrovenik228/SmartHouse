#!/bin/bash
set -e

echo "==> Собираем и запускаем контейнеры..."
docker compose up --build -d

echo "==> Ждём запуска базы данных..."
sleep 5

echo "==> Применяем миграции..."
docker compose exec backend alembic upgrade head

echo "==> Загружаем начальные данные..."
docker compose exec backend python -m app.db.seed

echo ""
echo "✅ Готово! Откройте http://77.95.206.95:5555"
echo "   admin / admin123  — администратор"
echo "   guest / guest123  — гость"
