import Foundation

// module 2 showings landing category
// movies concerts and seminars each continue into a booking flow
enum ShowingCategory: Int, CaseIterable {
    case movies
    case concerts
    case seminars

    var title: String {
        switch self {
        case .movies:
            return "Movies"
        case .concerts:
            return "Concerts"
        case .seminars:
            return "Seminars"
        }
    }

    var subtitle: String {
        switch self {
        case .movies:
            return "cinema schedules, seats, and booking"
        case .concerts:
            return "concerts, festivals, orchestra, and theater"
        case .seminars:
            return "seminars, conferences, and workshops"
        }
    }

    var iconName: String {
        switch self {
        case .movies:
            return "film"
        case .concerts:
            return "music.mic"
        case .seminars:
            return "person.3.sequence"
        }
    }

    var locationFilterLabel: String {
        switch self {
        case .movies:
            return "Cinemas"
        case .concerts, .seminars:
            return "Venues"
        }
    }

    var allLocationsTitle: String {
        "All \(locationFilterLabel)"
    }
}
