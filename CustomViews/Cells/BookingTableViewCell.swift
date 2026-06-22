import UIKit

// module 2 reusable booking cell
// bookings table uses this for saved booking rows
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
            statusLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 170),
            statusLabel.heightAnchor.constraint(equalToConstant: 21)
        ])
    }

    func configure(with booking: Booking) {
        titleLabel.text = booking.movie.title
        idLabel.text = booking.id
        statusLabel.text = booking.status.rawValue.uppercased()
        statusLabel.textColor = booking.status.isConfirmed ? .white : CineSeatTheme.secondaryText
        statusLabel.backgroundColor = booking.status.isConfirmed ? CineSeatTheme.primaryText : CineSeatTheme.border
        detailsLabel.text = "\(booking.dateSummary) - \(booking.showtime)\nSEATS  \(booking.seats.joined(separator: ", "))"
        totalLabel.text = CineSeatTheme.money(booking.total)
        isAccessibilityElement = true
        accessibilityIdentifier = "bookingCell_\(booking.id)"
        accessibilityLabel = "\(booking.movie.title), \(booking.status.rawValue), \(booking.seats.joined(separator: ", ")), \(CineSeatTheme.money(booking.total))"
        accessibilityTraits = .button
    }
}
