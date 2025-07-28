import Foundation

enum SortOrder {
    case priceLowestFirst
    case priceHighestFirst
}

@MainActor
class ResultsViewModel: ObservableObject {
    
    // Входные данные
    private let allDeals: [Deal]
    
    // "Громкоговорители", которые заставят View обновиться
    @Published var sortOrder: SortOrder = .priceLowestFirst
    @Published var selectedCountries: Set<String> = [] // Память для выбранных стран
    
    // "Умная" переменная, которая теперь и фильтрует, и сортирует
    var filteredAndSortedDeals: [Deal] {
        // 1. Сначала фильтруем
        let filteredDeals: [Deal]
        if selectedCountries.isEmpty {
            // Если ни одна страна не выбрана, показываем все
            filteredDeals = allDeals
        } else {
            // Оставляем только те рейсы, где страна прибытия есть в нашем списке
            filteredDeals = allDeals.filter { deal in
                // Нам нужно получить страну из полного имени аэропорта
                let country = deal.arrivalAirport.city.split(separator: ",").last?.trimmingCharacters(in: .whitespaces) ?? ""
                return selectedCountries.contains(country)
            }
        }
        
        // 2. Затем сортируем
        switch sortOrder {
        case .priceLowestFirst:
            return filteredDeals.sorted { $0.price.value < $1.price.value }
        case .priceHighestFirst:
            return filteredDeals.sorted { $0.price.value > $1.price.value }
        }
    }
    
    // "Умная" переменная, которая отдает список уникальных стран из результатов
    var availableCountries: [String] {
        let allCountries = allDeals.compactMap {
            $0.arrivalAirport.city.split(separator: ",").last?.trimmingCharacters(in: .whitespaces)
        }
        return Array(Set(allCountries)).sorted()
    }
    
    init(deals: [Deal]) {
        self.allDeals = deals
    }
    
    // Функция для переключения выбора страны
    func toggleCountrySelection(_ country: String) {
        if selectedCountries.contains(country) {
            selectedCountries.remove(country)
        } else {
            selectedCountries.insert(country)
        }
    }
}
