import Foundation

// module 1 codable movie model
// poster url is fallback while localPosterName points to bundled offline image
struct Movie: Codable, Equatable {
    let title: String
    let genre: String
    let duration: String
    let rating: Double
    let synopsis: String
    let posterURLString: String?
    let localPosterName: String?
    let isNowPlaying: Bool
    let isComingSoon: Bool
}
