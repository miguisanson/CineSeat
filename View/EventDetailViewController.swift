import UIKit

// module 2 event detail screen
// non-movie events are shown as information only in this build
final class EventDetailViewController: ScrollableViewController {
    var event: EventListing!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = event.category.title
        buildInterface()
    }

    private func buildInterface() {
        let posterView = PosterPlaceholderView()
        posterView.translatesAutoresizingMaskIntoConstraints = false
        posterView.heightAnchor.constraint(equalToConstant: CineSeatSize.posterDetailHeight).isActive = true
        posterView.loadPoster(from: event.posterURLString, localName: event.localPosterName)
        contentStack.addArrangedSubview(posterView)

        let titleLabel = UILabel()
        titleLabel.text = event.title
        titleLabel.font = CineSeatFont.pageTitleHeavy
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0
        contentStack.addArrangedSubview(titleLabel)

        let metadataLabel = UILabel()
        metadataLabel.text = "\(event.eventType) - \(event.venue)\n\(event.duration) - rating \(String(format: "%.1f", event.rating))"
        metadataLabel.font = CineSeatFont.metadata
        metadataLabel.textColor = CineSeatTheme.mutedText
        metadataLabel.numberOfLines = 0
        contentStack.addArrangedSubview(metadataLabel)

        let details = UIStackView()
        details.axis = .vertical
        details.spacing = CineSeatSpacing.small
        details.addArrangedSubview(CineSeatTheme.captionLabel("Details"))

        let summaryLabel = UILabel()
        summaryLabel.text = event.summary
        summaryLabel.font = CineSeatFont.body
        summaryLabel.textColor = CineSeatTheme.secondaryText
        summaryLabel.numberOfLines = 0
        details.addArrangedSubview(summaryLabel)

        details.addArrangedSubview(makeInfoRow(label: "Venue", value: event.venue))
        details.addArrangedSubview(makeInfoRow(label: "Status", value: event.statusText))
        contentStack.addArrangedSubview(makeCard(with: details))

        let noteLabel = CineSeatTheme.captionLabel("event browsing only - movie seat booking stays under movies")
        noteLabel.numberOfLines = 0
        contentStack.addArrangedSubview(noteLabel)
    }
}
