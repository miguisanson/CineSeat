import Foundation

// review eligibility requires ownership of a confirmed ticket after its showing
// developer mode can bypass the rule only for local testing
final class DefaultCheckReviewEligibilityUseCase: CheckReviewEligibilityUseCase {
    private let bookingManager: BookingManaging
    private let settingsStore: AppSettingsManaging
    private let now: () -> Date

    init(
        bookingManager: BookingManaging,
        settingsStore: AppSettingsManaging,
        now: @escaping () -> Date = Date.init
    ) {
        self.bookingManager = bookingManager
        self.settingsStore = settingsStore
        self.now = now
    }

    func execute(subject: ReviewSubject, profile: UserProfile?) -> ReviewEligibility {
        guard let profile else {
            return ReviewEligibility(canReview: false, message: "Log in before writing a review.")
        }

        let settings = settingsStore.settings
        if settings.developerModeEnabled && settings.simulateReviewEligibility {
            return ReviewEligibility(canReview: true, message: "Developer Mode is simulating an attended booking.")
        }

        let matchingBookings = bookingManager.bookings.filter { booking in
            booking.status.isConfirmed &&
                booking.isVisible(to: profile.email) &&
                matches(booking: booking, subject: subject)
        }
        guard !matchingBookings.isEmpty else {
            return ReviewEligibility(canReview: false, message: "You can review this after booking one of its tickets.")
        }
        guard matchingBookings.contains(where: { $0.endsAt <= now() }) else {
            return ReviewEligibility(canReview: false, message: "You can review this after its booked showing has finished.")
        }
        return ReviewEligibility(canReview: true, message: "Your attended booking is eligible for one review.")
    }

    private func matches(booking: Booking, subject: ReviewSubject) -> Bool {
        switch booking.item {
        case .movie(let movie):
            return subject.contentType == .movie && movie.title == subject.id
        case .event(let event):
            return event.id == subject.id &&
                ((subject.contentType == .concert && event.category == .concert) ||
                    (subject.contentType == .seminar && event.category == .seminar))
        }
    }
}
