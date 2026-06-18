import Foundation

// module 2 rating sort options
// movies viewmodel applies this after search and category filtering
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
