import Foundation

final class MoviesViewModel {
    private let movies: [Movie]
    var searchText = ""
    var selectedCategory: MovieCategory = .all

    init(movies: [Movie] = SampleData.movies) {
        self.movies = movies
    }

    var filteredMovies: [Movie] {
        movies.filter { movie in
            let matchesSearch = searchText.isEmpty ||
                movie.title.localizedCaseInsensitiveContains(searchText) ||
                movie.genre.localizedCaseInsensitiveContains(searchText)

            let matchesCategory: Bool
            switch selectedCategory {
            case .all:
                matchesCategory = true
            case .nowPlaying:
                matchesCategory = movie.isNowPlaying
            case .comingSoon:
                matchesCategory = movie.isComingSoon
            case .topRated:
                matchesCategory = movie.rating >= 4.5
            }

            return matchesSearch && matchesCategory
        }
    }
}

final class SeatSelectionViewModel {
    let rows = Array("ABCDEFG").map(String.init)
    let seatsPerRow = 8
    let reservedSeats: Set<String> = [
        "A2", "A3", "B5", "C1", "C2", "D4", "D5",
        "E6", "E7", "F3", "G1", "G2", "G3"
    ]

    private(set) var selectedSeats: Set<String>
    let ticketPrice: Double

    init(selectedSeats: Set<String> = ["D2", "D3"], ticketPrice: Double = 14) {
        self.selectedSeats = selectedSeats.subtracting(reservedSeats)
        self.ticketPrice = ticketPrice
    }

    @discardableResult
    func toggleSeat(_ seat: String) -> Bool {
        guard !reservedSeats.contains(seat) else { return false }

        if selectedSeats.contains(seat) {
            selectedSeats.remove(seat)
        } else {
            selectedSeats.insert(seat)
        }
        return true
    }

    var sortedSelectedSeats: [String] {
        selectedSeats.sorted { first, second in
            let firstRow = first.first ?? "A"
            let secondRow = second.first ?? "A"
            if firstRow == secondRow {
                return Int(first.dropFirst()) ?? 0 < Int(second.dropFirst()) ?? 0
            }
            return firstRow < secondRow
        }
    }

    var total: Double {
        Double(selectedSeats.count) * ticketPrice
    }
}
