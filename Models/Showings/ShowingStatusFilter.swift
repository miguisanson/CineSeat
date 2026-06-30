import Foundation

// shared list status used by movies concerts and seminars
enum ShowingStatusFilter: Int, CaseIterable {
    case all
    case nowShowing
    case comingSoon

    var title: String {
        switch self {
        case .all: return "All"
        case .nowShowing: return "Now Showing"
        case .comingSoon: return "Coming Soon"
        }
    }
}
