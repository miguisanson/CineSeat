import Foundation

// module 5 filemanager repository
// user reviews are saved as json in the app documents directory
final class ReviewFileRepository: ReviewPersisting {
    private let fileURL: URL
    private let reader: JSONFileReader
    private let writer: JSONFileWriter

    init(
        fileManager: FileManager = .default,
        directoryURL: URL? = nil,
        fileName: String = "reviews.json"
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

    func loadReviews() throws -> [Review] {
        guard reader.exists(at: fileURL) else { return [] }
        return try reader.read([Review].self, from: fileURL)
    }

    func saveReviews(_ reviews: [Review]) throws {
        try writer.write(reviews, to: fileURL)
    }
}
