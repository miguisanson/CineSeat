import Foundation

// module 5 shared json writer
// repositories use this so filemanager logic stays in one small place
final class JSONFileWriter {
    private let fileManager: FileManager
    private let encoder: JSONEncoder

    init(
        fileManager: FileManager = .default,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.fileManager = fileManager
        self.encoder = encoder
    }

    func write<T: Encodable>(_ value: T, to url: URL) throws {
        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }
}
