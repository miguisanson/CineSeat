import UIKit

// module 2 seminar list screen
// this controller receives only the seminar list viewmodel
final class SeminarListViewController: TicketedShowingListViewController {
    var viewModel: SeminarListViewModel! {
        didSet { listViewModel = viewModel }
    }

    override func makeDetailViewController(for listing: EventListing) -> UIViewController {
        guard let seminar = listing.seminar else { return UIViewController() }
        return factory.makeSeminarDetailViewController(seminar: seminar)
    }
}
