import Foundation

// module 6 seat layout store
// seat ui asks this for layouts instead of using hard-coded cinema switches
final class SeatLayoutStore {
    static let shared = SeatLayoutStore()

    private let repository: SeatLayoutPropertyListRepository
    private lazy var database: SeatLayoutDatabase = {
        (try? repository.loadDatabase()) ?? Self.fallbackDatabase
    }()

    init(repository: SeatLayoutPropertyListRepository = SeatLayoutPropertyListRepository()) {
        self.repository = repository
    }

    func layout(forCinemaID id: Int, type: CinemaType) -> SeatLayout {
        database.layouts.first {
            $0.cinemaID == id && $0.type == type
        }?.layout ?? fallbackLayout(for: type)
    }

    var databaseVersion: String {
        database.version
    }

    var layoutCount: Int {
        database.layouts.count
    }

    var editableFilePath: String {
        repository.editableURL.path
    }

    private func fallbackLayout(for type: CinemaType) -> SeatLayout {
        database.layouts.first { $0.type == type }?.layout ??
            database.layouts.first?.layout ??
            Self.fallbackDatabase.layouts[0].layout
    }

    private static let fallbackDatabase = SeatLayoutDatabase(
        version: "fallback",
        layouts: [
            SeatLayoutRecord(
                cinemaID: 0,
                type: .standard,
                name: "fallback hall",
                rowLabels: "ABCDE",
                firstSeatNumber: 1,
                lastSeatNumber: 6,
                aisleAfterSeatNumbers: [3],
                reservedSeats: [],
                unavailableSeats: []
            )
        ]
    )
}
