import Foundation

// module 1 error handling
// json catalog failures are kept readable during development
enum CatalogError: LocalizedError {
    case missingJSON(String)
    case missingCinema(Int)
    case missingEvent(String)
    case missingEventVenue(String)

    var errorDescription: String? {
        switch self {
        case .missingJSON(let name):
            return "\(name).json is missing from the app bundle"
        case .missingCinema(let id):
            return "Missing cinema in catalog json: \(id)"
        case .missingEvent(let id):
            return "Missing event in catalog json: \(id)"
        case .missingEventVenue(let id):
            return "Missing event venue in catalog json: \(id)"
        }
    }
}
