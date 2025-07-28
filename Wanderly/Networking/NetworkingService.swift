import Foundation

class NetworkingService {
    private let baseURL = "http://127.0.0.1:8000/api/v1"

    func fetchDeals(from locations: [String], durations: [Int], horizon: Int, maxPrice: Float) async throws -> [Deal] {
        var components = URLComponents(string: "\(baseURL)/deals")!
        let durationString = durations.map { String($0) }.joined(separator: ",")
        components.queryItems = [
            URLQueryItem(name: "durations", value: durationString),
            URLQueryItem(name: "horizon_days", value: String(horizon)),
            URLQueryItem(name: "max_price", value: String(maxPrice))
        ]
        for location in locations {
            components.queryItems?.append(URLQueryItem(name: "from_locations", value: location))
        }
        guard let url = components.url else { throw URLError(.badURL) }
        
        print("➡️ Requesting URL: \(url.absoluteString)")
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(DealResponse.self, from: data)
        return decodedResponse.data
    }
    
    func fetchLocations() async throws -> [String: [AirportOption]] {
        let url = URL(string: "\(baseURL)/locations")!
        print("➡️ Requesting URL: \(url.absoluteString)")
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedLocations = try JSONDecoder().decode([String: [AirportOption]].self, from: data)
        return decodedLocations
    }
}
