import Foundation

// module 5 json mapper
// ids in json are connected to full app models here
enum SeedDataMapper {
    static func makeStore(from dto: SeedDataDTO) throws -> SeedDataStore {
        let cinemaByID = Dictionary(uniqueKeysWithValues: dto.cinemas.map { ($0.id, $0) })
        let movieByTitle = Dictionary(uniqueKeysWithValues: dto.movies.map { ($0.title, $0) })
        let concerts = dto.concerts.map(EventListing.concert)
        let seminars = dto.seminars.map(EventListing.seminar)
        let eventByID = Dictionary(uniqueKeysWithValues: (concerts + seminars).map { ($0.id, $0) })
        let eventVenueByID = Dictionary(uniqueKeysWithValues: dto.eventVenues.map { ($0.id, $0) })

        let mappedEventShowings = try dto.eventShowings.map { showing -> EventShowing in
            guard eventByID[showing.eventID] != nil else {
                throw SeedDataError.missingEvent(showing.eventID)
            }

            let schedules = try showing.schedules.map { schedule -> EventSchedule in
                let times = try schedule.times.map { time -> EventTime in
                    guard let venue = eventVenueByID[time.venueID] else {
                        throw SeedDataError.missingEventVenue(time.venueID)
                    }
                    return EventTime(
                        id: time.id,
                        showtime: time.time,
                        venue: venue,
                        ticketPrice: time.ticketPrice,
                        capacity: time.capacity
                    )
                }

                return EventSchedule(
                    id: schedule.id,
                    date: CineSeatDateFormatters.dateFromToday(daysFromToday: schedule.daysFromToday),
                    times: times
                )
            }

            return EventShowing(id: showing.id, eventID: showing.eventID, schedules: schedules)
        }

        let mappedShowings = try dto.showings.map { showing -> MovieShowing in
            let schedules = try showing.schedules.map { schedule -> ShowingSchedule in
                let times = try schedule.times.map { time -> ShowingTime in
                    guard let cinema = cinemaByID[time.cinemaID] else {
                        throw SeedDataError.missingCinema(time.cinemaID)
                    }
                    return ShowingTime(
                        id: time.id,
                        showtime: time.time,
                        cinema: cinema
                    )
                }

                return ShowingSchedule(
                    id: schedule.id,
                    date: CineSeatDateFormatters.dateFromToday(daysFromToday: schedule.daysFromToday),
                    times: times
                )
            }

            return MovieShowing(
                id: showing.id,
                movieTitle: showing.movieTitle,
                schedules: schedules
            )
        }

        let mappedBookings = try dto.bookings.map { booking -> Booking in
            guard let movie = movieByTitle[booking.movieTitle] else {
                throw SeedDataError.missingMovie(booking.movieTitle)
            }
            guard let cinema = cinemaByID[booking.schedule.time.cinemaID] else {
                throw SeedDataError.missingCinema(booking.schedule.time.cinemaID)
            }
            return Booking(
                id: booking.id ?? BookingNumberFormatter.makeID(sequence: booking.idSeed ?? 1),
                movie: movie,
                schedule: BookingSchedule(
                    date: CineSeatDateFormatters.dateFromToday(daysFromToday: booking.schedule.daysFromToday),
                    time: BookingTime(
                        id: booking.schedule.time.id,
                        showtime: booking.schedule.time.time
                    )
                ),
                cinema: cinema.name,
                cinemaID: cinema.id,
                seats: booking.seats,
                ticketPrice: cinema.ticketPrice,
                bookingFee: booking.bookingFee,
                status: booking.status,
                ownerEmail: booking.ownerEmail,
                ownerName: booking.ownerName,
                ticketAssignments: booking.ticketAssignments ?? []
            )
        }

        let mappedAccounts = dto.profileAccounts.map {
            SeedProfileAccount(profile: $0.profile, password: $0.password)
        }

        return SeedDataStore(
            cinemas: dto.cinemas,
            movies: dto.movies,
            concerts: concerts,
            seminars: seminars,
            eventVenues: dto.eventVenues,
            eventShowings: mappedEventShowings,
            showings: mappedShowings,
            bookings: mappedBookings,
            profileAccounts: mappedAccounts
        )
    }
}
