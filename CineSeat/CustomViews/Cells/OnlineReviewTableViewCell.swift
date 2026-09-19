import UIKit

// tmdb review rows are visually separate from TicketPlease review rows
final class OnlineReviewTableViewCell: UITableViewCell {
    static let reuseIdentifier = "OnlineReviewTableViewCell"

    private let card = CardView()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let ratingLabel = UILabel()
    private let commentLabel = UILabel()
    private let sourceLabel = CineSeatTheme.captionLabel("TMDB - TAP TO OPEN SOURCE")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }

    private func configureViews() {
        backgroundColor = .clear
        selectionStyle = .none
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        authorLabel.font = CineSeatFont.bodyBold
        authorLabel.textColor = CineSeatTheme.primaryText
        dateLabel.font = CineSeatFont.metadata
        dateLabel.textColor = CineSeatTheme.mutedText
        ratingLabel.font = CineSeatFont.metadataSemibold
        ratingLabel.textColor = CineSeatTheme.primaryText
        commentLabel.font = CineSeatFont.body
        commentLabel.textColor = CineSeatTheme.secondaryText
        commentLabel.numberOfLines = 0

        let authorStack = UIStackView(arrangedSubviews: [authorLabel, dateLabel])
        authorStack.axis = .vertical
        authorStack.spacing = CineSeatSpacing.tiny
        let topRow = UIStackView(arrangedSubviews: [authorStack, UIView(), ratingLabel])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = CineSeatSpacing.regular

        let content = UIStackView(arrangedSubviews: [topRow, commentLabel, sourceLabel])
        content.axis = .vertical
        content.spacing = CineSeatSpacing.regular
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CineSeatSpacing.tiny),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CineSeatSpacing.tiny),
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: CineSeatSpacing.cardPadding),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: CineSeatSpacing.cardPadding),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -CineSeatSpacing.cardPadding),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -CineSeatSpacing.cardPadding)
        ])
    }

    func configure(with review: OnlineReview) {
        authorLabel.text = review.authorName
        dateLabel.text = review.createdAt.map(CineSeatDateFormatters.displayDate.string) ?? "Date unavailable"
        ratingLabel.text = review.rating.map { RatingDisplayFormatter.text(for: $0) } ?? "Not rated yet"
        commentLabel.text = review.content
        sourceLabel.isHidden = review.sourceURL == nil
        isAccessibilityElement = true
        accessibilityIdentifier = "onlineReview_\(review.id)"
        let accessibilityRating = review.rating.map { RatingDisplayFormatter.text(for: $0) } ?? "not rated yet"
        accessibilityLabel = "Online review by \(review.authorName), \(accessibilityRating), \(review.content)"
    }
}
