import json
import os
import requests
import uuid
from datetime import datetime, timedelta
from typing import List, Dict, Any, Tuple

# --- КОНСТАНТЫ ---
IRISH_AIRPORTS = ["DUB", "SNN", "ORK", "NOC", "KIR"]
UK_DEST_CODES = {"ABZ", "BFS", "BHD", "BHX", "BOH", "BRS", "CWL", "DSA", "DND", "EDI", "EMA", "EXT", "GLA", "HUY",
                 "INV", "LBA", "LDY", "LGW", "LPL", "LTN", "MAN", "NCL", "NQY", "PIK", "SEN", "SOU", "STN"}
PROJECT_DIR = "/Users/sergishatukh/Documents/Wandrly"  # Обновляем путь на новый
ROUTES_API_URL = "https://www.ryanair.com/api/views/locate/3/routes"
AIRPORTS_INFO_API_URL = "https://api.ryanair.com/aggregate/3/common?market=en-gb"
FARES_MONTHLY_API_URL = "https://www.ryanair.com/api/farfnd/v4/oneWayFares/{origin}/{destination}/cheapestPerDay"
ROUTES_FILE = os.path.join(PROJECT_DIR, "routes.json")
AIRPORTS_INFO_FILE = os.path.join(PROJECT_DIR, "airports_info.json")
REQUEST_TIMEOUT = 15


# --- ФУНКЦИИ-ПОМОЩНИКИ (ПОЛНЫЕ ВЕРСИИ) ---

def get_all_routes() -> List[Dict[str, Any]]:
    if os.path.exists(ROUTES_FILE):
        with open(ROUTES_FILE, "r") as f: return json.load(f)
    try:
        r = requests.get(ROUTES_API_URL, timeout=REQUEST_TIMEOUT)
        r.raise_for_status()
        routes = r.json()
        with open(ROUTES_FILE, "w") as f:
            json.dump(routes, f, indent=2)
        return routes
    except Exception as e:
        print(f"❌ Не удалось загрузить маршруты: {e}")
        return []


def get_airport_details() -> Tuple[Dict[str, str], Dict[str, str]]:
    airport_map, airport_to_country_map = {}, {}
    if os.path.exists(AIRPORTS_INFO_FILE):
        with open(AIRPORTS_INFO_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
    else:
        print("Не найден локальный файл airports_info.json.")
        return {}, {}
    country_map = {c['code']: c['name'] for c in data.get('countries', [])}
    for airport in data.get('airports', []):
        iata, city, country_code = airport.get("iataCode"), airport.get("name"), airport.get("countryCode")
        if iata and city and country_code:
            country_name = country_map.get(country_code, country_code)
            airport_map[iata] = f"{city}, {country_name}"
            airport_to_country_map[iata] = country_name
    return airport_map, airport_to_country_map


def get_destinations_from(origin: str, all_routes: List[Dict[str, Any]]) -> List[str]:
    destinations = set()
    for route in all_routes:
        if route.get("airportFrom") == origin:
            dest_code = route.get("airportTo")
            if dest_code and dest_code not in UK_DEST_CODES and dest_code not in IRISH_AIRPORTS:
                destinations.add(dest_code)
    return sorted(list(destinations))


def get_monthly_fares(session: requests.Session, origin: str, destination: str, month: str) -> Dict[str, float]:
    url = FARES_MONTHLY_API_URL.format(origin=origin, destination=destination)
    params = {"outboundMonthOfDate": f"{month}-01", "currency": "EUR"}
    fares_by_date = {}
    try:
        r = session.get(url, params=params, timeout=REQUEST_TIMEOUT)
        if r.status_code != 200: return {}
        data = r.json()
        for day_fare in data.get("outbound", {}).get("fares", []):
            if day_fare.get("unavailable") or not day_fare.get("price"): continue
            fares_by_date[day_fare["day"]] = day_fare["price"]["value"]
        return fares_by_date
    except Exception:
        return {}


# --- ГЛАВНАЯ ФУНКЦИЯ БИЗНЕС-ЛОГИКИ (ОБНОВЛЕННАЯ) ---
def find_deals(from_locations: List[str], durations: List[int], horizon_days: int, max_price: float) -> List[
    Dict[str, Any]]:
    print(
        f"🚀 Начинаю новый API поиск: Из {from_locations}, Длительность: {durations}, Горизонт: {horizon_days} дней, Макс. цена: {max_price} EUR")

    all_routes = get_all_routes()
    airport_map, _ = get_airport_details()

    if not all_routes or not airport_map:
        return []

    departure_airports = from_locations

    today = datetime.today().date()
    date_pairs = []
    for day_offset in range(1, horizon_days + 1):
        dep_date = today + timedelta(days=day_offset)
        for duration in durations:
            ret_date = dep_date + timedelta(days=duration)
            date_pairs.append((dep_date, ret_date))

    found_trips = []
    monthly_fares_cache = {}

    with requests.Session() as session:
        for origin in departure_airports:
            print(f"📍 Проверяю вылеты из: {airport_map.get(origin, origin)}")
            destinations = get_destinations_from(origin, all_routes)
            for dest in destinations:
                for dep_date, ret_date in date_pairs:
                    dep_month_str, ret_month_str = dep_date.strftime('%Y-%m'), ret_date.strftime('%Y-%m')
                    dep_day_str, ret_day_str = dep_date.strftime('%Y-%m-%d'), ret_date.strftime('%Y-%m-%d')

                    outbound_cache_key = (origin, dest, dep_month_str)
                    if outbound_cache_key not in monthly_fares_cache:
                        monthly_fares_cache[outbound_cache_key] = get_monthly_fares(session, origin, dest,
                                                                                    dep_month_str)

                    inbound_cache_key = (dest, origin, ret_month_str)
                    if inbound_cache_key not in monthly_fares_cache:
                        monthly_fares_cache[inbound_cache_key] = get_monthly_fares(session, dest, origin, ret_month_str)

                    out_price = monthly_fares_cache.get(outbound_cache_key, {}).get(dep_day_str)
                    back_price = monthly_fares_cache.get(inbound_cache_key, {}).get(ret_day_str)

                    if out_price is None or back_price is None: continue

                    total = out_price + back_price
                    if total <= max_price:
                        trip_info = {
                            "id": str(uuid.uuid4()),
                            "departureAirport": {"code": origin,
                                                 "city": airport_map.get(origin, origin).split(',')[0].strip()},
                            "arrivalAirport": {"code": dest, "city": airport_map.get(dest, dest).split(',')[0].strip()},
                            "departureDate": dep_date.isoformat(),
                            "returnDate": ret_date.isoformat(),
                            "durationDays": (ret_date - dep_date).days,
                            "price": {"value": round(total, 2), "currency": "EUR"}
                        }
                        found_trips.append(trip_info)

    print(f"🎉 Поиск завершен. Найдено совпадений: {len(found_trips)}")
    return sorted(found_trips, key=lambda x: x['price']['value'])