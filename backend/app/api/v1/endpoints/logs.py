from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.db.session import get_db
from app.models.action_log import ActionLog
from app.schemas.action_log import ActionLogOut
from app.core.deps import get_current_user
from app.models.user import User

router = APIRouter(prefix="/logs", tags=["logs"])


@router.get("/", response_model=list[ActionLogOut])
async def get_logs(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
    _: User = Depends(get_current_user),
):
    result = await db.execute(
        select(ActionLog).order_by(desc(ActionLog.created_at)).limit(limit).offset(offset)
    )
    return result.scalars().all()
