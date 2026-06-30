import Foundation

// module 2 seminar list viewmodel
// seminar searching and venue filtering stay separate from concerts
final class SeminarListViewModel: TicketedShowingListViewModeling {
    private let seminars: [Seminar]
    private let fetchReviewsUseCase: FetchReviewsUseCase
    private(set) var selectedVenue: String?
    var searchText = ""
    var selectedStatusFilter: ShowingStatusFilter = .all
    private var ratingSortOrder: RatingSortOrder = .highestFirst

    init(fetchEventsUseCase: FetchEventsUseCase, fetchReviewsUseCase: FetchReviewsUseCase) {
        seminars = fetchEventsUseCase.execute(category: .seminar).compactMap(\.seminar)
        self.fetchReviewsUseCase = fetchReviewsUseCase
    }

    convenience init(seminars: [Seminar] = AppContent.seminars.compactMap(\.seminar)) {
        self.init(
            fetchEventsUseCase: DefaultFetchEventsUseCase(
                eventFetcher: LocalEventContentClient(
                    concerts: AppContent.concerts,
                    seminars: seminars.map(EventListing.seminar)
                )
            ),
            fetchReviewsUseCase: DefaultFetchReviewsUseCase(reviewFetcher: ReviewStore.shared)
        )
    }

    var title: String { "Seminars" }
    var searchPlaceholder: String { "Search seminars..." }
    var venueFilterTitle: String { selectedVenue ?? "All Venues" }
    var availableVenues: [String] { Array(Set(seminars.map(\.venue))).sorted() }
    var headerText: String {
        "\(filteredSeminars.count) seminars - \(selectedStatusFilter.title.lowercased()) - rating \(ratingSortOrder.title.lowercased())"
    }
    var ratingSortButtonTitle: String { "rating: \(ratingSortOrder.title.lowercased())" }
    var listings: [EventListing] { filteredSeminars.map(EventListing.seminar) }

    var filteredSeminars: [Seminar] {
        seminars.filter { seminar in
            let matchesSearch = searchText.isEmpty ||
                seminar.title.localizedCaseInsensitiveContains(searchText) ||
                seminar.eventType.localizedCaseInsensitiveContains(searchText) ||
                seminar.venue.localizedCaseInsensitiveContains(searchText)
            let matchesVenue = selectedVenue.map { seminar.venue == $0 } ?? true
            let matchesStatus: Bool
            switch selectedStatusFilter {
            case .all: matchesStatus = true
            case .nowShowing: matchesStatus = !seminar.isComingSoon
            case .comingSoon: matchesStatus = seminar.isComingSoon
            }
            return matchesSearch && matchesVenue && matchesStatus
        }
        .sorted { first, second in
            let firstRating = ratingSummary(for: .seminar(first)).effectiveRating
            let secondRating = ratingSummary(for: .seminar(second)).effectiveRating
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
