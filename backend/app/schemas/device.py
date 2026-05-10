from pydantic import BaseModel
from app.models.device import DeviceType


class DeviceCreate(BaseModel):
    name: str
    type: DeviceType
    room_id: int


class DeviceOut(BaseModel):
    id: int
    name: str
    type: DeviceType
    is_on: bool
    value: float | None
    room_id: int

    model_config = {"from_attributes": True}


class DeviceUpdate(BaseModel):
    is_on: bool | None = None
    value: float | None = None
