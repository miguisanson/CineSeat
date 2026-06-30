import Foundation

// module 2 reviews viewmodel
// rating source and review ordering stay outside the view controller
final class ReviewsViewModel {
    let subject: ReviewSubject
    let reviews: [Review]
    let ratingSummary: ReviewRatingSummary

    init(subject: ReviewSubject, fetchReviewsUseCase: FetchReviewsUseCase) {
        self.subject = subject
        reviews = fetchReviewsUseCase.execute(for: subject)
        ratingSummary = fetchReviewsUseCase.ratingSummary(for: subject)
    }

    var pageTitle: String { "Reviews" }
    var subjectTypeText: String { subject.contentType.title.uppercased() }
    var reviewCountText: String {
        let word = reviews.count == 1 ? "review" : "reviews"
        return "\(reviews.count) TicketPlease \(word)"
    }
}
