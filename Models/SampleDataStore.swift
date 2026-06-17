import Foundation

// module 5 json seed data loader
// the real sample data is in SampleDataJson instead of hardcoded swift arrays
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

private struct SampleDataStore {
    let cinemas: [Cinema]
    let movies: [Movie]
    let showings: [MovieShowing]
    let bookings: [Booking]
    let profileAccounts: [SampleProfileAccount]

    static func load(
        fileManager: FileManager = .default,
        bundle: Bundle = .main
    ) -> SampleDataStore {
        do {
            let seedData = try loadSeedData(fileManager: fileManager, bundle: bundle)
            return try seedData.makeStore()
        } catch {
            fatalError("Could not load SampleDataJson.json: \(error.localizedDescription)")
        }
    }

    private static func loadSeedData(fileManager: FileManager, bundle: Bundle) throws -> SampleDataJSON {
        let bundles = [bundle, Bundle.main, Bundle(for: SampleDataBundleToken.self)]
        let jsonURL = bundles.compactMap {
            $0.url(forResource: "SampleDataJson", withExtension: "json")
        }.first

        guard let jsonURL,
              fileManager.fileExists(atPath: jsonURL.path) else {
            throw SampleDataError.missingJSON
        }

        let data = try Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SampleDataJSON.self, from: data)
    }
}

private final class SampleDataBundleToken {}

private struct SampleDataJSON: Decodable {
    let cinemas: [Cinema]
    let movies: [Movie]
    let showings: [ShowingJSON]
    let bookings: [BookingJSON]
    let profileAccounts: [ProfileAccountJSON]

    func makeStore() throws -> SampleDataStore {
        let cinemaByID = Dictionary(uniqueKeysWithValues: cinemas.map { ($0.id, $0) })
        let movieByTitle = Dictionary(uniqueKeysWithValues: movies.map { ($0.title, $0) })

        let mappedShowings = try showings.map { showing -> MovieShowing in
            guard let cinema = cinemaByID[showing.cinemaID] else {
                throw SampleDataError.missingCinema(showing.cinemaID)
            }
            return MovieShowing(
                id: showing.id,
                movieTitle: showing.movieTitle,
                dateTitle: showing.dateTitle,
                date: showing.date,
                showtime: showing.showtime,
                cinema: cinema
            )
        }

        let mappedBookings = try bookings.map { booking -> Booking in
            guard let movie = movieByTitle[booking.movieTitle] else {
                throw SampleDataError.missingMovie(booking.movieTitle)
            }
            guard let cinema = cinemaByID[booking.cinemaID] else {
                throw SampleDataError.missingCinema(booking.cinemaID)
            }
            return Booking(
                id: booking.id,
                movie: movie,
                date: booking.date,
                showtime: booking.showtime,
                cinema: cinema.name,
                seats: booking.seats,
                ticketPrice: cinema.ticketPrice,
                bookingFee: booking.bookingFee,
                status: booking.status
            )
        }

        let mappedAccounts = profileAccounts.map {
            SampleProfileAccount(profile: $0.profile, password: $0.password)
        }

        return SampleDataStore(
            cinemas: cinemas,
            movies: movies,
            showings: mappedShowings,
            bookings: mappedBookings,
            profileAccounts: mappedAccounts
        )
    }
}

private struct ShowingJSON: Decodable {
    let id: String
    let movieTitle: String
    let dateTitle: String
    let date: String
    let showtime: String
    let cinemaID: Int
}

private struct BookingJSON: Decodable {
    let id: String
    let movieTitle: String
    let date: String
    let showtime: String
    let cinemaID: Int
    let seats: [String]
    let bookingFee: Double
    let status: BookingStatus
}

private struct ProfileAccountJSON: Decodable {
    let profile: UserProfile
    let password: String
}

private enum SampleDataError: LocalizedError {
    case missingJSON
    case missingMovie(String)
    case missingCinema(Int)

    var errorDescription: String? {
        switch self {
        case .missingJSON:
            return "SampleDataJson.json is missing from the app bundle"
        case .missingMovie(let title):
            return "Missing movie in sample json: \(title)"
        case .missingCinema(let id):
            return "Missing cinema in sample json: \(id)"
        }
    }
}
