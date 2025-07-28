"""
Главный файл API-сервера Wandrly.
Определяет эндпоинты, обрабатывает входящие запросы и вызывает
модуль бизнес-логики для выполнения поиска.
"""
from fastapi import FastAPI, Query, HTTPException
from typing import List, Dict

# --- Импорты из нашего проекта ---
from . import logic
from .models import DealResponse, AirportListResponse # Сгруппировали импорты моделей

# --- Создание приложения FastAPI ---
app = FastAPI(
    title="Wandrly API",
    description="API для поиска спонтанных и дешевых авиаперелетов.",
    version="1.0.0"
)

# --- Эндпоинты ---

@app.get("/api/v1/deals", response_model=DealResponse)
def get_deals(
    from_locations: List[str] = Query(["DUB"], description="Список кодов аэропортов (IATA)."),
    durations: str = Query("5,7", description="Длительность поездки в днях, через запятую."),
    horizon_days: int = Query(60, description="Горизонт поиска в днях от сегодня."),
    max_price: float = Query(150.0, description="Максимальная цена за всю поездку.")
):
    """Ищет дешевые авиабилеты на основе заданных критериев."""
    try:
        duration_list = [int(d.strip()) for d in durations.split(',')]
    except ValueError:
        raise HTTPException(status_code=400, detail="Параметр 'durations' должен быть строкой чисел, разделенных запятой.")

    found_deals = logic.find_deals(
        from_locations=from_locations,
        durations=duration_list,
        horizon_days=horizon_days,
        max_price=max_price
    )
    return {"data": found_deals}


@app.get("/api/v1/airports", response_model=AirportListResponse)
def get_airports():
    """Возвращает отсортированный список всех доступных аэропортов."""
    airports = logic.get_all_airports()
    return {"data": airports}


@app.get("/api/v1/locations")
def get_locations() -> Dict[str, List[Dict[str, str]]]:
    """Возвращает все аэропорты, сгруппированные по странам."""
    return logic.get_locations_structured()


@app.get("/")
def read_root():
    """Корневой эндпоинт для проверки работы API."""
    return {"message": "Welcome to Wandrly API. Go to /docs for API documentation."}