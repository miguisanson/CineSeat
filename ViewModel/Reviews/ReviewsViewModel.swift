import Foundation

// module 2 reviews list viewmodel
// fetching eligibility and current-account ownership stay outside the screen
final class ReviewsViewModel {
    let subject: ReviewSubject

    private let fetchReviewsUseCase: FetchReviewsUseCase
    private let manageReviewsUseCase: ManageReviewsUseCase
    private let checkEligibilityUseCase: CheckReviewEligibilityUseCase
    private let authenticationService: Authenticating

    private(set) var reviews: [Review] = []
    private(set) var ratingSummary: ReviewRatingSummary

    init(
        subject: ReviewSubject,
        fetchReviewsUseCase: FetchReviewsUseCase,
        manageReviewsUseCase: ManageReviewsUseCase,
        checkEligibilityUseCase: CheckReviewEligibilityUseCase,
        authenticationService: Authenticating
    ) {
        self.subject = subject
        self.fetchReviewsUseCase = fetchReviewsUseCase
        self.manageReviewsUseCase = manageReviewsUseCase
        self.checkEligibilityUseCase = checkEligibilityUseCase
        self.authenticationService = authenticationService
        ratingSummary = fetchReviewsUseCase.ratingSummary(for: subject)
        reload()
    }

    var pageTitle: String { "Reviews" }
    var subjectTypeText: String { subject.contentType.title.uppercased() }
    var didChangeNotification: Notification.Name { manageReviewsUseCase.didChangeNotification }
    var currentProfile: UserProfile? { authenticationService.currentProfile }

    var currentUserReview: Review? {
        guard let profile = currentProfile else { return nil }
        return manageReviewsUseCase.review(for: subject, authorProfileID: profile.id)
    }

    var eligibility: ReviewEligibility {
        checkEligibilityUseCase.execute(subject: subject, profile: currentProfile)
    }

    var reviewActionTitle: String {
        currentUserReview == nil ? "Write a Review" : "Edit Your Review"
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
        review.authorProfileID == currentProfile?.id
    }
}
