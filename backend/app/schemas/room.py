from pydantic import BaseModel


class RoomCreate(BaseModel):
    name: str
    icon: str = "home"


class RoomOut(BaseModel):
    id: int
    name: str
    icon: str

    model_config = {"from_attributes": True}
