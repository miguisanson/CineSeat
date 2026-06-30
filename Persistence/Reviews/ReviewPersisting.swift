import Foundation

// review persistence contract stays beside its concrete file repository
// domain code receives ReviewManaging instead of this file detail
protocol ReviewPersisting {
    func loadReviews() throws -> [Review]
    func saveReviews(_ reviews: [Review]) throws
}
