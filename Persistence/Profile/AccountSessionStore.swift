import Foundation

// module 5 userdefaults session storage
// only the signed in profile id is stored here
final class AccountSessionStore {
    private let defaults: UserDefaults
    private let key = "signedInProfileID"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var signedInProfileID: UUID? {
        get {
            guard let value = defaults.string(forKey: key) else { return nil }
            return UUID(uuidString: value)
        }
        set {
            defaults.set(newValue?.uuidString, forKey: key)
        }
    }
}
