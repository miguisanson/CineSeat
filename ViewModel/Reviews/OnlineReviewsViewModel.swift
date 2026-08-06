import Foundation

// online review loading has its own state and never changes local app reviews
final class OnlineReviewsViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case unavailable(String)
    }

    let subject: ReviewSubject
    private let fetchOnlineReviewsUseCase: FetchOnlineReviewsUseCase

    private(set) var reviews: [OnlineReview] = []
    private(set) var state: State = .idle

    init(subject: ReviewSubject, fetchOnlineReviewsUseCase: FetchOnlineReviewsUseCase) {
        self.subject = subject
        self.fetchOnlineReviewsUseCase = fetchOnlineReviewsUseCase
    }

    var countText: String {
        let word = reviews.count == 1 ? "review" : "reviews"
        return "\(reviews.count) online \(word)"
    }

    var emptyStateText: String {
        switch state {
        case .idle, .loading:
            return "Loading online reviews..."
        case .loaded:
            return reviews.isEmpty ? "No online written reviews are available for this movie." : ""
        case .unavailable(let message):
            return message
        }
    }

    func load() async {
        guard state == .idle else { return }
        state = .loading
        do {
            reviews = try await fetchOnlineReviewsUseCase.execute(for: subject)
            state = .loaded
        } catch {
            reviews = []
            state = .unavailable(error.localizedDescription)
        }
    }
}
