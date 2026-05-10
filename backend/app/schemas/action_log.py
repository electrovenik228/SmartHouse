from datetime import datetime
from pydantic import BaseModel


class ActionLogOut(BaseModel):
    id: int
    user_id: int | None
    device_id: int
    action: str
    created_at: datetime

    model_config = {"from_attributes": True}
