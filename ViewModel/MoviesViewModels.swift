import Foundation

// module 2 movies viewmodel
// search filters and rating sorting stay out of the view controller
final class MoviesViewModel {
    private let movies: [Movie]
    private let movieShowings: [MovieShowing]
    private let fetchReviewsUseCase: FetchReviewsUseCase
    private let preferences: AppPreferencesManaging?
    var searchText = ""
    var ratingSortOrder: RatingSortOrder = .highestFirst
    private(set) var selectedCinemaName: String?
    var selectedCategory: MovieCategory {
        didSet {
            preferences?.selectedMovieCategory = selectedCategory
        }
    }

    init(
        fetchMoviesUseCase: FetchMoviesUseCase,
        fetchMovieShowingsUseCase: FetchMovieShowingsUseCase = DefaultFetchMovieShowingsUseCase(
            showingFetcher: LocalMovieShowingContentClient()
        ),
        fetchReviewsUseCase: FetchReviewsUseCase = DefaultFetchReviewsUseCase(
            reviewFetcher: ReviewStore.shared
        ),
        preferences: AppPreferencesManaging? = nil
    ) {
        movies = fetchMoviesUseCase.execute()
        movieShowings = fetchMovieShowingsUseCase.execute()
        self.fetchReviewsUseCase = fetchReviewsUseCase
        self.preferences = preferences
        selectedCategory = preferences?.selectedMovieCategory ?? .all
    }

    convenience init(
        movies: [Movie] = AppContent.movies,
        movieShowings: [MovieShowing] = AppContent.showings,
        preferences: AppPreferencesManaging? = nil
    ) {
        self.init(
            fetchMoviesUseCase: DefaultFetchMoviesUseCase(
                movieFetcher: LocalMovieContentClient(movies: movies)
            ),
            fetchMovieShowingsUseCase: DefaultFetchMovieShowingsUseCase(
                showingFetcher: LocalMovieShowingContentClient(showings: movieShowings)
            ),
            fetchReviewsUseCase: DefaultFetchReviewsUseCase(
                reviewFetcher: ReviewStore.shared
            ),
            preferences: preferences
        )
    }

    var movieCountText: String {
        "Movie library - \(movies.count) films"
    }

    var filterSummaryText: String {
        let sortText = ratingSortOrder.title.lowercased()
        return "\(filteredMovies.count) movies - \(selectedCategory.title.lowercased()) - rating \(sortText)"
    }

    var canSortRating: Bool {
        true
    }

    var ratingSortButtonTitle: String {
        "rating: \(ratingSortOrder.title.lowercased())"
    }

    var cinemaFilterTitle: String {
        selectedCinemaName ?? "All Cinemas"
    }

    var availableCinemaNames: [String] {
        let cinemas = movieShowings.flatMap(\.allTimes).map(\.time.cinema)
        return Dictionary(grouping: cinemas, by: \.id)
            .compactMap { $0.value.first }
            .sorted { $0.id < $1.id }
            .map(\.name)
    }

    func toggleRatingSortOrder() {
        ratingSortOrder = ratingSortOrder == .highestFirst ? .lowestFirst : .highestFirst
    }

    func selectCinema(_ cinemaName: String?) {
        selectedCinemaName = cinemaName
    }

    func ratingSummary(for movie: Movie) -> ReviewRatingSummary {
        fetchReviewsUseCase.ratingSummary(for: ReviewSubject(movie: movie))
    }

    var filteredMovies: [Movie] {
        let matchingMovies = movies.filter { movie in
            let matchesSearch = searchText.isEmpty ||
                movie.title.localizedCaseInsensitiveContains(searchText) ||
                movie.genre.localizedCaseInsensitiveContains(searchText)

            let matchesCategory: Bool
            switch selectedCategory {
            case .all:
                matchesCategory = true
            case .nowPlaying:
                matchesCategory = movie.isNowPlaying
            case .comingSoon:
                matchesCategory = movie.isComingSoon
            }

            let matchesCinema = selectedCinemaName.map { cinemaName in
                movieShowings.contains { showing in
                    showing.movieTitle == movie.title && showing.allTimes.contains {
                        $0.time.cinema.name == cinemaName
                    }
                }
            } ?? true

            return matchesSearch && matchesCategory && matchesCinema
        }

        return matchingMovies.sorted { first, second in
            let firstRating = ratingSummary(for: first).effectiveRating
            let secondRating = ratingSummary(for: second).effectiveRating
            if firstRating == secondRating {
                return first.title < second.title
            }

            switch ratingSortOrder {
            case .highestFirst:
                return firstRating > secondRating
            case .lowestFirst:
                return firstRating < secondRating
            }
        }
    }
}
