import Foundation

// module 5 json mapper
// ids in json are connected to full app models here
enum SampleDataMapper {
    static func makeStore(from dto: SampleDataDTO) throws -> SampleDataStore {
        let cinemaByID = Dictionary(uniqueKeysWithValues: dto.cinemas.map { ($0.id, $0) })
        let movieByTitle = Dictionary(uniqueKeysWithValues: dto.movies.map { ($0.title, $0) })

        let mappedShowings = try dto.showings.map { showing -> MovieShowing in
            guard let cinema = cinemaByID[showing.cinemaID] else {
                throw SampleDataError.missingCinema(showing.cinemaID)
            }
            return MovieShowing(
                id: showing.id,
                movieTitle: showing.movieTitle,
                dateTitle: showing.dateTitle,
                date: showing.date,
                showtime: showing.showtime,
                cinema: cinema
            )
        }

        let mappedBookings = try dto.bookings.map { booking -> Booking in
            guard let movie = movieByTitle[booking.movieTitle] else {
                throw SampleDataError.missingMovie(booking.movieTitle)
            }
            guard let cinema = cinemaByID[booking.cinemaID] else {
                throw SampleDataError.missingCinema(booking.cinemaID)
            }
            return Booking(
                id: booking.id,
                movie: movie,
                date: booking.date,
                showtime: booking.showtime,
                cinema: cinema.name,
                cinemaID: cinema.id,
                seats: booking.seats,
                ticketPrice: cinema.ticketPrice,
                bookingFee: booking.bookingFee,
                status: booking.status
            )
        }

        let mappedAccounts = dto.profileAccounts.map {
            SampleProfileAccount(profile: $0.profile, password: $0.password)
        }

        return SampleDataStore(
            cinemas: dto.cinemas,
            movies: dto.movies,
            showings: mappedShowings,
            bookings: mappedBookings,
            profileAccounts: mappedAccounts
        )
    }
}
