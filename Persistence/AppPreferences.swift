import Foundation

// module 5 userdefaults preferences
// plist handles app settings while userdefaults keeps tiny navigation flags
final class AppPreferences: AppPreferencesManaging {
    static let shared = AppPreferences(settingsStore: AppSettingsStore.shared)

    private enum Key {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let selectedMovieCategory = "selectedMovieCategory"
        static let showCancelledBookings = "showCancelledBookings"
    }

    private let defaults: UserDefaults
    private let settingsStore: AppSettingsManaging?

    init(defaults: UserDefaults = .standard, settingsStore: AppSettingsManaging? = nil) {
        self.defaults = defaults
        self.settingsStore = settingsStore
        defaults.register(defaults: [Key.showCancelledBookings: true])
    }

    var hasLaunchedBefore: Bool {
        get { defaults.bool(forKey: Key.hasLaunchedBefore) }
        set { defaults.set(newValue, forKey: Key.hasLaunchedBefore) }
    }

    var selectedMovieCategory: MovieCategory {
        get {
            MovieCategory(rawValue: defaults.integer(forKey: Key.selectedMovieCategory)) ?? .all
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.selectedMovieCategory)
        }
    }

    var showCancelledBookings: Bool {
        get {
            settingsStore?.settings.showCancelledBookings ??
                defaults.bool(forKey: Key.showCancelledBookings)
        }
        set {
            if let settingsStore {
                var settings = settingsStore.settings
                settings.showCancelledBookings = newValue
                settingsStore.updateSettings(settings)
            } else {
                defaults.set(newValue, forKey: Key.showCancelledBookings)
            }
        }
    }
}
