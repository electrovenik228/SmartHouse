"""Run once to populate the database with initial data."""
import asyncio
from app.db.session import AsyncSessionLocal
from app.models.user import User
from app.models.room import Room
from app.models.device import Device, DeviceType
from app.core.security import hash_password


ROOMS = [
    {"name": "Гостиная", "icon": "sofa"},
    {"name": "Спальня", "icon": "bed"},
    {"name": "Кухня", "icon": "kitchen"},
]

DEVICES = [
    # Гостиная (room index 0)
    {"name": "Люстра", "type": DeviceType.LIGHT, "room_idx": 0},
    {"name": "Кондиционер", "type": DeviceType.AC, "room_idx": 0},
    {"name": "Камера", "type": DeviceType.CAMERA, "room_idx": 0},
    {"name": "Датчик движения", "type": DeviceType.MOTION_SENSOR, "room_idx": 0},
    # Спальня (room index 1)
    {"name": "Лампа", "type": DeviceType.LIGHT, "room_idx": 1},
    {"name": "Датчик температуры", "type": DeviceType.TEMP_SENSOR, "room_idx": 1, "value": 22.0},
    # Кухня (room index 2)
    {"name": "Подсветка", "type": DeviceType.LIGHT, "room_idx": 2},
    {"name": "Розетка", "type": DeviceType.OUTLET, "room_idx": 2},
    {"name": "Датчик температуры", "type": DeviceType.TEMP_SENSOR, "room_idx": 2, "value": 24.0},
]


async def seed():
    async with AsyncSessionLocal() as db:
        admin = User(
            username="admin",
            email="admin@smarthome.local",
            hashed_password=hash_password("admin123"),
            is_admin=True,
        )
        guest = User(
            username="guest",
            email="guest@smarthome.local",
            hashed_password=hash_password("guest123"),
            is_admin=False,
        )
        db.add_all([admin, guest])
        await db.flush()

        rooms = [Room(**r) for r in ROOMS]
        db.add_all(rooms)
        await db.flush()

        for d in DEVICES:
            device = Device(
                name=d["name"],
                type=d["type"],
                room_id=rooms[d["room_idx"]].id,
                value=d.get("value"),
            )
            db.add(device)

        await db.commit()
        print("Seed completed.")
        print("  admin / admin123  (is_admin=True)")
        print("  guest / guest123  (is_admin=False)")


if __name__ == "__main__":
    asyncio.run(seed())
