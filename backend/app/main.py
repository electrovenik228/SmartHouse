import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.frontend.router import router as frontend_router
from app.services.simulator import start_simulator


@asynccontextmanager
async def lifespan(app: FastAPI):
    task = asyncio.create_task(start_simulator())
    yield
    task.cancel()


app = FastAPI(
    title="SmartHome API",
    description="REST API + WebSocket для управления умным домом",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)
app.include_router(frontend_router)
