import Foundation

// module 5 booking persistence contract
// filemanager writes and reads booking json through this protocol
protocol BookingPersisting {
    func loadBookings() throws -> [Booking]
    func saveBookings(_ bookings: [Booking]) throws
}

// module 5 filemanager repository
// bookings are saved as codable json in the documents directory
final class BookingFileRepository: BookingPersisting {
    private let fileManager: FileManager
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileManager: FileManager = .default,
        directoryURL: URL? = nil,
        fileName: String = "bookings.json"
    ) {
        self.fileManager = fileManager

        let documentsDirectory = directoryURL ?? fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        fileURL = documentsDirectory.appendingPathComponent(fileName)

        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder = JSONDecoder()
    }

    func loadBookings() throws -> [Booking] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([Booking].self, from: data)
    }

    func saveBookings(_ bookings: [Booking]) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        let data = try encoder.encode(bookings)
        try data.write(to: fileURL, options: .atomic)
    }
}

// module 5 userdefaults preferences
// this stores small settings like selected filter and cancelled booking visibility
final class AppPreferences: AppPreferencesManaging {
    static let shared = AppPreferences()

    private enum Key {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let selectedMovieCategory = "selectedMovieCategory"
        static let showCancelledBookings = "showCancelledBookings"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [Key.showCancelledBookings: true])
    }

    var hasLaunchedBefore: Bool {
        get { defaults.bool(forKey: Key.hasLaunchedBefore) }
        set { defaults.set(newValue, forKey: Key.hasLaunchedBefore) }
    }

    var selectedMovieCategory: MovieCategory {
        get {
            MovieCategory(rawValue: defaults.integer(forKey: Key.selectedMovieCategory)) ?? .all
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.selectedMovieCategory)
        }
    }

    var showCancelledBookings: Bool {
        get { defaults.bool(forKey: Key.showCancelledBookings) }
        set { defaults.set(newValue, forKey: Key.showCancelledBookings) }
    }
}
