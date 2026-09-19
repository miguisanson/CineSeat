import Foundation

// module 1 concert model
// concert json decodes into its own type instead of a broad event struct
struct Concert: Codable, Equatable, Identifiable {
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
