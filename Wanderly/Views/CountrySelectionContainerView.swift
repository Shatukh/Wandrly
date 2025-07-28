import SwiftUI

/// Этот View — обёртка, которая управляет навигацией внутри модального окна
struct CountrySelectionContainerView: View {
    @ObservedObject var viewModel: AirportSelectionViewModel
    @Binding var selectedAirportCodes: [String]

    var body: some View {
        NavigationView {
            CountrySelectionView(
                viewModel: viewModel,
                selectedAirportCodes: $selectedAirportCodes
            )
        }
    }
}
