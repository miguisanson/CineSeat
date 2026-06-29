import Foundation

// module 1 error handling
// json seed failures are kept readable during development
enum SeedDataError: LocalizedError {
    case missingJSON(String)
    case missingMovie(String)
    case missingCinema(Int)
    case missingEvent(String)
    case missingEventVenue(String)

    var errorDescription: String? {
        switch self {
        case .missingJSON(let name):
            return "\(name).json is missing from the app bundle"
        case .missingMovie(let title):
            return "Missing movie in seed json: \(title)"
        case .missingCinema(let id):
            return "Missing cinema in seed json: \(id)"
        case .missingEvent(let id):
            return "Missing event in seed json: \(id)"
        case .missingEventVenue(let id):
            return "Missing event venue in seed json: \(id)"
        }
    }
}
