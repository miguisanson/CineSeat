import Foundation

// module 1 codable booking item
// the enum prevents an event booking from pretending to be a movie booking
enum BookingItem: Equatable, Codable {
    case movie(Movie)
    case event(EventListing)

    private enum ItemType: String, Codable {
        case movie
        case event
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case movie
        case event
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(ItemType.self, forKey: .type) {
        case .movie:
            self = .movie(try container.decode(Movie.self, forKey: .movie))
        case .event:
            self = .event(try container.decode(EventListing.self, forKey: .event))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .movie(let movie):
            try container.encode(ItemType.movie, forKey: .type)
            try container.encode(movie, forKey: .movie)
        case .event(let event):
            try container.encode(ItemType.event, forKey: .type)
            try container.encode(event, forKey: .event)
        }
    }

    var title: String {
        switch self {
        case .movie(let movie): return movie.title
        case .event(let event): return event.title
        }
    }

    var detailText: String {
        switch self {
        case .movie(let movie): return "\(movie.genre) - \(movie.duration)"
        case .event(let event): return "\(event.eventType) - \(event.duration)"
        }
    }

    var categoryTitle: String {
        switch self {
        case .movie: return "Movie"
        case .event(let event): return event.category.title
        }
    }

    var isMovie: Bool {
        if case .movie = self { return true }
        return false
    }
}
