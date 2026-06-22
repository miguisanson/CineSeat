import Foundation

// module 5 filemanager repository
// bookings are saved as codable json in the documents directory
final class BookingFileRepository: BookingPersisting {
    private let fileURL: URL
    private let reader: JSONFileReader
    private let writer: JSONFileWriter

    init(
        fileManager: FileManager = .default,
        directoryURL: URL? = nil,
        fileName: String = "bookings.json"
    ) {
        let documentsDirectory = directoryURL ?? fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        fileURL = documentsDirectory.appendingPathComponent(fileName)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        reader = JSONFileReader(fileManager: fileManager, decoder: decoder)
        writer = JSONFileWriter(fileManager: fileManager, encoder: encoder)
    }

    func loadBookings() throws -> [Booking] {
        guard reader.exists(at: fileURL) else {
            return []
        }
        return try reader.read([Booking].self, from: fileURL)
    }

    func saveBookings(_ bookings: [Booking]) throws {
        try writer.write(bookings, to: fileURL)
    }
}
