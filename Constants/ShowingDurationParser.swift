import Foundation

// converts local content values such as 2h 30m into a duration used by review rules
enum ShowingDurationParser {
    static func timeInterval(from text: String) -> TimeInterval? {
        var hours = 0
        var minutes = 0
        var foundValue = false

        for component in text.lowercased().split(whereSeparator: { $0.isWhitespace }) {
            if component.hasSuffix("h"), let value = Int(component.dropLast()) {
                hours = value
                foundValue = true
            } else if component.hasSuffix("m"), let value = Int(component.dropLast()) {
                minutes = value
                foundValue = true
            }
        }

        guard foundValue else { return nil }
        return TimeInterval((hours * 60 + minutes) * 60)
    }
}
