import Foundation

// module 5 profile file repository
// this writes profile arrays as codable json
final class ProfileFileRepository: ProfilePersisting {
    private let fileURL: URL
    private let reader: JSONFileReader
    private let writer: JSONFileWriter

    init(
        fileManager: FileManager = .default,
        directoryURL: URL? = nil,
        fileName: String = "profiles.json"
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

    func loadProfiles() throws -> [UserProfile] {
        guard reader.exists(at: fileURL) else { return [] }
        return try reader.read([UserProfile].self, from: fileURL)
    }

    func saveProfiles(_ profiles: [UserProfile]) throws {
        try writer.write(profiles, to: fileURL)
    }
}
