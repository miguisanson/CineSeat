import Foundation

// module 5 booking persistence contract
// filemanager writes and reads booking json through this protocol
protocol BookingPersisting {
    func loadBookings() throws -> [Booking]
    func saveBookings(_ bookings: [Booking]) throws
}
