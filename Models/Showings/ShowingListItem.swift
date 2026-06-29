import Foundation

// module 2 item shown by the main showings list
// one enum lets the table display movies concerts and seminars safely
enum ShowingListItem: Equatable {
    case movie(Movie)
    case event(EventListing)

    var title: String {
        switch self {
        case .movie(let movie):
            return movie.title
        case .event(let event):
            return event.title
        }
    }
}
