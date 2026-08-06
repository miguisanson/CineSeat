import Foundation

// module 5 local json content
// bundled files initialize a writable Documents/LocalContent copy on first launch
struct LocalContentStore {
    private static let contentResourceNames = [
        "Cinemas",
        "Movies",
        "Concerts",
        "Seminars",
        "EventVenues",
        "EventShowings",
        "Showings"
    ]
    private static let metadataResourceName = "LocalContentMetadata"

    let cinemas: [Cinema]
    let movies: [Movie]
    let concerts: [EventListing]
    let seminars: [EventListing]
    let eventVenues: [EventVenue]
    let eventShowings: [EventShowing]
    let showings: [MovieShowing]

    static func load(
        fileManager: FileManager = .default,
        bundle: Bundle = .main,
        directoryURL: URL? = nil
    ) -> LocalContentStore {
        do {
            let documentsDirectory = directoryURL ?? fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first!
            let contentDirectory = documentsDirectory.appendingPathComponent("LocalContent", isDirectory: true)
            try synchronizeBundledContent(
                fileManager: fileManager,
                bundle: bundle,
                contentDirectory: contentDirectory
            )
            let dto = try loadContent(
                fileManager: fileManager,
                bundle: bundle,
                contentDirectory: contentDirectory
            )
            return try LocalContentMapper.makeStore(from: dto)
        } catch {
            fatalError("Could not load the local JSON content: \(error.localizedDescription)")
        }
    }

    private static func synchronizeBundledContent(
        fileManager: FileManager,
        bundle: Bundle,
        contentDirectory: URL
    ) throws {
        let reader = JSONFileReader(fileManager: fileManager)
        guard let bundledMetadataURL = reader.bundledResourceURL(
            named: metadataResourceName,
            extension: "json",
            bundle: bundle
        ) else {
            throw LocalContentError.missingJSON(metadataResourceName)
        }

        let bundledMetadata = try reader.read(LocalContentMetadata.self, from: bundledMetadataURL)
        let localMetadataURL = contentDirectory.appendingPathComponent("\(metadataResourceName).json")
        let localMetadata = try? reader.read(LocalContentMetadata.self, from: localMetadataURL)
        guard localMetadata != bundledMetadata else { return }

        if fileManager.fileExists(atPath: contentDirectory.path) {
            try fileManager.removeItem(at: contentDirectory)
        }
        try fileManager.createDirectory(at: contentDirectory, withIntermediateDirectories: true)

        for resourceName in contentResourceNames + [metadataResourceName] {
            guard let bundledURL = reader.bundledResourceURL(
                named: resourceName,
                extension: "json",
                bundle: bundle
            ) else {
                throw LocalContentError.missingJSON(resourceName)
            }
            let localURL = contentDirectory.appendingPathComponent("\(resourceName).json")
            try fileManager.copyItem(at: bundledURL, to: localURL)
        }
    }

    private static func loadContent(
        fileManager: FileManager,
        bundle: Bundle,
        contentDirectory: URL
    ) throws -> LocalContentDTO {
        let reader = JSONFileReader(fileManager: fileManager)
        return LocalContentDTO(
            cinemas: try read([Cinema].self, named: "Cinemas", reader: reader, fileManager: fileManager, bundle: bundle, directory: contentDirectory),
            movies: try read([Movie].self, named: "Movies", reader: reader, fileManager: fileManager, bundle: bundle, directory: contentDirectory),
            concerts: try read([Concert].self, named: "Concerts", reader: reader, fileManager: fileManager, bundle: bundle, directory: contentDirectory),
            seminars: try read([Seminar].self, named: "Seminars", reader: reader, fileManager: fileManager, bundle: bundle, directory: contentDirectory),
            eventVenues: try read([EventVenue].self, named: "EventVenues", reader: reader, fileManager: fileManager, bundle: bundle, directory: contentDirectory),
            eventShowings: try read([EventShowingDTO].self, named: "EventShowings", reader: reader, fileManager: fileManager, bundle: bundle, directory: contentDirectory),
            showings: try read([ShowingDTO].self, named: "Showings", reader: reader, fileManager: fileManager, bundle: bundle, directory: contentDirectory)
        )
    }

    private static func read<T: Decodable>(
        _ type: T.Type,
        named name: String,
        reader: JSONFileReader,
        fileManager: FileManager,
        bundle: Bundle,
        directory: URL
    ) throws -> T {
        let localURL = directory.appendingPathComponent("\(name).json")
        if !reader.exists(at: localURL) {
            guard let bundledURL = reader.bundledResourceURL(
                named: name,
                extension: "json",
                bundle: bundle
            ) else {
                throw LocalContentError.missingJSON(name)
            }
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            try fileManager.copyItem(at: bundledURL, to: localURL)
        }
        return try reader.read(type, from: localURL)
    }
}
