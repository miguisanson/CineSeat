import Foundation

// online and TicketPlease ratings stay separate
// the app average is only the fallback when an online score is unavailable
struct ReviewRatingSummary: Equatable {
    let onlineRating: Double?
    let appRating: Double?
    let reviewCount: Int

    var effectiveRating: Double {
        onlineRating ?? appRating ?? 0
    }

    var effectiveSource: String {
        onlineRating == nil ? AppConstants.Brand.name : "Online"
    }

    var compactText: String {
        RatingDisplayFormatter.sourcedText(for: effectiveRating, source: effectiveSource)
    }
}
