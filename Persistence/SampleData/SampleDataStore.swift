import Foundation

// module 5 json seed data loader
// this file only finds and decodes the bundled json resource
struct SampleDataStore {
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
            return try SampleDataMapper.makeStore(from: seedData)
        } catch {
            fatalError("Could not load SampleDataJson.json: \(error.localizedDescription)")
        }
    }

    private static func loadSeedData(fileManager: FileManager, bundle: Bundle) throws -> SampleDataDTO {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let reader = JSONFileReader(fileManager: fileManager, decoder: decoder)

        guard let jsonURL = reader.bundledResourceURL(
            named: "SampleDataJson",
            extension: "json",
            bundle: bundle
        ) else {
            throw SampleDataError.missingJSON
        }

        guard reader.exists(at: jsonURL) else {
            throw SampleDataError.missingJSON
        }

        return try reader.read(SampleDataDTO.self, from: jsonURL)
    }
}
