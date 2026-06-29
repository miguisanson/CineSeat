import Foundation

// module 5 seed data entry point
// the actual seed values live in separate json files instead of swift arrays
enum SeedData {
    static var cinemas: [Cinema] {
        store.cinemas
    }

    static var movies: [Movie] {
        store.movies
    }

    static var concerts: [EventListing] {
        store.concerts
    }

    static var seminars: [EventListing] {
        store.seminars
    }

    static var eventVenues: [EventVenue] {
        store.eventVenues
    }

    static var eventShowings: [EventShowing] {
        store.eventShowings
    }

    static var showings: [MovieShowing] {
        store.showings
    }

    static var seedBookingIDs: Set<String> {
        Set(store.bookings.map(\.id))
    }

    static var bookings: [Booking] {
        store.bookings
    }

    static var profileAccounts: [SeedProfileAccount] {
        store.profileAccounts
    }

    static var profiles: [UserProfile] {
        profileAccounts.map(\.profile)
    }

    static func showings(for movie: Movie) -> [MovieShowing] {
        showings.filter { $0.movieTitle == movie.title }
    }

    static func events(for category: EventCategory) -> [EventListing] {
        switch category {
        case .concert:
            return concerts
        case .seminar:
            return seminars
        }
    }

    static func eventShowings(for event: EventListing) -> [EventShowing] {
        eventShowings.filter { $0.eventID == event.id }
    }

    static func events(at venue: EventVenue) -> [EventListing] {
        let eventIDs = Set(eventShowings.compactMap { showing -> String? in
            showing.allTimes.contains { $0.time.venue.id == venue.id } ? showing.eventID : nil
        })
        return (concerts + seminars).filter { eventIDs.contains($0.id) }
    }

    private static let store = SeedDataStore.load()
}
