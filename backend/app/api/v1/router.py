from fastapi import APIRouter
from app.api.v1.endpoints import auth, rooms, devices, logs, ws

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(auth.router)
api_router.include_router(rooms.router)
api_router.include_router(devices.router)
api_router.include_router(logs.router)
api_router.include_router(ws.router)
