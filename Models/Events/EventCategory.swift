import Foundation

// module 1 event category enum
// json uses these values to separate non-movie showings
enum EventCategory: String, Codable, CaseIterable {
    case concert = "Concert"
    case seminar = "Seminar"

    var title: String {
        rawValue
    }

    var pluralTitle: String {
        switch self {
        case .concert:
            return "Concerts"
        case .seminar:
            return "Seminars"
        }
    }

    var emptyText: String {
        "No \(pluralTitle.lowercased()) available yet."
    }
}
