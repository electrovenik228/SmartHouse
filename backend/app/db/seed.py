"""Populate the database with initial data. Safe to run multiple times."""
import asyncio
from sqlalchemy import select
from app.db.session import AsyncSessionLocal
from app.models.user import User
from app.models.room import Room
from app.models.device import Device, DeviceType
from app.core.security import hash_password


USERS = [
    {"username": "admin", "email": "admin@smarthome.local", "password": "admin123", "is_admin": True},
    {"username": "guest", "email": "guest@smarthome.local", "password": "guest123", "is_admin": False},
]

ROOMS = [
    {"name": "Гостиная", "icon": "sofa"},
    {"name": "Спальня",  "icon": "bed"},
    {"name": "Кухня",    "icon": "kitchen"},
]

DEVICES = [
    {"name": "Люстра",            "type": DeviceType.LIGHT,         "room_idx": 0},
    {"name": "Кондиционер",       "type": DeviceType.AC,            "room_idx": 0},
    {"name": "Камера",            "type": DeviceType.CAMERA,        "room_idx": 0},
    {"name": "Датчик движения",   "type": DeviceType.MOTION_SENSOR, "room_idx": 0},
    {"name": "Лампа",             "type": DeviceType.LIGHT,         "room_idx": 1},
    {"name": "Датчик температуры","type": DeviceType.TEMP_SENSOR,   "room_idx": 1, "value": 22.0},
    {"name": "Подсветка",         "type": DeviceType.LIGHT,         "room_idx": 2},
    {"name": "Розетка",           "type": DeviceType.OUTLET,        "room_idx": 2},
    {"name": "Датчик температуры","type": DeviceType.TEMP_SENSOR,   "room_idx": 2, "value": 24.0},
]


async def seed():
    async with AsyncSessionLocal() as db:

        # ── Users ──────────────────────────────────────────────────────────
        for u in USERS:
            existing = await db.scalar(select(User).where(User.username == u["username"]))
            if existing:
                existing.hashed_password = hash_password(u["password"])
                print(f"  [updated] user '{u['username']}'")
            else:
                db.add(User(
                    username=u["username"],
                    email=u["email"],
                    hashed_password=hash_password(u["password"]),
                    is_admin=u["is_admin"],
                ))
                print(f"  [created] user '{u['username']}'")

        await db.flush()

        # ── Rooms ──────────────────────────────────────────────────────────
        rooms = []
        for r in ROOMS:
            existing = await db.scalar(select(Room).where(Room.name == r["name"]))
            if existing:
                rooms.append(existing)
                print(f"  [exists]  room '{r['name']}'")
            else:
                room = Room(**r)
                db.add(room)
                await db.flush()
                rooms.append(room)
                print(f"  [created] room '{r['name']}'")

        # ── Devices ────────────────────────────────────────────────────────
        for d in DEVICES:
            room = rooms[d["room_idx"]]
            existing = await db.scalar(
                select(Device).where(Device.name == d["name"], Device.room_id == room.id)
            )
            if existing:
                print(f"  [exists]  device '{d['name']}' in '{room.name}'")
            else:
                db.add(Device(
                    name=d["name"],
                    type=d["type"],
                    room_id=room.id,
                    value=d.get("value"),
                ))
                print(f"  [created] device '{d['name']}' in '{room.name}'")

        await db.commit()

    print("\nSeed completed.")
    print("  admin / admin123  (администратор)")
    print("  guest / guest123  (гость)")


if __name__ == "__main__":
    asyncio.run(seed())
