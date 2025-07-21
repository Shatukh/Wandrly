import SwiftUI

struct ResultsView: View {
    // Данные, которые экран получает от HomeView
    let deals: [Deal]
    
    var body: some View {
        List(deals) { deal in
            // Каждая ячейка в списке
            VStack(alignment: .leading, spacing: 4) {
                Text("\(deal.departureAirport.city) → \(deal.arrivalAirport.city)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(deal.formattedDepartureDate) – \(deal.formattedReturnDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                Text("Price: \(String(format: "%.2f", deal.price.value)) EUR")
                    .font(.headline)
                    .foregroundColor(.accentColor)
            }
            .padding(.vertical, 6)
        }
        // ИЗМЕНЕНИЕ ИМЕННО ЗДЕСЬ:
        .navigationTitle("Search Results (\(deals.count))")
        .navigationBarTitleDisplayMode(.inline)
    }
}
