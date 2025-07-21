import SwiftUI

struct HomeView: View {
    // --- Состояние Экрана ---
    @State private var selectedLocations: [String] = ["DUB"]
    @State private var selectedDurations: [Int] = [7]
    @State private var horizon: Int = 90
    @State private var maxPrice: Int = 150
    
    @State private var searchResults: [Deal] = []
    @State private var isShowingResults = false
    @State private var isLoading = false
    
    @State private var isShowingAirportSelector = false
    
    // --- Константы ---
    private let allDurations = [3, 5, 7, 10, 14, 21]
    private let networkingService = NetworkingService()
    
    private var locationsDisplayString: String {
        if selectedLocations.isEmpty {
            return "None selected"
        } else if selectedLocations.count > 2 {
            return "\(selectedLocations.count) airports selected"
        } else {
            return selectedLocations.joined(separator: ", ")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Search Parameters")) {
                    Button(action: {
                        isShowingAirportSelector = true
                    }) {
                        HStack {
                            Text("From")
                            Spacer()
                            Text(locationsDisplayString)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Duration (days)")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(allDurations, id: \.self) { duration in
                                    TagButton(
                                        title: "\(duration)",
                                        isSelected: selectedDurations.contains(duration),
                                        action: { toggleDurationSelection(duration) }
                                    )
                                }
                            }
                        }
                    }.padding(.vertical, 5)

                    TextField("Horizon (days)", value: $horizon, format: .number)
                        .keyboardType(.numberPad)

                    TextField("Max Price (€)", value: $maxPrice, format: .number)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    NavigationLink(destination: ResultsView(deals: searchResults), isActive: $isShowingResults) { EmptyView() }
                    
                    Button("Search Deals") {
                        Task { await searchDeals() }
                    }
                    .disabled(isLoading || selectedLocations.isEmpty)
                }
            }
            .navigationTitle("Wandrly")
            .sheet(isPresented: $isShowingAirportSelector) {
                AirportSelectionView(selectedAirportCodes: $selectedLocations)
            }
            .overlay {
                if isLoading {
                    ProgressView("Searching for flights...").padding().background(.thinMaterial).cornerRadius(10)
                }
            }
        }
    }
    
    // --- Логика ---
    private func searchDeals() async {
        isLoading = true
        do {
            // ИЗМЕНЕНИЕ ЗДЕСЬ: Мы убрали старую заглушку и теперь передаем
            // полный массив `selectedLocations` в наш обновленный сервис.
            let deals = try await networkingService.fetchDeals(
                from: selectedLocations,
                durations: selectedDurations,
                horizon: horizon,
                maxPrice: Float(maxPrice)
            )
            self.searchResults = deals
            self.isShowingResults = true
        } catch {
            print("Error fetching deals: \(error)")
            // TODO: Показать пользователю алерт об ошибке
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
