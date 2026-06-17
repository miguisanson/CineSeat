import Foundation

// module 2 movies viewmodel
// search filters and rating sorting stay out of the view controller
final class MoviesViewModel {
    private let movies: [Movie]
    private let preferences: AppPreferencesManaging?
    var searchText = ""
    var ratingSortOrder: RatingSortOrder = .highestFirst
    var selectedCategory: MovieCategory {
        didSet {
            preferences?.selectedMovieCategory = selectedCategory
        }
    }

    init(
        fetchMoviesUseCase: FetchMoviesUseCase,
        preferences: AppPreferencesManaging? = nil
    ) {
        movies = fetchMoviesUseCase.execute()
        self.preferences = preferences
        selectedCategory = preferences?.selectedMovieCategory ?? .all
    }

    convenience init(
        movies: [Movie] = SampleData.movies,
        preferences: AppPreferencesManaging? = nil
    ) {
        self.init(
            fetchMoviesUseCase: DefaultFetchMoviesUseCase(
                movieFetcher: MockMovieAPIClient(movies: movies)
            ),
            preferences: preferences
        )
    }

    var movieCountText: String {
        "Movie library - \(movies.count) films"
    }

    var filterSummaryText: String {
        let sortText = ratingSortOrder.title.lowercased()
        switch selectedCategory {
        case .all:
            return "\(filteredMovies.count) movies available - rating \(sortText)"
        case .nowPlaying:
            return "\(filteredMovies.count) movies ready for booking - rating \(sortText)"
        case .comingSoon:
            return "\(filteredMovies.count) movies coming soon - rating \(sortText)"
        }
    }

    var canSortRating: Bool {
        true
    }

    var ratingSortButtonTitle: String {
        "rating: \(ratingSortOrder.title.lowercased())"
    }

    func toggleRatingSortOrder() {
        ratingSortOrder = ratingSortOrder == .highestFirst ? .lowestFirst : .highestFirst
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

            return matchesSearch && matchesCategory
        }

        return matchingMovies.sorted { first, second in
            if first.rating == second.rating {
                return first.title < second.title
            }

            switch ratingSortOrder {
            case .highestFirst:
                return first.rating > second.rating
            case .lowestFirst:
                return first.rating < second.rating
            }
        }
    }
}
