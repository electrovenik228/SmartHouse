import enum
from sqlalchemy import String, Boolean, Float, ForeignKey, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import Base


class DeviceType(str, enum.Enum):
    LIGHT = "light"
    AC = "ac"
    OUTLET = "outlet"
    CAMERA = "camera"
    TEMP_SENSOR = "temp_sensor"
    MOTION_SENSOR = "motion_sensor"


class Device(Base):
    __tablename__ = "devices"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    type: Mapped[DeviceType] = mapped_column(Enum(DeviceType), nullable=False)
    is_on: Mapped[bool] = mapped_column(Boolean, default=False)
    # numeric value for sensors (temperature, brightness, etc.)
    value: Mapped[float | None] = mapped_column(Float, nullable=True)
    room_id: Mapped[int] = mapped_column(ForeignKey("rooms.id"), nullable=False)

    room: Mapped["Room"] = relationship(back_populates="devices")
    action_logs: Mapped[list["ActionLog"]] = relationship(back_populates="device")
