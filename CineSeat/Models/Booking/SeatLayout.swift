import Foundation

// module 6 layout model
// seat ui reads this instead of assuming every cinema has the same grid
struct SeatRow: Codable, Equatable {
    let label: String
    let seatNumbers: [Int]

    func seatID(for number: Int) -> String {
        "\(label)\(number)"
    }
}

struct SeatLayout: Codable, Equatable {
    let name: String
    let rows: [SeatRow]
    let aisleAfterSeatNumbers: Set<Int>
    let reservedSeats: Set<String>
    let unavailableSeats: Set<String>

    var allSeatIDs: [String] {
        rows.flatMap { row in
            row.seatNumbers.map { row.seatID(for: $0) }
        }
    }

    func containsSeat(_ seat: String) -> Bool {
        allSeatIDs.contains(seat)
    }

    func isSelectable(_ seat: String) -> Bool {
        containsSeat(seat) &&
            !reservedSeats.contains(seat) &&
            !unavailableSeats.contains(seat)
    }

    static func layout(forCinemaID id: Int, type: CinemaType) -> SeatLayout {
        SeatLayoutStore.shared.layout(forCinemaID: id, type: type)
    }
}
