import Foundation

// module 6 nested schedule model
// one movie showing can have many dates and each date can have time options
struct ShowingSchedule: Codable, Equatable, Identifiable {
    let id: String
    let date: Date
    let times: [ShowingTime]

    var displayDate: String {
        CineSeatDateFormatters.displayDate.string(from: date)
    }

    var shortDisplayDate: String {
        CineSeatDateFormatters.relativeDateTitle(for: date)
    }

    var displayDateWithTitle: String {
        "\(shortDisplayDate) - \(displayDate)"
    }
}
