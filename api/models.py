"""
Pydantic-модели для валидации данных и определения схемы API.
"""
from pydantic import BaseModel
from typing import List
import uuid

# Эти модели гарантируют, что ответ API всегда будет иметь правильную структуру.

class Airport(BaseModel):
    code: str
    city: str

class Price(BaseModel):
    value: float
    currency: str

class Deal(BaseModel):
    id: uuid.UUID
    departureAirport: Airport
    arrivalAirport: Airport
    departureDate: str
    returnDate: str
    durationDays: int
    price: Price

class DealResponse(BaseModel):
    data: List[Deal]
