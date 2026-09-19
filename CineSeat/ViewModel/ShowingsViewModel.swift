import Foundation

// module 2 showings landing viewmodel
// this page only owns category counts and leaves filters to each feature
final class ShowingsViewModel {
    private let movieCount: Int
    private let concertCount: Int
    private let seminarCount: Int

    init(fetchMoviesUseCase: FetchMoviesUseCase, fetchEventsUseCase: FetchEventsUseCase) {
        movieCount = fetchMoviesUseCase.execute().count
        concertCount = fetchEventsUseCase.execute(category: .concert).count
        seminarCount = fetchEventsUseCase.execute(category: .seminar).count
    }

    convenience init(
        movies: [Movie] = AppContent.movies,
        concerts: [EventListing] = AppContent.concerts,
        seminars: [EventListing] = AppContent.seminars
    ) {
        self.init(
            fetchMoviesUseCase: DefaultFetchMoviesUseCase(movieFetcher: LocalMovieContentClient(movies: movies)),
            fetchEventsUseCase: DefaultFetchEventsUseCase(
                eventFetcher: LocalEventContentClient(concerts: concerts, seminars: seminars)
            )
        )
    }

    var categories: [ShowingCategory] { ShowingCategory.allCases }
    var headerText: String { "Choose what you want to view" }

    func countText(for category: ShowingCategory) -> String {
        switch category {
        case .movies: return "\(movieCount) movies"
        case .concerts: return "\(concertCount) concerts"
        case .seminars: return "\(seminarCount) seminars"
        }
    }
}
