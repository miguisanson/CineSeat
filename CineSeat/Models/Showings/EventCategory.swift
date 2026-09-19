import Foundation

// module 1 ticketed showing category
// this is shared only where booking and venue code handles both types
enum EventCategory: String, Codable, CaseIterable {
    case concert = "Concert"
    case seminar = "Seminar"

    var title: String { rawValue }

    var pluralTitle: String {
        switch self {
        case .concert: return "Concerts"
        case .seminar: return "Seminars"
        }
    }
}
