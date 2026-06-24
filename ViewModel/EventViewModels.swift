import Foundation

// module 2 event list viewmodel
// concerts and seminars are browsed separately from movie seat booking
final class EventListViewModel {
    let category: EventCategory
    private let fetchEventsUseCase: FetchEventsUseCase
    var searchText = ""

    init(
        category: EventCategory,
        fetchEventsUseCase: FetchEventsUseCase
    ) {
        self.category = category
        self.fetchEventsUseCase = fetchEventsUseCase
    }

    convenience init(
        category: EventCategory,
        events: [EventListing]? = nil
    ) {
        let eventFetcher = MockEventAPIClient(
            concerts: category == .concert ? events ?? SeedData.concerts : SeedData.concerts,
            seminars: category == .seminar ? events ?? SeedData.seminars : SeedData.seminars
        )
        self.init(
            category: category,
            fetchEventsUseCase: DefaultFetchEventsUseCase(eventFetcher: eventFetcher)
        )
    }

    var events: [EventListing] {
        fetchEventsUseCase.execute(category: category)
    }

    var title: String {
        category.pluralTitle
    }

    var searchPlaceholder: String {
        "Search \(category.pluralTitle.lowercased())..."
    }

    var headerText: String {
        "\(filteredEvents.count) \(category.pluralTitle.lowercased()) available"
    }

    var filteredEvents: [EventListing] {
        let matches = events.filter { event in
            searchText.isEmpty ||
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.eventType.localizedCaseInsensitiveContains(searchText) ||
                event.venue.localizedCaseInsensitiveContains(searchText)
        }

        return matches.sorted { first, second in
            if first.isFeatured != second.isFeatured {
                return first.isFeatured && !second.isFeatured
            }
            if first.rating != second.rating {
                return first.rating > second.rating
            }
            return first.title < second.title
        }
    }

    func event(at index: Int) -> EventListing {
        filteredEvents[index]
    }
}
