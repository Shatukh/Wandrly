import SwiftUI

// Наша простая модель аэропорта, теперь она здесь
struct AirportOption: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
}

struct AirportSelectionView: View {
    // Теперь мы работаем с массивом кодов
    @Binding var selectedAirportCodes: [String]
    @Environment(\.presentationMode) var presentationMode
    
    // Наша "база данных" для MVP
    let allAirports: [AirportOption] = [
        .init(code: "DUB", name: "Dublin, Ireland"),
        .init(code: "SNN", name: "Shannon, Ireland"),
        .init(code: "ORK", name: "Cork, Ireland"),
        .init(code: "NOC", name: "Knock, Ireland"),
        .init(code: "KIR", name: "Kerry, Ireland")
    ]
    
    var body: some View {
        // Оборачиваем в NavigationView, чтобы добавить кнопки в панель
        NavigationView {
            List {
                // Секция для кнопок "Выбрать все" / "Очистить"
                Section {
                    Button("Select All Irish Airports") {
                        // Выбираем коды всех аэропортов
                        selectedAirportCodes = allAirports.map { $0.code }
                    }
                    Button("Clear Selection", role: .destructive) {
                        selectedAirportCodes.removeAll()
                    }
                }
                
                // Секция со списком аэропортов
                Section(header: Text("Airports")) {
                    ForEach(allAirports) { airport in
                        Button(action: {
                            toggleSelection(for: airport.code)
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(airport.code).font(.headline)
                                    Text(airport.name).font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()
                                if selectedAirportCodes.contains(airport.code) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Select Departure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Кнопка "Done" для закрытия экрана
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // Функция для переключения выбора
    private func toggleSelection(for code: String) {
        if let index = selectedAirportCodes.firstIndex(of: code) {
            selectedAirportCodes.remove(at: index)
        } else {
            selectedAirportCodes.append(code)
        }
    }
}
