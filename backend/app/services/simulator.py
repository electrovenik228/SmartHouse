import asyncio
import random
from sqlalchemy import select
from app.db.session import AsyncSessionLocal
from app.models.device import Device, DeviceType
from app.models.action_log import ActionLog
from app.schemas.device import DeviceOut
from app.services.websocket_manager import manager


async def _simulate_tick():
    async with AsyncSessionLocal() as db:
        result = await db.execute(
            select(Device).where(Device.type.in_([DeviceType.TEMP_SENSOR, DeviceType.MOTION_SENSOR]))
        )
        sensors = result.scalars().all()

        for sensor in sensors:
            if sensor.type == DeviceType.TEMP_SENSOR:
                delta = random.uniform(-0.5, 0.5)
                current = sensor.value if sensor.value is not None else 22.0
                sensor.value = round(max(15.0, min(35.0, current + delta)), 1)
                log = ActionLog(device_id=sensor.id, action=f"temperature updated to {sensor.value}°C")
                db.add(log)

            elif sensor.type == DeviceType.MOTION_SENSOR:
                # 10% chance of motion detected each tick
                detected = random.random() < 0.1
                if detected and not sensor.is_on:
                    sensor.is_on = True
                    log = ActionLog(device_id=sensor.id, action="motion detected")
                    db.add(log)
                elif not detected and sensor.is_on:
                    sensor.is_on = False

        await db.commit()

        for sensor in sensors:
            await db.refresh(sensor)
            await manager.broadcast({
                "type": "device_update",
                "device": DeviceOut.model_validate(sensor).model_dump(),
            })


async def start_simulator():
    while True:
        await asyncio.sleep(10)
        try:
            await _simulate_tick()
        except Exception:
            pass
