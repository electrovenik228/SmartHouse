from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.models.device import Device
from app.models.action_log import ActionLog
from app.schemas.device import DeviceCreate, DeviceOut, DeviceUpdate
from app.core.deps import get_current_user, get_admin_user
from app.models.user import User
from app.services.websocket_manager import manager

router = APIRouter(prefix="/devices", tags=["devices"])


@router.get("/", response_model=list[DeviceOut])
async def list_devices(db: AsyncSession = Depends(get_db), _: User = Depends(get_current_user)):
    result = await db.execute(select(Device))
    return result.scalars().all()


@router.get("/{device_id}", response_model=DeviceOut)
async def get_device(device_id: int, db: AsyncSession = Depends(get_db), _: User = Depends(get_current_user)):
    device = await db.get(Device, device_id)
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    return device


@router.post("/", response_model=DeviceOut, status_code=201)
async def create_device(data: DeviceCreate, db: AsyncSession = Depends(get_db), _: User = Depends(get_admin_user)):
    device = Device(**data.model_dump())
    db.add(device)
    await db.commit()
    await db.refresh(device)
    return device


@router.post("/{device_id}/toggle", response_model=DeviceOut)
async def toggle_device(
    device_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    device = await db.get(Device, device_id)
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")

    device.is_on = not device.is_on
    action = f"turned {'on' if device.is_on else 'off'}"
    log = ActionLog(user_id=current_user.id, device_id=device.id, action=action)
    db.add(log)
    await db.commit()
    await db.refresh(device)

    await manager.broadcast({"type": "device_update", "device": DeviceOut.model_validate(device).model_dump()})
    return device


@router.patch("/{device_id}", response_model=DeviceOut)
async def update_device(
    device_id: int,
    data: DeviceUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    device = await db.get(Device, device_id)
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")

    changes = []
    if data.is_on is not None and data.is_on != device.is_on:
        device.is_on = data.is_on
        changes.append(f"turned {'on' if device.is_on else 'off'}")
    if data.value is not None:
        device.value = data.value
        changes.append(f"value set to {data.value}")

    if changes:
        log = ActionLog(user_id=current_user.id, device_id=device.id, action=", ".join(changes))
        db.add(log)

    await db.commit()
    await db.refresh(device)
    await manager.broadcast({"type": "device_update", "device": DeviceOut.model_validate(device).model_dump()})
    return device


@router.delete("/{device_id}", status_code=204)
async def delete_device(device_id: int, db: AsyncSession = Depends(get_db), _: User = Depends(get_admin_user)):
    device = await db.get(Device, device_id)
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    await db.delete(device)
    await db.commit()
