import Foundation

// shared booking value for a concert or seminar
// concrete starter json still decodes into Concert and Seminar first
enum EventListing: Equatable, Identifiable, Codable {
    case concert(Concert)
    case seminar(Seminar)

    private enum CodingKeys: String, CodingKey {
        case category
        case concert
        case seminar
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let category = try container.decode(EventCategory.self, forKey: .category)

        switch category {
        case .concert:
            if let concert = try container.decodeIfPresent(Concert.self, forKey: .concert) {
                self = .concert(concert)
            } else {
                self = .concert(try Concert(from: decoder))
            }
        case .seminar:
            if let seminar = try container.decodeIfPresent(Seminar.self, forKey: .seminar) {
                self = .seminar(seminar)
            } else {
                self = .seminar(try Seminar(from: decoder))
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(category, forKey: .category)
        switch self {
        case .concert(let concert):
            try container.encode(concert, forKey: .concert)
        case .seminar(let seminar):
            try container.encode(seminar, forKey: .seminar)
        }
    }

    var id: String { value.id }
    var title: String { value.title }
    var eventType: String { value.eventType }
    var venue: String { value.venue }
    var duration: String { value.duration }
    var rating: Double { value.rating }
    var summary: String { value.summary }
    var posterURLString: String? { value.posterURLString }
    var localPosterName: String? { value.localPosterName }
    var isFeatured: Bool { value.isFeatured }
    var isComingSoon: Bool { value.isComingSoon }
    var statusText: String { "BOOK" }
    var detailText: String { "\(eventType) - \(venue)" }

    var concert: Concert? {
        guard case .concert(let concert) = self else { return nil }
        return concert
    }

    var seminar: Seminar? {
        guard case .seminar(let seminar) = self else { return nil }
        return seminar
    }

    var category: EventCategory {
        switch self {
        case .concert: return .concert
        case .seminar: return .seminar
        }
    }

    private var value: CommonShowingValues {
        switch self {
        case .concert(let concert):
            return CommonShowingValues(
                id: concert.id,
                title: concert.title,
                eventType: concert.eventType,
                venue: concert.venue,
                duration: concert.duration,
                rating: concert.rating,
                summary: concert.summary,
                posterURLString: concert.posterURLString,
                localPosterName: concert.localPosterName,
                isFeatured: concert.isFeatured,
                isComingSoon: concert.isComingSoon
            )
        case .seminar(let seminar):
            return CommonShowingValues(
                id: seminar.id,
                title: seminar.title,
                eventType: seminar.eventType,
                venue: seminar.venue,
                duration: seminar.duration,
                rating: seminar.rating,
                summary: seminar.summary,
                posterURLString: seminar.posterURLString,
                localPosterName: seminar.localPosterName,
                isFeatured: seminar.isFeatured,
                isComingSoon: seminar.isComingSoon
            )
        }
    }
}

private struct CommonShowingValues {
    let id: String
    let title: String
    let eventType: String
    let venue: String
    let duration: String
    let rating: Double
    let summary: String
    let posterURLString: String?
    let localPosterName: String?
    let isFeatured: Bool
    let isComingSoon: Bool
}
