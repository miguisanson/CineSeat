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

        titleLabel.font = CineSeatFont.bodyBold
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 2
        idLabel.font = CineSeatFont.status
        idLabel.textColor = CineSeatTheme.mutedText
        statusLabel.font = CineSeatFont.status
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = CineSeatRadius.medium
        statusLabel.clipsToBounds = true
        detailsLabel.font = CineSeatFont.metadata
        detailsLabel.textColor = CineSeatTheme.secondaryText
        detailsLabel.numberOfLines = 2
        totalLabel.font = CineSeatFont.button
        totalLabel.textColor = CineSeatTheme.primaryText
        totalLabel.textAlignment = .right
        totalLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), statusLabel])
        titleStack.axis = .horizontal
        titleStack.alignment = .center
        titleStack.spacing = CineSeatSpacing.regular
        let detailStack = UIStackView(arrangedSubviews: [detailsLabel, UIView(), totalLabel])
        detailStack.axis = .horizontal
        detailStack.alignment = .bottom
        detailStack.spacing = CineSeatSpacing.regular
        let stack = UIStackView(arrangedSubviews: [titleStack, idLabel, detailStack])
        stack.axis = .vertical
        stack.spacing = CineSeatSpacing.small
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: CineSeatSpacing.medium),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: CineSeatSpacing.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -CineSeatSpacing.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -CineSeatSpacing.medium),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 82),
            statusLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 170),
            statusLabel.heightAnchor.constraint(equalToConstant: CineSeatSize.statusHeight)
        ])
    }

    func configure(with booking: Booking) {
        titleLabel.text = booking.title
        idLabel.text = booking.id
        statusLabel.text = booking.status.rawValue.uppercased()
        statusLabel.textColor = booking.status.isConfirmed ? .white : CineSeatTheme.secondaryText
        statusLabel.backgroundColor = booking.status.isConfirmed ? CineSeatTheme.primaryText : CineSeatTheme.border
        let ticketText = booking.isMovieBooking
            ? booking.ticketIdentifiers.joined(separator: ", ")
            : "\(booking.ticketCount) ticket\(booking.ticketCount == 1 ? "" : "s")"
        detailsLabel.text = "\(booking.dateSummary) - \(booking.showtime)\n\(booking.locationName) - \(ticketText)"
        totalLabel.text = CineSeatTheme.money(booking.total)
        isAccessibilityElement = true
        accessibilityIdentifier = "bookingCell_\(booking.id)"
        accessibilityLabel = "\(booking.title), \(booking.status.rawValue), \(ticketText), \(CineSeatTheme.money(booking.total))"
        accessibilityTraits = .button
    }
}
