import Foundation

// read-side review use case
// online scores and local app averages remain separate
final class DefaultFetchReviewsUseCase: FetchReviewsUseCase {
    private let reviewFetcher: ReviewFetching

    init(reviewFetcher: ReviewFetching) {
        self.reviewFetcher = reviewFetcher
    }

    var didChangeNotification: Notification.Name {
        reviewFetcher.didChangeNotification
    }

    func execute(for subject: ReviewSubject) -> [Review] {
        reviewFetcher.fetchReviews()
            .filter { $0.subjectID == subject.id && $0.contentType == subject.contentType }
            .sorted { first, second in
                (first.updatedAt ?? first.createdAt) > (second.updatedAt ?? second.createdAt)
            }
    }

    func ratingSummary(for subject: ReviewSubject) -> ReviewRatingSummary {
        let reviews = execute(for: subject)
        let appRating = reviews.isEmpty ? nil : reviews.map(\.rating).reduce(0, +) / Double(reviews.count)
        return ReviewRatingSummary(
            onlineRating: subject.onlineRating,
            appRating: appRating,
            reviewCount: reviews.count
        )
    }
}
