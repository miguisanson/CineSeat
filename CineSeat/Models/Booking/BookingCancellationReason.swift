import Foundation

// cancellation reasons used by status and local notifications
enum BookingCancellationReason: String, Codable {
    case user = "User Request"
    case weather = "Weather"
    case technicalIssue = "Technical Issue"

    var notificationText: String {
        switch self {
        case .user:
            return "your request"
        case .weather:
            return "weather conditions"
        case .technicalIssue:
            return "a technical issue"
        }
    }
}
