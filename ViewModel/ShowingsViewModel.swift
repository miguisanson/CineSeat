import Foundation

// module 2 showings landing viewmodel
// keeps the first screen from knowing seed data details directly
final class ShowingsViewModel {
    private let movieCount: Int
    private let concertCount: Int
    private let seminarCount: Int

    init(
        movieCount: Int = SeedData.movies.count,
        concertCount: Int = SeedData.concerts.count,
        seminarCount: Int = SeedData.seminars.count
    ) {
        self.movieCount = movieCount
        self.concertCount = concertCount
        self.seminarCount = seminarCount
    }

    var categories: [ShowingCategory] {
        ShowingCategory.allCases
    }

    var headerText: String {
        "Choose what you want to view"
    }

    func countText(for category: ShowingCategory) -> String {
        switch category {
        case .movies:
            return "\(movieCount) movies"
        case .concerts:
            return "\(concertCount) events"
        case .seminars:
            return "\(seminarCount) sessions"
        }
    }
}
