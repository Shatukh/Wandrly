import SwiftUI

struct FilterView: View {
    
    // Теперь мы получаем доступ ко всему ViewModel, а не только к sortOrder
    @ObservedObject var viewModel: ResultsViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort by")) {
                    Picker("Sort Order", selection: $viewModel.sortOrder) {
                        Text("Price (Lowest First)").tag(SortOrder.priceLowestFirst)
                        Text("Price (Highest First)").tag(SortOrder.priceHighestFirst)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                // ИНТЕРАКТИВНЫЙ ФИЛЬТР ПО СТРАНАМ
                Section(header: Text("Filter by Destination Country")) {
                    // Строим список на основе доступных стран из ViewModel
                    ForEach(viewModel.availableCountries, id: \.self) { country in
                        Button(action: {
                            // При нажатии вызываем функцию в ViewModel
                            viewModel.toggleCountrySelection(country)
                        }) {
                            HStack {
                                Text(country)
                                Spacer()
                                // Показываем галочку, если страна выбрана
                                if viewModel.selectedCountries.contains(country) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }

            }
            .navigationTitle("Filters & Sorting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
