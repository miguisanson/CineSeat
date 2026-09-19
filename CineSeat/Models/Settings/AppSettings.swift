import Foundation

// module 5 plist model
// settings are small app preferences that are readable in a property list
struct AppSettings: Codable, Equatable {
    var showCancelledBookings: Bool
    var bookingRemindersEnabled: Bool
    var developerModeEnabled: Bool
    var reviewTestingEnabled: Bool
    var testNotificationsEnabled: Bool
    var settingsVersion: String

    private enum CodingKeys: String, CodingKey {
        case showCancelledBookings
        case bookingRemindersEnabled
        case developerModeEnabled
        case reviewTestingEnabled
        case simulateReviewEligibility
        case testNotificationsEnabled
        case settingsVersion
    }

    init(
        showCancelledBookings: Bool,
        bookingRemindersEnabled: Bool,
        developerModeEnabled: Bool,
        reviewTestingEnabled: Bool,
        testNotificationsEnabled: Bool,
        settingsVersion: String
    ) {
        self.showCancelledBookings = showCancelledBookings
        self.bookingRemindersEnabled = bookingRemindersEnabled
        self.developerModeEnabled = developerModeEnabled
        self.reviewTestingEnabled = reviewTestingEnabled
        self.testNotificationsEnabled = testNotificationsEnabled
        self.settingsVersion = settingsVersion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        showCancelledBookings = try container.decodeIfPresent(Bool.self, forKey: .showCancelledBookings) ?? true
        bookingRemindersEnabled = try container.decodeIfPresent(Bool.self, forKey: .bookingRemindersEnabled) ?? true
        developerModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .developerModeEnabled) ?? false
        reviewTestingEnabled = try container.decodeIfPresent(Bool.self, forKey: .reviewTestingEnabled)
            ?? container.decodeIfPresent(Bool.self, forKey: .simulateReviewEligibility)
            ?? false
        testNotificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .testNotificationsEnabled) ?? false
        settingsVersion = try container.decodeIfPresent(String.self, forKey: .settingsVersion) ?? "2026.07.01"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(showCancelledBookings, forKey: .showCancelledBookings)
        try container.encode(bookingRemindersEnabled, forKey: .bookingRemindersEnabled)
        try container.encode(developerModeEnabled, forKey: .developerModeEnabled)
        try container.encode(reviewTestingEnabled, forKey: .reviewTestingEnabled)
        try container.encode(testNotificationsEnabled, forKey: .testNotificationsEnabled)
        try container.encode(settingsVersion, forKey: .settingsVersion)
    }

    static let defaults = AppSettings(
        showCancelledBookings: true,
        bookingRemindersEnabled: true,
        developerModeEnabled: false,
        reviewTestingEnabled: false,
        testNotificationsEnabled: false,
        settingsVersion: "2026.07.01"
    )
}
