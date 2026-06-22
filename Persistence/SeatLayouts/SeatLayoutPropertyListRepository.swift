import Foundation

// module 5 plist dto
// this matches SeatLayouts.plist and maps into SeatLayout models
struct SeatLayoutDatabase: Codable, Equatable {
    let version: String
    let layouts: [SeatLayoutRecord]
}

struct SeatLayoutRecord: Codable, Equatable {
    let cinemaID: Int
    let type: CinemaType
    let name: String
    let rowLabels: String
    let firstSeatNumber: Int
    let lastSeatNumber: Int
    let aisleAfterSeatNumbers: [Int]
    let reservedSeats: [String]
    let unavailableSeats: [String]

    var layout: SeatLayout {
        SeatLayout(
            name: name,
            rows: rowLabels.map {
                SeatRow(
                    label: String($0),
                    seatNumbers: Array(firstSeatNumber...lastSeatNumber)
                )
            },
            aisleAfterSeatNumbers: Set(aisleAfterSeatNumbers),
            reservedSeats: Set(reservedSeats),
            unavailableSeats: Set(unavailableSeats)
        )
    }
}

// module 5 filemanager plist reader
// documents copy can be replaced later without changing seat ui code
final class SeatLayoutPropertyListRepository {
    private let fileManager: FileManager
    private let bundle: Bundle
    private let directoryURL: URL
    private let fileName = "SeatLayouts.plist"

    init(
        fileManager: FileManager = .default,
        bundle: Bundle = .main,
        directoryURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.bundle = bundle
        self.directoryURL = directoryURL ?? fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
    }

    func loadDatabase() throws -> SeatLayoutDatabase {
        try prepareEditableCopyIfNeeded()
        let data = try Data(contentsOf: editableURL)
        return try PropertyListDecoder().decode(SeatLayoutDatabase.self, from: data)
    }

    var editableURL: URL {
        directoryURL.appendingPathComponent(fileName)
    }

    private func prepareEditableCopyIfNeeded() throws {
        guard !fileManager.fileExists(atPath: editableURL.path) else { return }
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        if let bundledURL = bundle.url(forResource: "SeatLayouts", withExtension: "plist") {
            try fileManager.copyItem(at: bundledURL, to: editableURL)
        } else {
            let data = try PropertyListEncoder.cineseat.encode(Self.fallbackDatabase)
            try data.write(to: editableURL, options: .atomic)
        }
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
