import UIKit

// module 2 concert list screen
// this controller receives only the concert list viewmodel
final class ConcertListViewController: TicketedShowingListViewController {
    var viewModel: ConcertListViewModel! {
        didSet { listViewModel = viewModel }
    }

    override func makeDetailViewController(for listing: EventListing) -> UIViewController {
        guard let concert = listing.concert else { return UIViewController() }
        return factory.makeConcertDetailViewController(concert: concert)
    }
}
