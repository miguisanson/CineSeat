import Foundation

// write-side review use case
// the store enforces one review per account and subject
final class DefaultManageReviewsUseCase: ManageReviewsUseCase {
    private let reviewManager: ReviewManaging

    init(reviewManager: ReviewManaging) {
        self.reviewManager = reviewManager
    }

    var didChangeNotification: Notification.Name {
        reviewManager.didChangeNotification
    }

    func review(for subject: ReviewSubject, authorProfileID: UUID) -> Review? {
        reviewManager.fetchReviews().first {
            $0.subjectID == subject.id &&
                $0.contentType == subject.contentType &&
                $0.authorProfileID == authorProfileID
        }
    }

    @discardableResult
    func save(
        subject: ReviewSubject,
        author: UserProfile,
        rating: Double,
        comment: String
    ) throws -> Review {
        try reviewManager.saveReview(
            subject: subject,
            author: author,
            rating: rating,
            comment: comment
        )
    }

    @discardableResult
    func delete(reviewID: String, authorProfileID: UUID) throws -> Bool {
        try reviewManager.deleteReview(id: reviewID, authorProfileID: authorProfileID)
    }

    @discardableResult
    func clearAll() -> Int {
        reviewManager.clearReviews()
    }
}
