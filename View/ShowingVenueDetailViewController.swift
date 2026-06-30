import UIKit

// module 2 event venue details
// a map pin opens this list before the selected event detail
final class ShowingVenueDetailViewController: ScrollableViewController {
    var factory = AppFactory.shared
    var viewModel: ShowingVenueDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Venue Details"
        buildInterface()
    }

    private func buildInterface() {
        let titleLabel = UILabel()
        titleLabel.text = viewModel.venue.name
        titleLabel.font = CineSeatFont.pageTitleHeavy
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(CineSeatTheme.captionLabel(viewModel.venue.address))

        let mapView = LocationPreviewMapView()
        mapView.show(venue: viewModel.venue)
        contentStack.addArrangedSubview(mapView)
        contentStack.addArrangedSubview(CineSeatTheme.captionLabel(viewModel.countText))

        for (index, event) in viewModel.events.enumerated() {
            let button = UIButton(type: .system)
            var configuration = UIButton.Configuration.gray()
            configuration.title = event.title
            configuration.subtitle = "\(event.category.title) - \(event.eventType)"
            configuration.image = UIImage(systemName: event.category == .concert ? "music.mic" : "person.3.sequence")
            configuration.imagePadding = CineSeatSpacing.medium
            configuration.titleAlignment = .leading
            configuration.contentInsets = .init(top: 14, leading: 14, bottom: 14, trailing: 14)
            button.configuration = configuration
            button.tag = index
            button.contentHorizontalAlignment = .leading
            button.addTarget(self, action: #selector(eventTapped(_:)), for: .touchUpInside)
            contentStack.addArrangedSubview(button)
        }
    }

    @objc private func eventTapped(_ sender: UIButton) {
        guard viewModel.events.indices.contains(sender.tag) else { return }
        navigationController?.pushViewController(
            factory.makeTicketedShowingDetailViewController(listing: viewModel.event(at: sender.tag)),
            animated: true
        )
    }
}
