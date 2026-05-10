from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.db.session import get_db
from app.models.room import Room
from app.schemas.room import RoomCreate, RoomOut
from app.schemas.device import DeviceOut
from app.core.deps import get_current_user, get_admin_user
from app.models.user import User

router = APIRouter(prefix="/rooms", tags=["rooms"])


@router.get("/", response_model=list[RoomOut])
async def list_rooms(db: AsyncSession = Depends(get_db), _: User = Depends(get_current_user)):
    result = await db.execute(select(Room))
    return result.scalars().all()


@router.get("/{room_id}", response_model=RoomOut)
async def get_room(room_id: int, db: AsyncSession = Depends(get_db), _: User = Depends(get_current_user)):
    room = await db.get(Room, room_id)
    if not room:
        raise HTTPException(status_code=404, detail="Room not found")
    return room


@router.get("/{room_id}/devices", response_model=list[DeviceOut])
async def room_devices(room_id: int, db: AsyncSession = Depends(get_db), _: User = Depends(get_current_user)):
    result = await db.execute(
        select(Room).options(selectinload(Room.devices)).where(Room.id == room_id)
    )
    room = result.scalar_one_or_none()
    if not room:
        raise HTTPException(status_code=404, detail="Room not found")
    return room.devices


@router.post("/", response_model=RoomOut, status_code=201)
async def create_room(data: RoomCreate, db: AsyncSession = Depends(get_db), _: User = Depends(get_admin_user)):
    room = Room(**data.model_dump())
    db.add(room)
    await db.commit()
    await db.refresh(room)
    return room


@router.delete("/{room_id}", status_code=204)
async def delete_room(room_id: int, db: AsyncSession = Depends(get_db), _: User = Depends(get_admin_user)):
    room = await db.get(Room, room_id)
    if not room:
        raise HTTPException(status_code=404, detail="Room not found")
    await db.delete(room)
    await db.commit()
