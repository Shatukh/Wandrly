import Foundation

// MARK: - Модели для ответа API (Рейсы)

struct DealResponse: Codable {
    let data: [Deal]
}

struct Deal: Codable, Identifiable, Hashable {
    let id: UUID
    let departureAirport: Airport
    let arrivalAirport: Airport
    let departureDate: String
    let returnDate: String
    let durationDays: Int
    let price: Price
    
    // Вычисляемые свойства для красивого отображения дат
    var formattedDepartureDate: String {
        return formatDateString(departureDate)
    }
    
    var formattedReturnDate: String {
        return formatDateString(returnDate)
    }
    
    // Приватная функция-помощник для конвертации
    private func formatDateString(_ dateString: String) -> String {
        // ИСПРАВЛЕНИЕ ЗДЕСЬ: Правильное имя класса
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]
        
        if let date = isoFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd.MM.yyyy"
            return displayFormatter.string(from: date)
        }
        
        // Если что-то пошло не так, возвращаем исходную строку
        return dateString
    }
}

struct Airport: Codable, Hashable {
    let code: String
    let city: String
}

struct Price: Codable, Hashable {
    let value: Double
    let currency: String
}


// MARK: - Модель для списка аэропортов

struct AirportOption: Identifiable, Codable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case code, name
    }
}
