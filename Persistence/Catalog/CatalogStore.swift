import Foundation

// module 5 local json catalog
// bundled files initialize a writable Documents/Catalog copy on first launch
struct CatalogStore {
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
    ) -> CatalogStore {
        do {
            let documentsDirectory = directoryURL ?? fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first!
            let catalogDirectory = documentsDirectory.appendingPathComponent("Catalog", isDirectory: true)
            let dto = try loadCatalog(
                fileManager: fileManager,
                bundle: bundle,
                catalogDirectory: catalogDirectory
            )
            return try CatalogMapper.makeStore(from: dto)
        } catch {
            fatalError("Could not load the local JSON catalog: \(error.localizedDescription)")
        }
    }

    private static func loadCatalog(
        fileManager: FileManager,
        bundle: Bundle,
        catalogDirectory: URL
    ) throws -> CatalogDTO {
        let reader = JSONFileReader(fileManager: fileManager)
        return CatalogDTO(
            cinemas: try read([Cinema].self, named: "Cinemas", reader: reader, fileManager: fileManager, bundle: bundle, directory: catalogDirectory),
            movies: try read([Movie].self, named: "Movies", reader: reader, fileManager: fileManager, bundle: bundle, directory: catalogDirectory),
            concerts: try read([Concert].self, named: "Concerts", reader: reader, fileManager: fileManager, bundle: bundle, directory: catalogDirectory),
            seminars: try read([Seminar].self, named: "Seminars", reader: reader, fileManager: fileManager, bundle: bundle, directory: catalogDirectory),
            eventVenues: try read([EventVenue].self, named: "EventVenues", reader: reader, fileManager: fileManager, bundle: bundle, directory: catalogDirectory),
            eventShowings: try read([EventShowingDTO].self, named: "EventShowings", reader: reader, fileManager: fileManager, bundle: bundle, directory: catalogDirectory),
            showings: try read([ShowingDTO].self, named: "Showings", reader: reader, fileManager: fileManager, bundle: bundle, directory: catalogDirectory)
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
                throw CatalogError.missingJSON(name)
            }
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            try fileManager.copyItem(at: bundledURL, to: localURL)
        }
        return try reader.read(type, from: localURL)
    }
}
