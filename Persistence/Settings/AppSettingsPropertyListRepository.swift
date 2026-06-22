import Foundation

// module 5 plist repository
// bundle plist seeds documents plist so settings can be edited and saved
final class AppSettingsPropertyListRepository {
    private let fileManager: FileManager
    private let bundle: Bundle
    private let directoryURL: URL
    private let fileName = "CineSeatSettings.plist"

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

    func loadSettings() throws -> AppSettings {
        if fileManager.fileExists(atPath: settingsURL.path) {
            return try decodeSettings(from: settingsURL)
        }

        let settings = try loadBundledDefaults()
        try saveSettings(settings)
        return settings
    }

    func saveSettings(_ settings: AppSettings) throws {
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        let data = try PropertyListEncoder.cineseat.encode(settings)
        try data.write(to: settingsURL, options: .atomic)
    }

    func resetSettings() throws -> AppSettings {
        let settings = try loadBundledDefaults()
        try saveSettings(settings)
        return settings
    }

    var settingsURL: URL {
        directoryURL.appendingPathComponent(fileName)
    }

    private func loadBundledDefaults() throws -> AppSettings {
        guard let url = bundle.url(forResource: "DefaultAppSettings", withExtension: "plist") else {
            return .defaults
        }
        return try decodeSettings(from: url)
    }

    private func decodeSettings(from url: URL) throws -> AppSettings {
        let data = try Data(contentsOf: url)
        return try PropertyListDecoder().decode(AppSettings.self, from: data)
    }
}

extension PropertyListEncoder {
    static var cineseat: PropertyListEncoder {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        return encoder
    }
}
