import Foundation

// shared list contract used by the concert and seminar screens
// each concrete viewmodel still owns its own model array and filtering
protocol TicketedShowingListViewModeling: AnyObject {
    var title: String { get }
    var searchPlaceholder: String { get }
    var headerText: String { get }
    var venueFilterTitle: String { get }
    var availableVenues: [String] { get }
    var listings: [EventListing] { get }
    var searchText: String { get set }
    var selectedStatusFilter: ShowingStatusFilter { get set }
    var ratingSortButtonTitle: String { get }

    func selectVenue(_ venue: String?)
    func toggleRatingSortOrder()
    func ratingSummary(for listing: EventListing) -> ReviewRatingSummary
}
