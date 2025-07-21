import Foundation

struct DealResponse: Codable {
    let data: [Deal]
}

struct Deal: Codable, Identifiable {
    let id: UUID
    let departureAirport: Airport
    let arrivalAirport: Airport
    let departureDate: String
    let returnDate: String
    let durationDays: Int
    let price: Price
    
    // --- ЭТОТ КОД ОТВЕЧАЕТ ЗА ФОРМАТИРОВАНИЕ ---
    var formattedDepartureDate: String {
        return formatDateString(departureDate)
    }
    
    var formattedReturnDate: String {
        return formatDateString(returnDate)
    }
    
    private func formatDateString(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]
        
        if let date = isoFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd.MM.yyyy"
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct Airport: Codable {
    let code: String
    let city: String
}

struct Price: Codable {
    let value: Double
    let currency: String
}
