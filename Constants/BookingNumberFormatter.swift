import Foundation

// booking number builder
// CS means CineSeat and the year comes from the current calendar year
enum BookingNumberFormatter {
    static func makeID(sequence: Int, date: Date = Date()) -> String {
        let year = CineSeatDateFormatters.calendar.component(.year, from: date)
        return "\(AppConstants.Booking.idPrefix)-\(year)-\(String(format: "%05d", sequence))"
    }

    static func sequence(from bookingID: String) -> Int? {
        Int(bookingID.split(separator: "-").last ?? "")
    }
}
