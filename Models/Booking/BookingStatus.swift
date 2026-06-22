import Foundation

// module 1 enum for booking state
// cancelled statuses are split so weather and technical issue are explainable
enum BookingStatus: String, Codable {
    case confirmed = "Confirmed"
    case cancelledByUser = "Cancelled by User"
    case cancelledWeather = "Cancelled - Weather"
    case cancelledTechnicalIssue = "Cancelled - Technical Issue"

    var isConfirmed: Bool {
        self == .confirmed
    }

    var isCancelled: Bool {
        !isConfirmed
    }

    static func cancelled(reason: BookingCancellationReason) -> BookingStatus {
        switch reason {
        case .user:
            return .cancelledByUser
        case .weather:
            return .cancelledWeather
        case .technicalIssue:
            return .cancelledTechnicalIssue
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case Self.confirmed.rawValue:
            self = .confirmed
        case "Cancelled", Self.cancelledByUser.rawValue:
            self = .cancelledByUser
        case Self.cancelledWeather.rawValue:
            self = .cancelledWeather
        case Self.cancelledTechnicalIssue.rawValue:
            self = .cancelledTechnicalIssue
        default:
            self = .cancelledByUser
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
