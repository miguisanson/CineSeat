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

    func execute(booking: Booking, subject: ReviewSubject, profile: UserProfile?) -> ReviewEligibility {
        guard let profile else {
            return ReviewEligibility(canReview: false, message: "Log in before writing a review.")
        }

        guard matches(booking: booking, subject: subject), booking.isVisible(to: profile.email) else {
            return ReviewEligibility(canReview: false, message: "This booking is not assigned to the signed-in account.")
        }

        let settings = settingsStore.settings
        if settings.developerModeEnabled && settings.reviewTestingEnabled {
            return ReviewEligibility(canReview: true, message: "Developer Mode allows repeated test reviews from this booking.")
        }

        guard let currentBooking = bookingManager.bookings.first(where: { $0.id == booking.id }),
              matches(booking: currentBooking, subject: subject),
              currentBooking.status.isConfirmed,
              currentBooking.isVisible(to: profile.email) else {
            return ReviewEligibility(canReview: false, message: "Only an active confirmed booking can be reviewed.")
        }
        guard currentBooking.startsAt <= now() else {
            return ReviewEligibility(
                canReview: false,
                message: "Writing opens after the booked showtime: \(currentBooking.dateSummary) at \(currentBooking.showtime)."
            )
        }
        return ReviewEligibility(canReview: true, message: "This booking is eligible for one review.")
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
