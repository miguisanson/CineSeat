import Foundation

// only movie subjects currently have a supported online written-review source
final class DefaultFetchOnlineReviewsUseCase: FetchOnlineReviewsUseCase {
    private let onlineReviewFetcher: OnlineReviewFetching

    init(onlineReviewFetcher: OnlineReviewFetching) {
        self.onlineReviewFetcher = onlineReviewFetcher
    }

    func execute(for subject: ReviewSubject) async throws -> [OnlineReview] {
        guard subject.contentType == .movie, let movieID = subject.tmdbMovieID else {
            throw OnlineReviewError.unavailableForContent
        }
        return try await onlineReviewFetcher.fetchReviews(movieID: movieID)
    }
}
