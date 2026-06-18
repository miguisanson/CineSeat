import Foundation

// module 1 error handling
// json seed failures are kept readable during development
enum SampleDataError: LocalizedError {
    case missingJSON
    case missingMovie(String)
    case missingCinema(Int)

    var errorDescription: String? {
        switch self {
        case .missingJSON:
            return "SampleDataJson.json is missing from the app bundle"
        case .missingMovie(let title):
            return "Missing movie in sample json: \(title)"
        case .missingCinema(let id):
            return "Missing cinema in sample json: \(id)"
        }
    }
}
