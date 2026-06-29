import Foundation

// module 6 nested event schedule
// each event date can contain one or more available times
struct EventSchedule: Codable, Equatable, Identifiable {
    let id: String
    let date: Date
    let times: [EventTime]

    var displayDate: String {
        CineSeatDateFormatters.displayDate.string(from: date)
    }

    var displayDateWithTitle: String {
        "\(CineSeatDateFormatters.relativeDateTitle(for: date)) - \(displayDate)"
    }
}
