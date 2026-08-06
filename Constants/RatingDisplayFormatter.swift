import Foundation

// every visible rating uses one decimal place and the same maximum value
enum RatingDisplayFormatter {
    static let maximumRating = 5.0

    static func text(for rating: Double) -> String {
        let clampedRating = min(maximumRating, max(0, rating))
        return String(format: "%.1f / %.1f", clampedRating, maximumRating)
    }

    static func sourcedText(for rating: Double, source: String) -> String {
        guard rating > 0 else { return "Not rated yet" }
        return "\(source) \(text(for: rating))"
    }
}
