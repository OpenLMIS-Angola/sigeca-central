from typing import Optional, Literal
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel


class MSService(BaseModel):
    code: str
    name: str


class MSFacility(BaseModel):
    id: UUID
    reference_id: Optional[UUID]
    is_deleted: bool
    last_updated: datetime
    name: str
    code: str
    acronym: str
    category: str
    ownership: Optional[str]
    management: Optional[str]
    municipality: str
    province: str
    is_operational: bool
    latitude: Optional[str]
    longitude: Optional[str]
    services: list[MSService]


class User(BaseModel):
    id: UUID
    is_deleted: bool
    last_updated: datetime
    username: str
    password_hash: str


class TokenPayload(BaseModel):
    sub: str
    exp: datetime


class TokenResponse(BaseModel):
    access_token: str
    token_type: str


class SyncInput(BaseModel):
    id: UUID
    schema_name: Optional[str]
    table_name: str
    operation: Literal["I", "U", "D"]
    change_time: datetime
    row_data: dict
