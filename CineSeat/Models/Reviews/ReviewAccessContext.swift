import Foundation

// review writing is only available when the screen came from booking detail
enum ReviewAccessContext: Equatable {
    case readOnly
    case booking(Booking)

    var booking: Booking? {
        guard case .booking(let booking) = self else { return nil }
        return booking
    }
}
