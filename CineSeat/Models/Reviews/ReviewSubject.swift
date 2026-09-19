import Foundation

// small value passed from a detail screen into the reviews feature
struct ReviewSubject: Equatable {
    let id: String
    let title: String
    let contentType: ReviewContentType
    let onlineRating: Double?
    let tmdbMovieID: Int?

    init(
        id: String,
        title: String,
        contentType: ReviewContentType,
        onlineRating: Double?,
        tmdbMovieID: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.contentType = contentType
        self.onlineRating = onlineRating.flatMap { $0 > 0 ? $0 : nil }
        self.tmdbMovieID = tmdbMovieID
    }

    init(movie: Movie) {
        self.init(
            id: movie.title,
            title: movie.title,
            contentType: .movie,
            onlineRating: movie.rating,
            tmdbMovieID: movie.tmdbID
        )
    }

    init(event: EventListing) {
        self.init(
            id: event.id,
            title: event.title,
            contentType: event.category == .concert ? .concert : .seminar,
            onlineRating: event.rating
        )
    }

    init(booking: Booking) {
        switch booking.item {
        case .movie(let movie): self.init(movie: movie)
        case .event(let event): self.init(event: event)
        }
    }
}
