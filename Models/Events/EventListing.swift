import Foundation

// module 1 codable event model
// concerts and seminars reuse the same poster loading pattern as movies
struct EventListing: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let category: EventCategory
    let eventType: String
    let venue: String
    let duration: String
    let rating: Double
    let summary: String
    let posterURLString: String?
    let localPosterName: String?
    let isFeatured: Bool
    let isComingSoon: Bool

    var statusText: String {
        "BOOK"
    }

    var detailText: String {
        "\(eventType) - \(venue)"
    }
}
