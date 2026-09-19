import Foundation

// shared metadata keeps details and saved bookings visually consistent
enum ShowingMetadataFormatter {
    static func movie(_ movie: Movie, ratingText: String? = nil) -> String {
        let displayedRating = ratingText ?? RatingDisplayFormatter.sourcedText(
            for: movie.rating,
            source: "Online"
        )
        return [movie.genre, duration(movie.duration), displayedRating]
            .joined(separator: " | ")
    }

    static func event(_ event: EventListing, ratingText: String? = nil) -> String {
        let displayedRating = ratingText ?? RatingDisplayFormatter.sourcedText(
            for: event.rating,
            source: "Online"
        )
        return [event.eventType, duration(event.duration), displayedRating]
            .joined(separator: " | ")
    }

    static func item(_ item: BookingItem, ratingText: String? = nil) -> String {
        switch item {
        case .movie(let movie):
            return Self.movie(movie, ratingText: ratingText)
        case .event(let event):
            return Self.event(event, ratingText: ratingText)
        }
    }

    static func duration(_ text: String) -> String {
        guard let interval = ShowingDurationParser.timeInterval(from: text) else {
            return text.lowercased()
        }
        let totalMinutes = Int(interval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%dh %02dm", hours, minutes)
    }
}
