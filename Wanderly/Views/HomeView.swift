import SwiftUI

struct HomeView: View {
    // ViewModel для загрузки списка аэропортов
    @StateObject private var airportViewModel = AirportSelectionViewModel()
    
    // --- Состояние для параметров поиска ---
    @State private var selectedLocations: [String] = ["DUB"]
    @State private var selectedDurations: [Int] = [7]
    @State private var horizon: Int = 90
    @State private var maxPrice: Int = 150
    
    // --- Состояние для UI и навигации ---
    @State private var searchResults: [Deal] = []
    @State private var isLoading = false
    @State private var appError: AppError?
    
    @State private var isShowingAirportSelector = false
    @State private var navigateToResults = false
    
    // --- Константы ---
    private let allDurations = [3, 5, 7, 10, 14, 21]
    private let networkingService = NetworkingService()
    
    // Вычисляемое свойство для красивого отображения выбранных аэропортов
    private var locationsDisplayString: String {
        // ИСПРАВЛЕНИЕ ЗДЕСЬ
        if selectedLocations.isEmpty {
            return "Select departure"
        } else if selectedLocations.count > 10 {
            return "\(selectedLocations.count) airports"
        } else {
            return selectedLocations.joined(separator: ", ")
        }
    }
    
    var body: some View {
        ZStack {
            // 1. Светло-серый фон для всего экрана
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // 2. Заголовок
                Text("Wandrly")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.accentColor)
                
                // 3. Кастомные поля ввода
                
                // Кнопка "From"
                Button(action: { isShowingAirportSelector = true }) {
                    HStack {
                        Text("From")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(locationsDisplayString)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                }

                // Поле "Duration" с тегами
                VStack(alignment: .leading, spacing: 10) {
                    Text("Duration")
                        .foregroundColor(.secondary)
                        .padding([.leading, .top])
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(allDurations, id: \.self) { duration in
                                TagButton(title: "\(duration)", isSelected: selectedDurations.contains(duration), action: { toggleDurationSelection(duration) })
                            }
                        }
                    }
                    .padding(.leading)
                }
                
                // Поля "Horizon" и "Max Price"
                HStack {
                    Text("Horizon (days)")
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("", value: $horizon, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                
                HStack {
                    Text("Max Price")
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("", value: $maxPrice, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    Text("€").foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                
                Spacer() // Толкает кнопку "Search" вниз
                
                // 4. Кнопка "Search"
                
                // Невидимая ссылка для перехода
                NavigationLink(destination: SearchResultsContainerView(deals: searchResults), isActive: $navigateToResults) { EmptyView() }
                
                Button("Search") {
                    Task { await searchDeals() }
                }
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(25)
                .disabled(isLoading || selectedLocations.isEmpty)

            }
            .padding()
        }
        .navigationBarHidden(true) // Прячем стандартный заголовок, так как у нас есть свой
        .onAppear { Task { await airportViewModel.fetchLocations() } }
        .sheet(isPresented: $isShowingAirportSelector) {
            CountrySelectionContainerView(viewModel: airportViewModel, selectedAirportCodes: $selectedLocations)
        }
        .overlay {
            if isLoading {
                ProgressView("Searching...").padding().background(.thinMaterial).cornerRadius(10)
            }
        }
        .alert(item: $appError) { error in
            Alert(title: Text(error.title), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private func searchDeals() async {
        isLoading = true
        do {
            let deals = try await networkingService.fetchDeals(from: selectedLocations, durations: selectedDurations, horizon: horizon, maxPrice: Float(maxPrice))
            self.searchResults = deals
            self.navigateToResults = true
        } catch {
            appError = AppError(title: "Network Error", message: "Failed to fetch flight deals.")
        }
        isLoading = false
    }
    
    private func toggleDurationSelection(_ duration: Int) {
        if let index = selectedDurations.firstIndex(of: duration) {
            selectedDurations.remove(at: index)
        } else {
            selectedDurations.append(duration)
        }
    }
}
