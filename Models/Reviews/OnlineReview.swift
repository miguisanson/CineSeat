import Foundation

// online reviews stay separate from reviews written inside TicketPlease
struct OnlineReview: Equatable, Identifiable {
    let id: String
    let authorName: String
    let rating: Double?
    let content: String
    let createdAt: Date?
    let sourceURL: URL?
}

enum OnlineReviewError: LocalizedError, Equatable {
    case unavailableForContent
    case missingConfiguration
    case invalidResponse
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .unavailableForContent:
            return "Online written reviews are currently available for movies only."
        case .missingConfiguration:
            return "Add TMDB_READ_ACCESS_TOKEN to the active scheme environment to load online reviews."
        case .invalidResponse:
            return "The online review service returned an invalid response."
        case .requestFailed:
            return "Online reviews could not be loaded. Check the connection and try again."
        }
    }
}
