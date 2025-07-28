import SwiftUI

struct SearchResultsContainerView: View {
    @StateObject private var viewModel: ResultsViewModel
    @State private var isShowingFilterView = false
    
    init(deals: [Deal]) {
        _viewModel = StateObject(wrappedValue: ResultsViewModel(deals: deals))
    }
    
    var body: some View {
        Group {
            if viewModel.filteredAndSortedDeals.isEmpty {
                EmptyResultsView()
            } else {
                ResultsView(deals: viewModel.filteredAndSortedDeals)
            }
        }
        .navigationTitle("Search Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.filteredAndSortedDeals.isEmpty {
                    Button(action: { isShowingFilterView = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingFilterView) {
            // Передаем ВЕСЬ ViewModel, а не только его часть
            FilterView(viewModel: viewModel)
        }
    }
}
