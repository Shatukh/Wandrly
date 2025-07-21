from . import logic
from .models import DealResponse

from fastapi import FastAPI, Query, HTTPException
from typing import List

app = FastAPI(
    title="Wandrly API",
    description="API для поиска спонтанных и дешевых авиаперелетов.",
    version="1.0.0"
)


@app.get("/api/v1/deals", response_model=DealResponse)
def get_deals(
        # Мы изменили имя параметра, чтобы было понятнее, что это список
        from_locations: List[str] = Query(["DUB"],
                                          description="Список кодов аэропортов (IATA). Пример: DUB или DUB,SNN"),
        durations: str = Query("5,7", description="Длительность поездки в днях, через запятую."),
        horizon_days: int = Query(60, description="Горизонт поиска в днях от сегодня."),
        max_price: float = Query(150.0, description="Максимальная цена за всю поездку.")
):
    try:
        duration_list = [int(d.strip()) for d in durations.split(',')]
    except ValueError:
        raise HTTPException(status_code=400,
                            detail="Параметр 'durations' должен быть строкой чисел, разделенных запятой.")

    # Вызываем нашу бизнес-логику, передавая весь список аэропортов
    found_deals = logic.find_deals(
        from_locations=from_locations,  # Передаем список аэропортов
        durations=duration_list,
        horizon_days=horizon_days,
        max_price=max_price
    )

    return {"data": found_deals}


@app.get("/")
def read_root():
    return {"message": "Welcome to Wandrly API. Go to /docs for API documentation."}