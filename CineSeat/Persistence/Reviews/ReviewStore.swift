import Foundation

// module 5 review storage service
// normal saves update one account review while developer testing can add more
final class ReviewStore: ReviewManaging {
    static let shared = ReviewStore(persistence: ReviewFileRepository())
    static let reviewsDidChange = Notification.Name("reviewsDidChange")

    private(set) var reviews: [Review]
    private let persistence: ReviewPersisting?

    var didChangeNotification: Notification.Name { Self.reviewsDidChange }

    init(reviews: [Review]? = nil, persistence: ReviewPersisting? = nil) {
        self.persistence = persistence
        if let reviews {
            self.reviews = reviews
        } else {
            self.reviews = (try? persistence?.loadReviews()) ?? []
        }
    }

    func fetchReviews() -> [Review] {
        reviews
    }

    @discardableResult
    func saveReview(
        subject: ReviewSubject,
        author: UserProfile,
        rating: Double,
        comment: String,
        existingReviewID: String?,
        allowsMultipleReviews: Bool
    ) throws -> Review {
        guard rating >= 1, rating <= 5 else { throw ReviewError.invalidRating }
        let cleanComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanComment.count >= 3 else { throw ReviewError.commentTooShort }
        guard cleanComment.count <= 500 else { throw ReviewError.commentTooLong }

        let now = Date()
        let reviewIndex: Int?
        if let existingReviewID {
            reviewIndex = reviews.firstIndex { review in
                review.id == existingReviewID &&
                    review.subjectID == subject.id &&
                    review.contentType == subject.contentType &&
                    review.authorProfileID == author.id
            }
            guard reviewIndex != nil else { throw ReviewError.reviewNotFound }
        } else if allowsMultipleReviews {
            reviewIndex = nil
        } else {
            reviewIndex = reviews.firstIndex { review in
                review.subjectID == subject.id &&
                    review.contentType == subject.contentType &&
                    review.authorProfileID == author.id
            }
        }

        if let index = reviewIndex {
            let current = reviews[index]
            reviews[index] = Review(
                id: current.id,
                subjectID: subject.id,
                contentType: subject.contentType,
                authorProfileID: author.id,
                authorName: author.fullName,
                rating: rating,
                comment: cleanComment,
                createdAt: current.createdAt,
                updatedAt: now
            )
            try saveChanges()
            return reviews[index]
        }

        let review = Review(
            id: UUID().uuidString,
            subjectID: subject.id,
            contentType: subject.contentType,
            authorProfileID: author.id,
            authorName: author.fullName,
            rating: rating,
            comment: cleanComment,
            createdAt: now,
            updatedAt: nil
        )
        reviews.insert(review, at: 0)
        try saveChanges()
        return review
    }

    @discardableResult
    func deleteReview(id: String, authorProfileID: UUID) throws -> Bool {
        guard let index = reviews.firstIndex(where: { $0.id == id }) else {
            throw ReviewError.reviewNotFound
        }
        guard reviews[index].authorProfileID == authorProfileID else {
            throw ReviewError.notReviewOwner
        }
        reviews.remove(at: index)
        try saveChanges()
        return true
    }

    @discardableResult
    func clearReviews() -> Int {
        let count = reviews.count
        reviews.removeAll()
        try? saveChanges()
        return count
    }

    private func saveChanges() throws {
        try persistence?.saveReviews(reviews)
        NotificationCenter.default.post(name: Self.reviewsDidChange, object: nil)
    }
}
