import UIKit

// reusable review row
// comments can wrap without forcing a fixed cell height
final class ReviewTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ReviewTableViewCell"

    private let card = CardView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let ratingLabel = UILabel()
    private let commentLabel = UILabel()
    private let likesLabel = UILabel()

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

        avatarLabel.font = CineSeatFont.bodyBold
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarLabel.backgroundColor = CineSeatTheme.primaryText
        avatarLabel.layer.cornerRadius = CineSeatSize.reviewAvatarSize / 2
        avatarLabel.clipsToBounds = true
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = CineSeatFont.bodyBold
        nameLabel.textColor = CineSeatTheme.primaryText
        dateLabel.font = CineSeatFont.metadata
        dateLabel.textColor = CineSeatTheme.mutedText
        ratingLabel.font = CineSeatFont.metadataSemibold
        ratingLabel.textColor = CineSeatTheme.primaryText
        commentLabel.font = CineSeatFont.body
        commentLabel.textColor = CineSeatTheme.secondaryText
        commentLabel.numberOfLines = 0
        likesLabel.font = CineSeatFont.metadata
        likesLabel.textColor = CineSeatTheme.mutedText

        let authorStack = UIStackView(arrangedSubviews: [nameLabel, dateLabel])
        authorStack.axis = .vertical
        authorStack.spacing = CineSeatSpacing.tiny

        let topRow = UIStackView(arrangedSubviews: [avatarLabel, authorStack, UIView(), ratingLabel])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = CineSeatSpacing.regular

        let content = UIStackView(arrangedSubviews: [topRow, commentLabel, likesLabel])
        content.axis = .vertical
        content.spacing = CineSeatSpacing.regular
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CineSeatSpacing.tiny),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CineSeatSpacing.tiny),

            avatarLabel.widthAnchor.constraint(equalToConstant: CineSeatSize.reviewAvatarSize),
            avatarLabel.heightAnchor.constraint(equalToConstant: CineSeatSize.reviewAvatarSize),

            content.topAnchor.constraint(equalTo: card.topAnchor, constant: CineSeatSpacing.cardPadding),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: CineSeatSpacing.cardPadding),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -CineSeatSpacing.cardPadding),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -CineSeatSpacing.cardPadding)
        ])
    }

    func configure(with review: Review) {
        avatarLabel.text = review.authorInitials
        nameLabel.text = review.authorName
        dateLabel.text = review.relativeDateText
        ratingLabel.text = "\(String(repeating: "*", count: Int(review.rating.rounded()))) \(String(format: "%.1f", review.rating))"
        commentLabel.text = review.comment
        likesLabel.text = "helpful \(review.likes)"
        isAccessibilityElement = true
        accessibilityIdentifier = "review_\(review.id)"
        accessibilityLabel = "\(review.authorName), rated \(review.rating), \(review.comment)"
    }
}
