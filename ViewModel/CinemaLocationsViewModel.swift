import Foundation

// module 2 locations viewmodel
// map data stays outside the view controller for a cleaner tab feature
final class CinemaLocationsViewModel {
    private let cinemasSource: () -> [Cinema]

    init(cinemasSource: @escaping () -> [Cinema] = { SeedData.cinemas }) {
        self.cinemasSource = cinemasSource
    }

    var cinemas: [Cinema] {
        cinemasSource()
    }

    var cinemaCountText: String {
        "\(cinemas.count) CINEMA LOCATIONS"
    }

    var mappedCinemas: [Cinema] {
        cinemas.filter { $0.location != nil }
    }

    func cinema(id: Int) -> Cinema? {
        cinemas.first { $0.id == id }
    }
}
