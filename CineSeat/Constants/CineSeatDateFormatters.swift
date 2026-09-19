import Foundation

// date helpers used by schedules and bookings
// the json uses days from today so dates stay current when the app is opened
enum CineSeatDateFormatters {
    static let calendar = Calendar.current

    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE d"
        return formatter
    }()

    private static let displayDateWithYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMMM d yyyy"
        return formatter
    }()

    private static let inputTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static func dateFromToday(daysFromToday: Int, now: Date = Date()) -> Date {
        let startOfToday = calendar.startOfDay(for: now)
        return calendar.date(byAdding: .day, value: daysFromToday, to: startOfToday) ?? startOfToday
    }

    static func relativeDateTitle(for date: Date, now: Date = Date()) -> String {
        let today = calendar.startOfDay(for: now)
        let targetDay = calendar.startOfDay(for: date)
        let dayCount = calendar.dateComponents([.day], from: today, to: targetDay).day ?? 0

        switch dayCount {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        case let days where days > 1:
            return "In \(days) Days"
        default:
            return shortDate.string(from: date)
        }
    }

    static func date(fromDisplayText text: String, now: Date = Date()) -> Date {
        let currentYear = calendar.component(.year, from: now)
        return displayDateWithYear.date(from: "\(text) \(currentYear)") ?? calendar.startOfDay(for: now)
    }

    static func dateTime(date: Date, timeText: String) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        guard let parsedTime = inputTime.date(from: timeText) else {
            return startOfDay
        }

        let parts = calendar.dateComponents([.hour, .minute], from: parsedTime)
        return calendar.date(
            bySettingHour: parts.hour ?? 0,
            minute: parts.minute ?? 0,
            second: 0,
            of: startOfDay
        ) ?? startOfDay
    }

    static func isSameDay(_ firstDate: Date, _ secondDate: Date) -> Bool {
        calendar.isDate(firstDate, inSameDayAs: secondDate)
    }
}
