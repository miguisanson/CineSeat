import Foundation

// module 5 userdefaults preferences
// this stores small settings like selected filter and cancelled booking visibility
final class AppPreferences: AppPreferencesManaging {
    static let shared = AppPreferences()

    private enum Key {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let selectedMovieCategory = "selectedMovieCategory"
        static let showCancelledBookings = "showCancelledBookings"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
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
        get { defaults.bool(forKey: Key.showCancelledBookings) }
        set { defaults.set(newValue, forKey: Key.showCancelledBookings) }
    }
}
