import SwiftUI

struct ResultsView: View {
    let deals: [Deal]
    
    var body: some View {
        List(deals) { deal in
            VStack(alignment: .leading, spacing: 4) {
                Text("\(deal.departureAirport.city) → \(deal.arrivalAirport.city)")
                    .font(.headline)
                Text("\(deal.formattedDepartureDate) – \(deal.formattedReturnDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Price: \(String(format: "%.2f", deal.price.value)) EUR")
                    .font(.headline)
                    .foregroundColor(.accentColor)
            }
            .padding(.vertical, 6)
        }
        .navigationTitle("Search Results (\(deals.count))")
        .navigationBarTitleDisplayMode(.inline)
    }
}
