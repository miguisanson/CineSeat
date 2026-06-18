import Foundation

// module 5 shared json reader
// filemanager owns file lookup while jsondecoder handles model conversion
final class JSONFileReader {
    private let fileManager: FileManager
    private let decoder: JSONDecoder

    init(
        fileManager: FileManager = .default,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.fileManager = fileManager
        self.decoder = decoder
    }

    func exists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }

    func read<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        guard let data = fileManager.contents(atPath: url.path) else {
            throw CocoaError(.fileReadNoSuchFile)
        }
        return try decoder.decode(type, from: data)
    }

    func bundledResourceURL(
        named name: String,
        extension fileExtension: String,
        bundle: Bundle = .main
    ) -> URL? {
        let bundles = [bundle, Bundle.main, Bundle(for: SampleDataBundleToken.self)]
        return bundles.compactMap {
            $0.url(forResource: name, withExtension: fileExtension)
        }.first
    }
}

final class SampleDataBundleToken {}
