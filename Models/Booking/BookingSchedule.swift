import Foundation

// selected booking schedule
// booking keeps date and time together instead of loose strings
struct BookingSchedule: Codable, Equatable {
    let date: Date
    let time: BookingTime

    var displayDate: String {
        CineSeatDateFormatters.displayDate.string(from: date)
    }

    var shortDisplayDate: String {
        CineSeatDateFormatters.relativeDateTitle(for: date)
    }

    var displayDateWithTitle: String {
        "\(shortDisplayDate) - \(displayDate)"
    }

    var showtime: String {
        time.showtime
    }

    var startsAt: Date {
        CineSeatDateFormatters.dateTime(date: date, timeText: time.showtime)
    }
}
