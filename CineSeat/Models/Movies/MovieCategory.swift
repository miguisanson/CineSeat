import Foundation

// module 2 movie list filters
// storyboard segment indexes match these raw values
enum MovieCategory: Int, CaseIterable, Codable {
    case all
    case nowPlaying
    case comingSoon

    var title: String {
        switch self {
        case .all: return "All"
        case .nowPlaying: return "Now Showing"
        case .comingSoon: return "Coming Soon"
        }
    }
}
