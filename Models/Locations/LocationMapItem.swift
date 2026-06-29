import Foundation

// module 2 location map category
// the segmented control index matches these raw values
enum LocationCategory: Int, CaseIterable {
    case cinemas
    case eventVenues

    var title: String {
        switch self {
        case .cinemas: return "Cinemas"
        case .eventVenues: return "Event Venues"
        }
    }
}

// module 2 map item
// one pin can safely keep either a cinema or an event venue model
enum LocationMapItem: Equatable {
    case cinema(Cinema)
    case eventVenue(EventVenue)

    var id: String {
        switch self {
        case .cinema(let cinema): return "cinema-\(cinema.id)"
        case .eventVenue(let venue): return "event-venue-\(venue.id)"
        }
    }

    var title: String {
        switch self {
        case .cinema(let cinema): return cinema.name
        case .eventVenue(let venue): return venue.name
        }
    }

    var subtitle: String {
        switch self {
        case .cinema(let cinema):
            return "\(cinema.type.rawValue) - \(cinema.location?.address ?? "Address unavailable")"
        case .eventVenue(let venue):
            return venue.address
        }
    }

    var latitude: Double? {
        switch self {
        case .cinema(let cinema): return cinema.location?.latitude
        case .eventVenue(let venue): return venue.latitude
        }
    }

    var longitude: Double? {
        switch self {
        case .cinema(let cinema): return cinema.location?.longitude
        case .eventVenue(let venue): return venue.longitude
        }
    }
}
