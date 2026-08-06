import Foundation

// online review contracts keep urlsession and tmdb details out of presentation
protocol OnlineReviewFetching {
    func fetchReviews(movieID: Int) async throws -> [OnlineReview]
}

protocol FetchOnlineReviewsUseCase {
    func execute(for subject: ReviewSubject) async throws -> [OnlineReview]
}
