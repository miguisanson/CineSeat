import UIKit

// module 6 design layer
// shared colors, reusable cells, and layout helpers live here
enum CineSeatTheme {
    static let background = UIColor.white
    static let card = UIColor(white: 0.96, alpha: 1)
    static let border = UIColor(white: 0.84, alpha: 1)
    static let placeholder = UIColor(white: 0.79, alpha: 1)
    static let mutedText = UIColor(white: 0.58, alpha: 1)
    static let secondaryText = UIColor(white: 0.33, alpha: 1)
    static let primaryText = UIColor(white: 0.10, alpha: 1)
    static let reservedSeat = UIColor(white: 0.75, alpha: 1)

    static func money(_ value: Double) -> String {
        String(format: "₱%.2f", value)
    }

    static func captionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .monospacedSystemFont(ofSize: 10, weight: .medium)
        label.textColor = mutedText
        label.numberOfLines = 0
        return label
    }

    static func primaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title.uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
        button.backgroundColor = primaryText
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }

    static func secondaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title.uppercased(), for: .normal)
        button.setTitleColor(primaryText, for: .normal)
        button.titleLabel?.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
        button.backgroundColor = UIColor(white: 0.91, alpha: 1)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = border.cgColor
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }
}

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = CineSeatTheme.border
        appearance.stackedLayoutAppearance.selected.iconColor = CineSeatTheme.primaryText
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: CineSeatTheme.primaryText]
        appearance.stackedLayoutAppearance.normal.iconColor = CineSeatTheme.mutedText
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: CineSeatTheme.mutedText]
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

final class CardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = CineSeatTheme.card
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = CineSeatTheme.border.cgColor
    }
}

final class PosterPlaceholderView: UIView {
    private let imageView = UIImageView()
    private let iconView = UIImageView(image: UIImage(systemName: "photo"))
    private let titleLabel = CineSeatTheme.captionLabel("Poster")
    private var currentPosterID: String?
    private var task: URLSessionDataTask?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = CineSeatTheme.placeholder
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.69, alpha: 1).cgColor
        clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        addSubview(imageView)

        iconView.tintColor = CineSeatTheme.mutedText
        iconView.contentMode = .scaleAspectFit
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func loadPoster(from urlString: String?, localName: String? = nil) {
        task?.cancel()
        imageView.image = nil
        imageView.isHidden = true
        iconView.superview?.isHidden = false
        currentPosterID = localName ?? urlString

        if let localName,
           let image = bundledPoster(named: localName) {
            show(image, for: localName)
            return
        }

        guard let urlString,
              let url = URL(string: urlString) else {
            currentPosterID = nil
            return
        }

        currentPosterID = urlString

        if let cachedURL = cachedFileURL(for: url),
           let data = try? Data(contentsOf: cachedURL),
           let image = UIImage(data: data) {
            show(image, for: urlString)
            return
        }

        task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let image = UIImage(data: data) else {
                return
            }

            if let cachedURL = self.cachedFileURL(for: url) {
                try? data.write(to: cachedURL, options: .atomic)
            }

            DispatchQueue.main.async {
                self.show(image, for: urlString)
            }
        }
        task?.resume()
    }

    private func show(_ image: UIImage, for posterID: String) {
        guard currentPosterID == posterID else { return }
        imageView.image = image
        imageView.isHidden = false
        iconView.superview?.isHidden = true
    }

    private func bundledPoster(named fileName: String) -> UIImage? {
        guard let fileURL = Bundle.main.url(
            forResource: fileName,
            withExtension: nil,
            subdirectory: "PosterImages"
        ),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: data)
    }

    private func cachedFileURL(for url: URL) -> URL? {
        guard let cacheDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        let posterDirectory = cacheDirectory.appendingPathComponent("PosterCache", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: posterDirectory,
            withIntermediateDirectories: true
        )
        return posterDirectory.appendingPathComponent(url.lastPathComponent)
    }
}

class ScrollableViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CineSeatTheme.background

        if scrollView == nil {
            scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(scrollView)
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }

        if contentStack == nil {
            contentStack = UIStackView()
            contentStack.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(contentStack)
            NSLayoutConstraint.activate([
                contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
                contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
                contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
                contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20)
            ])
        }

        scrollView.alwaysBounceVertical = true
        contentStack.axis = .vertical
        contentStack.spacing = 12
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func makeCard(with stack: UIStackView, padding: CGFloat = 14) -> CardView {
        let card = CardView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -padding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -padding)
        ])
        return card
    }

    func makeInfoRow(label: String, value: String) -> UIStackView {
        let labelView = CineSeatTheme.captionLabel(label)
        let valueView = UILabel()
        valueView.text = value
        valueView.textAlignment = .right
        valueView.font = .monospacedSystemFont(ofSize: 11, weight: .semibold)
        valueView.textColor = CineSeatTheme.primaryText
        valueView.numberOfLines = 0
        valueView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [labelView, valueView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = .init(top: 7, leading: 0, bottom: 7, trailing: 0)
        return row
    }
}

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

final class BookingTableViewCell: UITableViewCell {
    static let reuseIdentifier = "BookingTableViewCell"

    private let card = CardView()
    private let titleLabel = UILabel()
    private let idLabel = UILabel()
    private let statusLabel = UILabel()
    private let detailsLabel = UILabel()
    private let totalLabel = UILabel()

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

        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 2
        idLabel.font = .monospacedSystemFont(ofSize: 9, weight: .regular)
        idLabel.textColor = CineSeatTheme.mutedText
        statusLabel.font = .monospacedSystemFont(ofSize: 9, weight: .bold)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 10
        statusLabel.clipsToBounds = true
        detailsLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        detailsLabel.textColor = CineSeatTheme.secondaryText
        detailsLabel.numberOfLines = 2
        totalLabel.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
        totalLabel.textColor = CineSeatTheme.primaryText
        totalLabel.textAlignment = .right
        totalLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), statusLabel])
        titleStack.axis = .horizontal
        titleStack.alignment = .center
        titleStack.spacing = 8
        let detailStack = UIStackView(arrangedSubviews: [detailsLabel, UIView(), totalLabel])
        detailStack.axis = .horizontal
        detailStack.alignment = .bottom
        detailStack.spacing = 8
        let stack = UIStackView(arrangedSubviews: [titleStack, idLabel, detailStack])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 82),
            statusLabel.heightAnchor.constraint(equalToConstant: 21)
        ])
    }

    func configure(with booking: Booking) {
        titleLabel.text = booking.movie.title
        idLabel.text = booking.id
        statusLabel.text = booking.status.rawValue.uppercased()
        statusLabel.textColor = booking.status == .confirmed ? .white : CineSeatTheme.secondaryText
        statusLabel.backgroundColor = booking.status == .confirmed ? CineSeatTheme.primaryText : CineSeatTheme.border
        detailsLabel.text = "\(booking.date) - \(booking.showtime)\nSEATS  \(booking.seats.joined(separator: ", "))"
        totalLabel.text = CineSeatTheme.money(booking.total)
        isAccessibilityElement = true
        accessibilityIdentifier = "bookingCell_\(booking.id)"
        accessibilityLabel = "\(booking.movie.title), \(booking.status.rawValue), \(booking.seats.joined(separator: ", ")), \(CineSeatTheme.money(booking.total))"
        accessibilityTraits = .button
    }
}
