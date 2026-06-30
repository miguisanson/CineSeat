import Foundation

// module 2 review editor viewmodel
// save and delete always include the signed-in profile id
final class ReviewEditorViewModel {
    let subject: ReviewSubject
    let author: UserProfile
    private(set) var existingReview: Review?

    private let manageReviewsUseCase: ManageReviewsUseCase

    init(
        subject: ReviewSubject,
        author: UserProfile,
        existingReview: Review?,
        manageReviewsUseCase: ManageReviewsUseCase
    ) {
        self.subject = subject
        self.author = author
        self.existingReview = existingReview
        self.manageReviewsUseCase = manageReviewsUseCase
    }

    var pageTitle: String { existingReview == nil ? "Write Review" : "Edit Review" }
    var initialRating: Int { Int(existingReview?.rating ?? 5) }
    var initialComment: String { existingReview?.comment ?? "" }
    var canDelete: Bool { existingReview != nil }

    @discardableResult
    func save(rating: Int, comment: String) throws -> Review {
        let review = try manageReviewsUseCase.save(
            subject: subject,
            author: author,
            rating: Double(rating),
            comment: comment
        )
        existingReview = review
        return review
    }

    @discardableResult
    func delete() throws -> Bool {
        guard let existingReview else { throw ReviewError.reviewNotFound }
        return try manageReviewsUseCase.delete(
            reviewID: existingReview.id,
            authorProfileID: author.id
        )
    }
}
