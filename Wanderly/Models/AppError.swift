import Foundation

struct AppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
