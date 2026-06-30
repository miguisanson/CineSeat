import Foundation

// module 6 review contract
// the viewmodels do not know whether reviews came from json or an api
protocol ReviewFetching {
    var didChangeNotification: Notification.Name { get }
    func fetchReviews() -> [Review]
}

protocol ReviewManaging: ReviewFetching {
    @discardableResult
    func saveReview(
        subject: ReviewSubject,
        author: UserProfile,
        rating: Double,
        comment: String
    ) throws -> Review

    @discardableResult
    func deleteReview(id: String, authorProfileID: UUID) throws -> Bool

    @discardableResult
    func clearReviews() -> Int
}

protocol FetchReviewsUseCase {
    var didChangeNotification: Notification.Name { get }
    func execute(for subject: ReviewSubject) -> [Review]
    func ratingSummary(for subject: ReviewSubject) -> ReviewRatingSummary
}

protocol ManageReviewsUseCase {
    var didChangeNotification: Notification.Name { get }
    func review(for subject: ReviewSubject, authorProfileID: UUID) -> Review?

    @discardableResult
    func save(
        subject: ReviewSubject,
        author: UserProfile,
        rating: Double,
        comment: String
    ) throws -> Review

    @discardableResult
    func delete(reviewID: String, authorProfileID: UUID) throws -> Bool

    @discardableResult
    func clearAll() -> Int
}

struct ReviewEligibility: Equatable {
    let canReview: Bool
    let message: String
}

protocol CheckReviewEligibilityUseCase {
    func execute(subject: ReviewSubject, profile: UserProfile?) -> ReviewEligibility
}
