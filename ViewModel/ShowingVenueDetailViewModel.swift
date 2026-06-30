import Foundation

// module 2 event venue detail viewmodel
// this groups every concert or seminar assigned to one venue pin
final class ShowingVenueDetailViewModel {
    let venue: EventVenue
    private let eventsSource: (EventVenue) -> [EventListing]

    init(
        venue: EventVenue,
        eventsSource: @escaping (EventVenue) -> [EventListing] = AppCatalog.events(at:)
    ) {
        self.venue = venue
        self.eventsSource = eventsSource
    }

    var events: [EventListing] {
        eventsSource(venue).sorted { $0.title < $1.title }
    }

    var countText: String {
        "\(events.count) EVENT\(events.count == 1 ? "" : "S") AT THIS VENUE"
    }

    func event(at index: Int) -> EventListing {
        events[index]
    }
}
