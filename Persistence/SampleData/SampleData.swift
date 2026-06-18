import Foundation

// module 5 sample data entry point
// the actual seed values live in SampleDataJson instead of swift arrays
enum SampleData {
    static var cinemas: [Cinema] {
        store.cinemas
    }

    static var movies: [Movie] {
        store.movies
    }

    static var showings: [MovieShowing] {
        store.showings
    }

    static var sampleBookingIDs: Set<String> {
        Set(store.bookings.map(\.id))
    }

    static var bookings: [Booking] {
        store.bookings
    }

    static var profileAccounts: [SampleProfileAccount] {
        store.profileAccounts
    }

    static var profiles: [UserProfile] {
        profileAccounts.map(\.profile)
    }

    static func showings(for movie: Movie) -> [MovieShowing] {
        showings.filter { $0.movieTitle == movie.title }
    }

    private static let store = SampleDataStore.load()
}
