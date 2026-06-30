import Foundation

// module 6 review use case
// filtering and app-average calculation stay outside the screens
final class DefaultFetchReviewsUseCase: FetchReviewsUseCase {
    private let reviewFetcher: ReviewFetching

    init(reviewFetcher: ReviewFetching) {
        self.reviewFetcher = reviewFetcher
    }

    func execute(for subject: ReviewSubject) -> [Review] {
        reviewFetcher.fetchReviews()
            .filter { $0.subjectID == subject.id && $0.contentType == subject.contentType }
            .sorted { first, second in
                if first.daysAgo != second.daysAgo { return first.daysAgo < second.daysAgo }
                return first.likes > second.likes
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

final class MockReviewAPIClient: ReviewFetching {
    private let reviews: [Review]

    init(reviews: [Review]) {
        self.reviews = reviews
    }

    func fetchReviews() -> [Review] {
        reviews
    }
}
