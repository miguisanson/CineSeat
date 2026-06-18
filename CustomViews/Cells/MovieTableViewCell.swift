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

        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 2
        detailLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        detailLabel.textColor = CineSeatTheme.mutedText
        detailLabel.numberOfLines = 1
        ratingLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        ratingLabel.textColor = CineSeatTheme.primaryText
        durationLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        durationLabel.textColor = CineSeatTheme.secondaryText
        bookLabel.text = "BOOK"
        bookLabel.font = .monospacedSystemFont(ofSize: 10, weight: .bold)
        bookLabel.textColor = .white
        bookLabel.textAlignment = .center
        bookLabel.backgroundColor = CineSeatTheme.primaryText
        bookLabel.layer.cornerRadius = 6
        bookLabel.clipsToBounds = true

        let bottomRow = UIStackView(arrangedSubviews: [durationLabel, UIView(), bookLabel])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        let labels = UIStackView(arrangedSubviews: [titleLabel, detailLabel, ratingLabel, UIView(), bottomRow])
        labels.axis = .vertical
        labels.spacing = 4
        labels.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(labels)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            posterView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            posterView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            posterView.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),
            posterView.widthAnchor.constraint(equalToConstant: 68),
            posterView.heightAnchor.constraint(equalToConstant: 92),
            labels.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            labels.leadingAnchor.constraint(equalTo: posterView.trailingAnchor, constant: 12),
            labels.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            labels.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            bookLabel.widthAnchor.constraint(equalToConstant: 62),
            bookLabel.heightAnchor.constraint(equalToConstant: 26)
        ])
    }

    func configure(with movie: Movie) {
        posterView.loadPoster(from: movie.posterURLString, localName: movie.localPosterName)
        titleLabel.text = movie.title
        detailLabel.text = movie.genre
        ratingLabel.text = "\(String(repeating: "*", count: Int(movie.rating.rounded())))  \(String(format: "%.1f", movie.rating))"
        durationLabel.text = "TIME  \(movie.duration)"
        bookLabel.text = movie.isComingSoon ? "SOON" : "BOOK"
        bookLabel.backgroundColor = movie.isComingSoon ? CineSeatTheme.mutedText : CineSeatTheme.primaryText
        isAccessibilityElement = true
        accessibilityIdentifier = "movieCell_\(movie.title)"
        accessibilityLabel = "\(movie.title), \(movie.genre), rating \(movie.rating), duration \(movie.duration)"
        accessibilityTraits = .button
    }
}
