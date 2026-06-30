import Foundation

// shared app values
// keeping these here avoids random numbers being repeated in different screens
enum AppConstants {
    enum Brand {
        static let name = "TicketPlease"
    }

    enum Booking {
        static let idPrefix = "TP"
        static let defaultFee: Double = 35
        static let standardTicketPrice: Double = 350
        static let vipTicketPrice: Double = 550
        static let maximumEventTickets = 10
    }

    enum Notifications {
        static let reminderLeadTimes: [TimeInterval] = [
            3 * 60 * 60,
            2 * 60 * 60,
            1 * 60 * 60,
            30 * 60
        ]
        static let reminderIdentifierPrefix = "cineseat-reminder-"
        static let cancellationIdentifierPrefix = "cineseat-cancelled-"
        static let developerTestIdentifierPrefix = "cineseat-developer-test-"
        static let developerTestDelay: TimeInterval = 5
    }

    enum Reviews {
        static let fallbackShowingDuration: TimeInterval = 2 * 60 * 60
    }
}
