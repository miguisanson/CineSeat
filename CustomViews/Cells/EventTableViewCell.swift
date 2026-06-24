import UIKit

// module 2 reusable event cell
// event browsing has its own cell so movie booking labels stay simple
final class EventTableViewCell: UITableViewCell {
    static let reuseIdentifier = "EventTableViewCell"

    private let card = CardView()
    private let posterView = PosterPlaceholderView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let ratingLabel = UILabel()
    private let durationLabel = UILabel()
    private let statusLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterView.loadPoster(from: nil)
    }

    private func configureViews() {
        backgroundColor = .clear
        selectionStyle = .none

        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        posterView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(posterView)

        titleLabel.font = CineSeatFont.fieldButton
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 2

        detailLabel.font = CineSeatFont.metadata
        detailLabel.textColor = CineSeatTheme.mutedText
        detailLabel.numberOfLines = 2

        ratingLabel.font = CineSeatFont.metadata
        ratingLabel.textColor = CineSeatTheme.primaryText

        durationLabel.font = CineSeatFont.metadata
        durationLabel.textColor = CineSeatTheme.secondaryText

        statusLabel.font = CineSeatFont.caption
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.backgroundColor = CineSeatTheme.primaryText
        statusLabel.layer.cornerRadius = CineSeatRadius.small
        statusLabel.clipsToBounds = true

        let bottomRow = UIStackView(arrangedSubviews: [durationLabel, UIView(), statusLabel])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center

        let labels = UIStackView(arrangedSubviews: [titleLabel, detailLabel, ratingLabel, UIView(), bottomRow])
        labels.axis = .vertical
        labels.spacing = CineSeatSpacing.tiny
        labels.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(labels)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

            posterView.topAnchor.constraint(equalTo: card.topAnchor, constant: CineSeatSpacing.medium),
            posterView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: CineSeatSpacing.medium),
            posterView.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -CineSeatSpacing.medium),
            posterView.widthAnchor.constraint(equalToConstant: CineSeatSize.moviePosterWidth),
            posterView.heightAnchor.constraint(equalToConstant: CineSeatSize.moviePosterHeight),

            labels.topAnchor.constraint(equalTo: card.topAnchor, constant: CineSeatSpacing.medium),
            labels.leadingAnchor.constraint(equalTo: posterView.trailingAnchor, constant: CineSeatSpacing.medium),
            labels.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -CineSeatSpacing.medium),
            labels.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -CineSeatSpacing.medium),

            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: CineSeatSize.bookBadgeWidth),
            statusLabel.heightAnchor.constraint(equalToConstant: CineSeatSize.bookBadgeHeight)
        ])
    }

    func configure(with event: EventListing) {
        posterView.loadPoster(from: event.posterURLString, localName: event.localPosterName)
        titleLabel.text = event.title
        detailLabel.text = event.detailText
        ratingLabel.text = "\(String(repeating: "*", count: Int(event.rating.rounded())))  \(String(format: "%.1f", event.rating))"
        durationLabel.text = "TIME  \(event.duration)"
        statusLabel.text = event.statusText
        statusLabel.backgroundColor = event.isComingSoon ? CineSeatTheme.mutedText : CineSeatTheme.primaryText
        isAccessibilityElement = true
        accessibilityIdentifier = "eventCell_\(event.title)"
        accessibilityLabel = "\(event.title), \(event.eventType), \(event.venue)"
        accessibilityTraits = .button
    }
}
