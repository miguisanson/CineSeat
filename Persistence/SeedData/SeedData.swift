import Foundation

// module 5 seed data entry point
// the actual seed values live in separate json files instead of swift arrays
enum SeedData {
    static var cinemas: [Cinema] {
        store.cinemas
    }

    static var movies: [Movie] {
        store.movies
    }

    static var showings: [MovieShowing] {
        store.showings
    }

    static var seedBookingIDs: Set<String> {
        Set(store.bookings.map(\.id))
    }

    static var bookings: [Booking] {
        store.bookings
    }

    static var profileAccounts: [SeedProfileAccount] {
        store.profileAccounts
    }

    static var profiles: [UserProfile] {
        profileAccounts.map(\.profile)
    }

    static func showings(for movie: Movie) -> [MovieShowing] {
        showings.filter { $0.movieTitle == movie.title }
    }

    private static let store = SeedDataStore.load()
}
