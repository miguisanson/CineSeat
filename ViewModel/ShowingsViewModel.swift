import Foundation

// module 2 showings viewmodel
// category search schedule and location filters stay outside the view controller
final class ShowingsViewModel {
    private let movies: [Movie]
    private let concerts: [EventListing]
    private let seminars: [EventListing]
    private let movieShowings: [MovieShowing]
    private let preferences: AppPreferencesManaging?

    var searchText = ""
    var ratingSortOrder: RatingSortOrder = .highestFirst
    var selectedLocationName: String?

    var selectedCategory: ShowingCategory = .movies {
        didSet {
            selectedLocationName = nil
        }
    }

    var selectedMovieCategory: MovieCategory {
        didSet {
            preferences?.selectedMovieCategory = selectedMovieCategory
        }
    }

    init(
        fetchMoviesUseCase: FetchMoviesUseCase,
        fetchEventsUseCase: FetchEventsUseCase,
        fetchMovieShowingsUseCase: FetchMovieShowingsUseCase,
        preferences: AppPreferencesManaging? = nil
    ) {
        movies = fetchMoviesUseCase.execute()
        concerts = fetchEventsUseCase.execute(category: .concert)
        seminars = fetchEventsUseCase.execute(category: .seminar)
        movieShowings = fetchMovieShowingsUseCase.execute()
        self.preferences = preferences
        selectedMovieCategory = preferences?.selectedMovieCategory ?? .all
    }

    convenience init(
        movies: [Movie] = SeedData.movies,
        concerts: [EventListing] = SeedData.concerts,
        seminars: [EventListing] = SeedData.seminars,
        movieShowings: [MovieShowing] = SeedData.showings,
        preferences: AppPreferencesManaging? = nil
    ) {
        self.init(
            fetchMoviesUseCase: DefaultFetchMoviesUseCase(
                movieFetcher: MockMovieAPIClient(movies: movies)
            ),
            fetchEventsUseCase: DefaultFetchEventsUseCase(
                eventFetcher: MockEventAPIClient(concerts: concerts, seminars: seminars)
            ),
            fetchMovieShowingsUseCase: DefaultFetchMovieShowingsUseCase(
                showingFetcher: MockMovieShowingAPIClient(showings: movieShowings)
            ),
            preferences: preferences
        )
    }

    var categories: [ShowingCategory] {
        ShowingCategory.allCases
    }

    var headerText: String {
        "Browse movies, concerts, and seminars"
    }

    var searchPlaceholder: String {
        "Search \(selectedCategory.title.lowercased())..."
    }

    var locationFilterTitle: String {
        selectedLocationName ?? selectedCategory.allLocationsTitle
    }

    var availableLocationNames: [String] {
        switch selectedCategory {
        case .movies:
            let cinemas = movieShowings.flatMap(\.allTimes).map(\.time.cinema)
            let uniqueCinemas = Dictionary(grouping: cinemas, by: \.id).compactMap { $0.value.first }
            return uniqueCinemas.sorted { $0.id < $1.id }.map(\.name)
        case .concerts:
            return uniqueVenues(from: concerts)
        case .seminars:
            return uniqueVenues(from: seminars)
        }
    }

    var filterSummaryText: String {
        let locationText = selectedLocationName ?? selectedCategory.allLocationsTitle
        switch selectedCategory {
        case .movies:
            return "\(filteredItems.count) \(selectedMovieCategory.title.lowercased()) movies - \(locationText) - rating \(ratingSortOrder.title.lowercased())"
        case .concerts, .seminars:
            return "\(filteredItems.count) \(selectedCategory.title.lowercased()) - \(locationText)"
        }
    }

    var emptyStateText: String {
        "No \(selectedCategory.title.lowercased()) match these filters"
    }

    var showsMovieFilters: Bool {
        selectedCategory == .movies
    }

    var ratingSortButtonTitle: String {
        "Rating: \(ratingSortOrder.title)"
    }

    var filteredItems: [ShowingListItem] {
        switch selectedCategory {
        case .movies:
            return filteredMovies.map(ShowingListItem.movie)
        case .concerts:
            return filteredEvents(concerts).map(ShowingListItem.event)
        case .seminars:
            return filteredEvents(seminars).map(ShowingListItem.event)
        }
    }

    func countText(for category: ShowingCategory) -> String {
        switch category {
        case .movies:
            return "\(movies.count) movies"
        case .concerts:
            return "\(concerts.count) events"
        case .seminars:
            return "\(seminars.count) sessions"
        }
    }

    func selectCategory(at index: Int) {
        guard let category = ShowingCategory(rawValue: index) else { return }
        selectedCategory = category
    }

    func selectLocation(_ locationName: String?) {
        selectedLocationName = locationName
    }

    func toggleRatingSortOrder() {
        ratingSortOrder = ratingSortOrder == .highestFirst ? .lowestFirst : .highestFirst
    }

    func item(at index: Int) -> ShowingListItem {
        filteredItems[index]
    }

    private var filteredMovies: [Movie] {
        movies.filter { movie in
            let matchesSearch = searchText.isEmpty ||
                movie.title.localizedCaseInsensitiveContains(searchText) ||
                movie.genre.localizedCaseInsensitiveContains(searchText)

            let matchesStatus: Bool
            switch selectedMovieCategory {
            case .all:
                matchesStatus = true
            case .nowPlaying:
                matchesStatus = movie.isNowPlaying
            case .comingSoon:
                matchesStatus = movie.isComingSoon
            }

            let matchesCinema = selectedLocationName.map { cinemaName in
                movieShowings.contains { showing in
                    showing.movieTitle == movie.title && showing.allTimes.contains {
                        $0.time.cinema.name == cinemaName
                    }
                }
            } ?? true

            return matchesSearch && matchesStatus && matchesCinema
        }
        .sorted { first, second in
            if first.rating == second.rating {
                return first.title < second.title
            }
            return ratingSortOrder == .highestFirst
                ? first.rating > second.rating
                : first.rating < second.rating
        }
    }

    private func filteredEvents(_ events: [EventListing]) -> [EventListing] {
        events.filter { event in
            let matchesSearch = searchText.isEmpty ||
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.eventType.localizedCaseInsensitiveContains(searchText) ||
                event.venue.localizedCaseInsensitiveContains(searchText)
            let matchesVenue = selectedLocationName.map { event.venue == $0 } ?? true
            return matchesSearch && matchesVenue
        }
        .sorted { first, second in
            if first.isFeatured != second.isFeatured {
                return first.isFeatured && !second.isFeatured
            }
            if first.rating != second.rating {
                return first.rating > second.rating
            }
            return first.title < second.title
        }
    }

    private func uniqueVenues(from events: [EventListing]) -> [String] {
        Array(Set(events.map(\.venue))).sorted()
    }
}
