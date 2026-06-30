import Foundation

// module 1 seminar model
// seminar json stays separate from concert data and naming
struct Seminar: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let eventType: String
    let venue: String
    let duration: String
    let rating: Double
    let summary: String
    let posterURLString: String?
    let localPosterName: String?
    let isFeatured: Bool
    let isComingSoon: Bool
}
