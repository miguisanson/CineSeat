import Foundation

// module 2 temporary event checkout data
// events use ticket quantity and do not create seat values
struct EventBookingDraft {
    let event: EventListing
    let schedule: BookingSchedule
    let venue: EventVenue
    let ticketPrice: Double
    var quantity: Int
    let bookingFee: Double = AppConstants.Booking.defaultFee

    init(
        event: EventListing,
        schedule: EventSchedule,
        time: EventTime,
        quantity: Int
    ) {
        self.event = event
        self.schedule = BookingSchedule(
            date: schedule.date,
            time: BookingTime(id: time.id, showtime: time.showtime)
        )
        venue = time.venue
        ticketPrice = time.ticketPrice
        self.quantity = quantity
    }

    var ticketIdentifiers: [String] {
        (1...max(quantity, 1)).map { "Ticket \($0)" }
    }

    var subtotal: Double {
        Double(quantity) * ticketPrice
    }

    var total: Double {
        subtotal + bookingFee
    }

    var dateSummary: String {
        schedule.displayDateWithTitle
    }

    var showtime: String {
        schedule.showtime
    }
}
