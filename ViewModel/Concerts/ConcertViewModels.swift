import Foundation

// module 2 concert list viewmodel
// concert searching and venue filtering do not depend on seminar data
final class ConcertListViewModel: TicketedShowingListViewModeling {
    private let concerts: [Concert]
    private let fetchReviewsUseCase: FetchReviewsUseCase
    private(set) var selectedVenue: String?
    var searchText = ""
    var selectedStatusFilter: ShowingStatusFilter = .all
    private var ratingSortOrder: RatingSortOrder = .highestFirst

    init(fetchEventsUseCase: FetchEventsUseCase, fetchReviewsUseCase: FetchReviewsUseCase) {
        concerts = fetchEventsUseCase.execute(category: .concert).compactMap(\.concert)
        self.fetchReviewsUseCase = fetchReviewsUseCase
    }

    convenience init(concerts: [Concert] = AppCatalog.concerts.compactMap(\.concert)) {
        self.init(
            fetchEventsUseCase: DefaultFetchEventsUseCase(
                eventFetcher: LocalEventCatalogClient(
                    concerts: concerts.map(EventListing.concert),
                    seminars: AppCatalog.seminars
                )
            ),
            fetchReviewsUseCase: DefaultFetchReviewsUseCase(reviewFetcher: ReviewStore.shared)
        )
    }

    var title: String { "Concerts" }
    var searchPlaceholder: String { "Search concerts..." }
    var venueFilterTitle: String { selectedVenue ?? "All Venues" }
    var availableVenues: [String] { Array(Set(concerts.map(\.venue))).sorted() }
    var headerText: String {
        "\(filteredConcerts.count) concerts - \(selectedStatusFilter.title.lowercased()) - rating \(ratingSortOrder.title.lowercased())"
    }
    var ratingSortButtonTitle: String { "rating: \(ratingSortOrder.title.lowercased())" }
    var listings: [EventListing] { filteredConcerts.map(EventListing.concert) }

    var filteredConcerts: [Concert] {
        concerts.filter { concert in
            let matchesSearch = searchText.isEmpty ||
                concert.title.localizedCaseInsensitiveContains(searchText) ||
                concert.eventType.localizedCaseInsensitiveContains(searchText) ||
                concert.venue.localizedCaseInsensitiveContains(searchText)
            let matchesVenue = selectedVenue.map { concert.venue == $0 } ?? true
            let matchesStatus: Bool
            switch selectedStatusFilter {
            case .all: matchesStatus = true
            case .nowShowing: matchesStatus = !concert.isComingSoon
            case .comingSoon: matchesStatus = concert.isComingSoon
            }
            return matchesSearch && matchesVenue && matchesStatus
        }
        .sorted { first, second in
            let firstRating = ratingSummary(for: .concert(first)).effectiveRating
            let secondRating = ratingSummary(for: .concert(second)).effectiveRating
            if firstRating == secondRating { return first.title < second.title }
            return ratingSortOrder == .highestFirst ? firstRating > secondRating : firstRating < secondRating
        }
    }

    func selectVenue(_ venue: String?) {
        selectedVenue = venue
    }

    func toggleRatingSortOrder() {
        ratingSortOrder = ratingSortOrder == .highestFirst ? .lowestFirst : .highestFirst
    }

    func ratingSummary(for listing: EventListing) -> ReviewRatingSummary {
        fetchReviewsUseCase.ratingSummary(for: ReviewSubject(event: listing))
    }
}
