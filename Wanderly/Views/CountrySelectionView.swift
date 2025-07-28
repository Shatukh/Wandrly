import SwiftUI

struct CountrySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AirportSelectionViewModel
    @Binding var selectedAirportCodes: [String]
    
    @State private var searchText = ""

    private var filteredCountries: [String] {
        if searchText.isEmpty {
            return viewModel.locations.keys.sorted()
        } else {
            return viewModel.locations.keys.sorted().filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading locations...")
            } else {
                List(filteredCountries, id: \.self) { country in
                    NavigationLink(destination: AirportSelectionView(
                        country: country,
                        airports: viewModel.locations[country] ?? [],
                        selectedAirportCodes: $selectedAirportCodes
                    )) {
                        HStack {
                            Text(country)
                            Spacer()
                            if hasSelection(in: country) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Country")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search for a country")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func hasSelection(in country: String) -> Bool {
        let countryAirports = viewModel.locations[country]?.map { $0.code } ?? []
        return !Set(countryAirports).isDisjoint(with: Set(selectedAirportCodes))
    }
}
