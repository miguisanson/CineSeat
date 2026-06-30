import Foundation

// readable review validation and ownership errors
enum ReviewError: LocalizedError, Equatable {
    case invalidRating
    case commentTooShort
    case commentTooLong
    case reviewNotFound
    case notReviewOwner

    var errorDescription: String? {
        switch self {
        case .invalidRating:
            return "Choose a rating from 1 to 5."
        case .commentTooShort:
            return "Write at least 3 characters for the review."
        case .commentTooLong:
            return "Keep the review within 500 characters."
        case .reviewNotFound:
            return "The review could not be found."
        case .notReviewOwner:
            return "Only the account that wrote this review can change it."
        }
    }
}
