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
        switch id {
        case 1:
            return standardNorth
        case 2:
            return standardEast
        case 3:
            return standardMain
        case 4:
            return standardSouth
        case 5:
            return standardCity
        case 6:
            return standardGarden
        case 7:
            return vipLounge
        case 8:
            return vipDirectorsClub
        default:
            return type == .vip ? vipLounge : standardMain
        }
    }

    private static func rows(_ labels: String, seats: ClosedRange<Int>) -> [SeatRow] {
        labels.map { SeatRow(label: String($0), seatNumbers: Array(seats)) }
    }

    private static let standardNorth = SeatLayout(
        name: "standard north hall",
        rows: rows("ABCDEFG", seats: 1...8),
        aisleAfterSeatNumbers: [4],
        reservedSeats: ["A2", "A3", "B5", "C1", "C2", "D4", "D5", "E6", "E7", "F3", "G1", "G2", "G3"],
        unavailableSeats: []
    )

    private static let standardEast = SeatLayout(
        name: "standard east hall",
        rows: rows("ABCDEF", seats: 1...9),
        aisleAfterSeatNumbers: [3, 6],
        reservedSeats: ["A4", "A5", "B2", "C8", "D1", "D2", "E6", "F7"],
        unavailableSeats: ["A9", "F1"]
    )

    private static let standardMain = SeatLayout(
        name: "standard main hall",
        rows: rows("ABCDEFGH", seats: 1...8),
        aisleAfterSeatNumbers: [4],
        reservedSeats: ["A2", "B6", "C3", "C4", "D7", "E1", "E2", "F5", "G8", "H3"],
        unavailableSeats: []
    )

    private static let standardSouth = SeatLayout(
        name: "standard south hall",
        rows: rows("ABCDEF", seats: 1...10),
        aisleAfterSeatNumbers: [5],
        reservedSeats: ["A1", "A2", "B5", "C6", "D3", "E9", "F4", "F5"],
        unavailableSeats: ["A10", "B10"]
    )

    private static let standardCity = SeatLayout(
        name: "standard city hall",
        rows: rows("ABCDE", seats: 1...8),
        aisleAfterSeatNumbers: [4],
        reservedSeats: ["A4", "B1", "B2", "C7", "D5", "E3"],
        unavailableSeats: ["A1", "A8"]
    )

    private static let standardGarden = SeatLayout(
        name: "standard garden hall",
        rows: rows("ABCDEFG", seats: 1...7),
        aisleAfterSeatNumbers: [3],
        reservedSeats: ["A3", "B4", "C1", "C2", "D7", "E5", "F6"],
        unavailableSeats: ["G1", "G7"]
    )

    private static let vipLounge = SeatLayout(
        name: "vip lounge",
        rows: rows("ABCD", seats: 1...6),
        aisleAfterSeatNumbers: [3],
        reservedSeats: ["A2", "B5", "C1", "D6"],
        unavailableSeats: []
    )

    private static let vipDirectorsClub = SeatLayout(
        name: "vip directors club",
        rows: rows("ABC", seats: 1...8),
        aisleAfterSeatNumbers: [2, 6],
        reservedSeats: ["A4", "B1", "B8", "C5"],
        unavailableSeats: ["A1", "C8"]
    )
}
