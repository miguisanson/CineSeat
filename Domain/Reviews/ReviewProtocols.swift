import Foundation

// module 6 review contract
// the viewmodels do not know whether reviews came from json or an api
protocol ReviewFetching {
    func fetchReviews() -> [Review]
}

protocol FetchReviewsUseCase {
    func execute(for subject: ReviewSubject) -> [Review]
    func ratingSummary(for subject: ReviewSubject) -> ReviewRatingSummary
}
