import Foundation

// module 2 locations viewmodel
// map category and pin models stay outside the view controller
final class CinemaLocationsViewModel {
    private let cinemasSource: () -> [Cinema]
    private let eventVenuesSource: () -> [EventVenue]
    private(set) var selectedCategory: LocationCategory = .cinemas

    init(
        cinemasSource: @escaping () -> [Cinema] = { AppContent.cinemas },
        eventVenuesSource: @escaping () -> [EventVenue] = { AppContent.eventVenues }
    ) {
        self.cinemasSource = cinemasSource
        self.eventVenuesSource = eventVenuesSource
    }

    var categories: [LocationCategory] { LocationCategory.allCases }

    var titleText: String {
        selectedCategory == .cinemas ? "Cinema Locations" : "Event Venues"
    }

    var countText: String {
        "\(mapItems.count) \(selectedCategory.title.uppercased())"
    }

    var mapItems: [LocationMapItem] {
        switch selectedCategory {
        case .cinemas:
            return cinemasSource().filter { $0.location != nil }.map(LocationMapItem.cinema)
        case .eventVenues:
            return eventVenuesSource().map(LocationMapItem.eventVenue)
        }
    }

    func selectCategory(at index: Int) {
        selectedCategory = LocationCategory(rawValue: index) ?? .cinemas
    }

    func item(id: String) -> LocationMapItem? {
        mapItems.first { $0.id == id }
    }

    func cinema(id: Int) -> Cinema? {
        cinemasSource().first { $0.id == id }
    }
}
