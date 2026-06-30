import UIKit

// module 2 reusable movie cell
// table view uses this for the movies screen
final class MovieTableViewCell: UITableViewCell {
    static let reuseIdentifier = "MovieTableViewCell"

    private let card = CardView()
    private let posterView = PosterPlaceholderView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let ratingLabel = UILabel()
    private let durationLabel = UILabel()
    private let bookLabel = UILabel()

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
        detailLabel.numberOfLines = 1
        ratingLabel.font = CineSeatFont.metadata
        ratingLabel.textColor = CineSeatTheme.primaryText
        durationLabel.font = CineSeatFont.metadata
        durationLabel.textColor = CineSeatTheme.secondaryText
        bookLabel.text = "BOOK"
        bookLabel.font = CineSeatFont.caption
        bookLabel.textColor = .white
        bookLabel.textAlignment = .center
        bookLabel.backgroundColor = CineSeatTheme.primaryText
        bookLabel.layer.cornerRadius = CineSeatRadius.small
        bookLabel.clipsToBounds = true

        let bottomRow = UIStackView(arrangedSubviews: [durationLabel, UIView(), bookLabel])
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
            bookLabel.widthAnchor.constraint(equalToConstant: CineSeatSize.bookBadgeWidth),
            bookLabel.heightAnchor.constraint(equalToConstant: CineSeatSize.bookBadgeHeight)
        ])
    }

    func configure(with movie: Movie, ratingSummary: ReviewRatingSummary) {
        posterView.loadPoster(from: movie.posterURLString, localName: movie.localPosterName)
        titleLabel.text = movie.title
        detailLabel.text = movie.genre
        ratingLabel.text = "\(String(repeating: "*", count: Int(ratingSummary.effectiveRating.rounded())))  \(ratingSummary.compactText)"
        durationLabel.text = "TIME  \(movie.duration)"
        bookLabel.text = movie.isComingSoon ? "SOON" : "BOOK"
        bookLabel.backgroundColor = movie.isComingSoon ? CineSeatTheme.mutedText : CineSeatTheme.primaryText
        isAccessibilityElement = true
        accessibilityIdentifier = "movieCell_\(movie.title)"
        accessibilityLabel = "\(movie.title), \(movie.genre), \(ratingSummary.compactText), duration \(movie.duration)"
        accessibilityTraits = .button
    }
}
