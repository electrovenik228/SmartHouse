"""Create all tables directly from SQLAlchemy models (no migrations needed)."""
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from app.models.base import Base
from app.models import User, Room, Device, ActionLog  # noqa: F401
from app.core.config import settings


async def create_tables():
    engine = create_async_engine(settings.DATABASE_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    await engine.dispose()
    print("Tables created successfully.")


if __name__ == "__main__":
    asyncio.run(create_tables())
