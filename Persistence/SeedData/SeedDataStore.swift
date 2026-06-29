import Foundation

// module 5 json seed data loader
// this file finds each bundled json resource and keeps decoding in one place
struct SeedDataStore {
    let cinemas: [Cinema]
    let movies: [Movie]
    let concerts: [EventListing]
    let seminars: [EventListing]
    let eventVenues: [EventVenue]
    let eventShowings: [EventShowing]
    let showings: [MovieShowing]
    let bookings: [Booking]
    let profileAccounts: [SeedProfileAccount]

    static func load(
        fileManager: FileManager = .default,
        bundle: Bundle = .main
    ) -> SeedDataStore {
        do {
            let seedData = try loadSeedData(fileManager: fileManager, bundle: bundle)
            return try SeedDataMapper.makeStore(from: seedData)
        } catch {
            fatalError("Could not load bundled seed data: \(error.localizedDescription)")
        }
    }

    private static func loadSeedData(fileManager: FileManager, bundle: Bundle) throws -> SeedDataDTO {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let reader = JSONFileReader(fileManager: fileManager, decoder: decoder)

        return SeedDataDTO(
            cinemas: try read([Cinema].self, named: "Cinemas", reader: reader, bundle: bundle),
            movies: try read([Movie].self, named: "Movies", reader: reader, bundle: bundle),
            concerts: try read([EventListing].self, named: "Concerts", reader: reader, bundle: bundle),
            seminars: try read([EventListing].self, named: "Seminars", reader: reader, bundle: bundle),
            eventVenues: try read([EventVenue].self, named: "EventVenues", reader: reader, bundle: bundle),
            eventShowings: try read([EventShowingDTO].self, named: "EventShowings", reader: reader, bundle: bundle),
            showings: try read([ShowingDTO].self, named: "Showings", reader: reader, bundle: bundle),
            bookings: try read([BookingDTO].self, named: "Bookings", reader: reader, bundle: bundle),
            profileAccounts: try read([ProfileAccountDTO].self, named: "ProfileAccounts", reader: reader, bundle: bundle)
        )
    }

    private static func read<T: Decodable>(
        _ type: T.Type,
        named name: String,
        reader: JSONFileReader,
        bundle: Bundle
    ) throws -> T {
        guard let jsonURL = reader.bundledResourceURL(
            named: name,
            extension: "json",
            bundle: bundle
        ) else {
            throw SeedDataError.missingJSON(name)
        }

        guard reader.exists(at: jsonURL) else {
            throw SeedDataError.missingJSON(name)
        }

        return try reader.read(type, from: jsonURL)
    }
}
