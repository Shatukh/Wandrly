import SwiftUI

struct AirportSelectionView: View {
    let country: String
    let airports: [AirportOption]
    @Binding var selectedAirportCodes: [String]
    
    @Environment(\.dismiss) private var dismiss
    
    private var areAllSelected: Bool {
        Set(airports.map { $0.code }).isSubset(of: Set(selectedAirportCodes))
    }
    
    var body: some View {
        List {
            Button(areAllSelected ? "Deselect All in \(country)" : "Select All in \(country)") {
                toggleSelectAll()
            }
            .foregroundColor(areAllSelected ? .red : .blue)
            
            ForEach(airports) { airport in
                Button(action: { toggleSelection(for: airport.code) }) {
                    HStack {
                        Text("\(airport.name) (\(airport.code))")
                        Spacer()
                        if selectedAirportCodes.contains(airport.code) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle").foregroundColor(.secondary)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle(country)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss() // просто закрывает текущий экран
                }
            }
        }
    }
    
    private func toggleSelection(for code: String) {
        if let index = selectedAirportCodes.firstIndex(of: code) {
            selectedAirportCodes.remove(at: index)
        } else {
            selectedAirportCodes.append(code)
        }
    }
    
    private func toggleSelectAll() {
        if areAllSelected {
            let countryCodes = Set(airports.map { $0.code })
            selectedAirportCodes.removeAll { countryCodes.contains($0) }
        } else {
            let countryCodes = airports.map { $0.code }
            let combined = Set(selectedAirportCodes).union(Set(countryCodes))
            selectedAirportCodes = Array(combined)
        }
    }
}
