import Foundation

@MainActor
class AirportSelectionViewModel: ObservableObject {
    @Published var locations: [String: [AirportOption]] = [:]
    @Published var isLoading = false
    @Published var appError: AppError?
    
    private let networkingService = NetworkingService()
    
    func fetchLocations() async {
        guard locations.isEmpty else { return }
        isLoading = true
        do {
            self.locations = try await networkingService.fetchLocations()
        } catch {
            self.appError = AppError(title: "Network Error", message: "Failed to fetch locations.")
            print("🚨 Error: \(error)")
        }
        isLoading = false
    }
}
