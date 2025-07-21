import Foundation

class NetworkingService {
    
    // ИЗМЕНЕНИЕ ЗДЕСЬ: теперь принимаем [String]
    func fetchDeals(from locations: [String], durations: [Int], horizon: Int, maxPrice: Float) async throws -> [Deal] {
        
        // 1. Строим URL с параметрами
        var components = URLComponents(string: "http://127.0.0.1:8000/api/v1/deals")!
        
        let durationString = durations.map { String($0) }.joined(separator: ",")
        
        // Собираем базовые query items
        components.queryItems = [
            URLQueryItem(name: "durations", value: durationString),
            URLQueryItem(name: "horizon_days", value: String(horizon)),
            URLQueryItem(name: "max_price", value: String(maxPrice))
        ]
        
        // ИЗМЕНЕНИЕ ЗДЕСЬ: вручную добавляем параметры для массива
        // Чтобы URL был ...&from_locations=DUB&from_locations=ORK
        for location in locations {
            components.queryItems?.append(URLQueryItem(name: "from_locations", value: location))
        }
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        print("Requesting URL: \(url.absoluteString)")
        
        // 2. Делаем сетевой запрос (без изменений)
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // 3. Декодируем JSON (без изменений)
        let decodedResponse = try JSONDecoder().decode(DealResponse.self, from: data)
        
        // 4. Возвращаем результат (без изменений)
        return decodedResponse.data
    }
}
