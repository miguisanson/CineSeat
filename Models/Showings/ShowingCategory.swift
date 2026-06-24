import Foundation

// module 2 showings landing category
// movies keep the booking flow while events are browsing pages
enum ShowingCategory: CaseIterable {
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
}
