import Foundation

// module 6 settings store
// protocol users read this instead of touching the plist repository directly
final class AppSettingsStore: AppSettingsManaging {
    static let shared = AppSettingsStore()
    static let settingsDidChange = Notification.Name("settingsDidChange")

    private let repository: AppSettingsPropertyListRepository
    private(set) var settings: AppSettings

    var didChangeNotification: Notification.Name {
        Self.settingsDidChange
    }

    init(repository: AppSettingsPropertyListRepository = AppSettingsPropertyListRepository()) {
        self.repository = repository
        settings = (try? repository.loadSettings()) ?? .defaults
    }

    func updateSettings(_ settings: AppSettings) {
        self.settings = settings
        try? repository.saveSettings(settings)
        NotificationCenter.default.post(name: Self.settingsDidChange, object: nil)
    }

    func resetToDefaults() {
        settings = (try? repository.resetSettings()) ?? .defaults
        NotificationCenter.default.post(name: Self.settingsDidChange, object: nil)
    }

    var settingsFilePath: String {
        repository.settingsURL.path
    }
}
