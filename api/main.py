"""
Главный файл API-сервера Wandrly.

Определяет эндпоинты, обрабатывает входящие запросы и вызывает
модуль бизнес-логики для выполнения поиска.
"""
from fastapi import FastAPI, Query, HTTPException
from typing import List, Optional

# Импортируем нашу бизнес-логику и модели данных
from . import logic
from .models import DealResponse

# Создаем экземпляр приложения FastAPI
app = FastAPI(
    title="Wandrly API",
    description="API для поиска спонтанных и дешевых авиаперелетов.",
    version="1.0.0"
)

# Определяем наш основной эндпоинт для поиска
@app.get("/api/v1/deals", response_model=DealResponse)
def get_deals(
    from_location: str = Query("DUB", description="Код аэропорта (IATA) или страны. Пример: DUB или DE"),
    durations: str = Query("5,7", description="Длительность поездки в днях, через запятую. Пример: 3,5,7"),
    horizon_days: int = Query(60, description="Горизонт поиска в днях от сегодня."),
    max_price: float = Query(150.0, description="Максимальная цена за всю поездку.")
):
    """
    Этот эндпоинт ищет дешевые авиабилеты на основе заданных критериев.
    """
    try:
        # Преобразуем строку длительностей в список чисел
        duration_list = [int(d.strip()) for d in durations.split(',')]
    except ValueError:
        raise HTTPException(status_code=400, detail="Параметр 'durations' должен быть строкой чисел, разделенных запятой.")

    # Вызываем нашу основную бизнес-логику из файла logic.py
    found_deals = logic.find_deals(
        from_location=from_location,
        durations=duration_list,
        horizon_days=horizon_days,
        max_price=max_price
    )

    # FastAPI автоматически преобразует этот словарь в JSON-ответ
    # благодаря `response_model=DealResponse`
    return {"data": found_deals}


@app.get("/")
def read_root():
    return {"message": "Welcome to Wandrly API. Go to /docs for API documentation."}
