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
        guard effectiveRating > 0 else { return "Not rated yet" }
        return "\(effectiveSource) \(String(format: "%.1f", effectiveRating))/5"
    }

    var appRatingText: String {
        guard let appRating else { return "No TicketPlease reviews yet" }
        let reviewWord = reviewCount == 1 ? "review" : "reviews"
        return "TicketPlease \(String(format: "%.1f", appRating))/5 from \(reviewCount) \(reviewWord)"
    }

    var onlineRatingText: String {
        guard let onlineRating else { return "Online rating unavailable" }
        return "Online \(String(format: "%.1f", onlineRating))/5"
    }
}
