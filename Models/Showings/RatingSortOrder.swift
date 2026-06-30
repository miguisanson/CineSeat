import Foundation

// shared rating order for movie concert and seminar lists
enum RatingSortOrder: Int, Codable {
    case highestFirst
    case lowestFirst

    var title: String {
        switch self {
        case .highestFirst: return "Highest First"
        case .lowestFirst: return "Lowest First"
        }
    }
}
