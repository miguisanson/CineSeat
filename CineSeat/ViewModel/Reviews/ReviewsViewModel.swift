import Foundation

// module 2 reviews list viewmodel
// fetching eligibility and current-account ownership stay outside the screen
final class ReviewsViewModel {
    let subject: ReviewSubject
    let accessContext: ReviewAccessContext

    private let fetchReviewsUseCase: FetchReviewsUseCase
    private let manageReviewsUseCase: ManageReviewsUseCase
    private let checkEligibilityUseCase: CheckReviewEligibilityUseCase
    private let authenticationService: Authenticating
    private let settingsStore: AppSettingsManaging

    private(set) var reviews: [Review] = []
    private(set) var ratingSummary: ReviewRatingSummary

    init(
        subject: ReviewSubject,
        accessContext: ReviewAccessContext,
        fetchReviewsUseCase: FetchReviewsUseCase,
        manageReviewsUseCase: ManageReviewsUseCase,
        checkEligibilityUseCase: CheckReviewEligibilityUseCase,
        authenticationService: Authenticating,
        settingsStore: AppSettingsManaging
    ) {
        self.subject = subject
        self.accessContext = accessContext
        self.fetchReviewsUseCase = fetchReviewsUseCase
        self.manageReviewsUseCase = manageReviewsUseCase
        self.checkEligibilityUseCase = checkEligibilityUseCase
        self.authenticationService = authenticationService
        self.settingsStore = settingsStore
        ratingSummary = fetchReviewsUseCase.ratingSummary(for: subject)
        reload()
    }

    var pageTitle: String { "Reviews" }
    var subjectTypeText: String { subject.contentType.title.uppercased() }
    var didChangeNotification: Notification.Name { manageReviewsUseCase.didChangeNotification }
    var currentProfile: UserProfile? { authenticationService.currentProfile }

    var currentUserReviews: [Review] {
        guard let profile = currentProfile else { return [] }
        return manageReviewsUseCase.reviews(for: subject, authorProfileID: profile.id)
    }

    var currentUserReview: Review? {
        currentUserReviews.first
    }

    var showsReviewAction: Bool {
        accessContext.booking != nil
    }

    var reviewTestingEnabled: Bool {
        let settings = settingsStore.settings
        return settings.developerModeEnabled && settings.reviewTestingEnabled
    }

    var reviewForAction: Review? {
        reviewTestingEnabled ? nil : currentUserReview
    }

    var eligibility: ReviewEligibility {
        guard let booking = accessContext.booking else {
            return ReviewEligibility(
                canReview: false,
                message: "Reviews can only be written from an eligible Booking Detail screen."
            )
        }
        return checkEligibilityUseCase.execute(booking: booking, subject: subject, profile: currentProfile)
    }

    var reviewActionTitle: String {
        if reviewTestingEnabled { return "Write Another Test Review" }
        return currentUserReview == nil ? "Write a Review" : "Edit Your Review"
    }

    var reviewCountText: String {
        let word = reviews.count == 1 ? "review" : "reviews"
        return "\(reviews.count) TicketPlease \(word)"
    }

    func reload() {
        reviews = fetchReviewsUseCase.execute(for: subject)
        ratingSummary = fetchReviewsUseCase.ratingSummary(for: subject)
    }

    func canEdit(_ review: Review) -> Bool {
        showsReviewAction && review.authorProfileID == currentProfile?.id
    }
}
