import UIKit

// module 2 event booking summary
// login and persistence use the same account and booking store as movies
final class EventBookingSummaryViewController: ScrollableViewController {
    var draft: EventBookingDraft!
    var factory = AppFactory.shared
    var confirmBookingUseCase: ConfirmEventBookingUseCase = DefaultConfirmEventBookingUseCase(
        bookingManager: BookingStore.shared
    )
    var authenticationService: Authenticating = AuthenticationService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Booking Summary"
        buildInterface()
    }

    private func buildInterface() {
        let titleLabel = UILabel()
        titleLabel.text = draft.event.title
        titleLabel.font = CineSeatFont.detailTitle
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0
        let heading = UIStackView(arrangedSubviews: [titleLabel, CineSeatTheme.captionLabel(draft.event.eventType)])
        heading.axis = .vertical
        heading.spacing = CineSeatSpacing.small
        contentStack.addArrangedSubview(makeCard(with: heading))

        let details = UIStackView()
        details.axis = .vertical
        details.addArrangedSubview(CineSeatTheme.captionLabel("Booking details"))
        details.addArrangedSubview(makeInfoRow(label: "Date", value: draft.dateSummary))
        details.addArrangedSubview(makeInfoRow(label: "Time", value: draft.showtime))
        details.addArrangedSubview(makeInfoRow(label: "Venue", value: "\(draft.venue.name)\n\(draft.venue.address)"))
        details.addArrangedSubview(makeInfoRow(label: "Tickets", value: "\(draft.quantity)"))
        details.addArrangedSubview(makeInfoRow(label: "Ticket price", value: "\(CineSeatTheme.money(draft.ticketPrice)) each"))
        contentStack.addArrangedSubview(makeCard(with: details))

        let price = UIStackView()
        price.axis = .vertical
        price.addArrangedSubview(makeInfoRow(label: "Subtotal", value: CineSeatTheme.money(draft.subtotal)))
        price.addArrangedSubview(makeInfoRow(label: "Booking fee", value: CineSeatTheme.money(draft.bookingFee)))
        price.addArrangedSubview(makeInfoRow(label: "Total", value: CineSeatTheme.money(draft.total)))
        contentStack.addArrangedSubview(makeCard(with: price))

        let confirmButton = CineSeatTheme.primaryButton(title: "Confirm Booking")
        confirmButton.addTarget(self, action: #selector(confirmTapped(_:)), for: .touchUpInside)
        contentStack.addArrangedSubview(confirmButton)

        let editButton = CineSeatTheme.secondaryButton(title: "Edit Tickets")
        editButton.addTarget(self, action: #selector(editTicketsTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(editButton)
    }

    @objc private func confirmTapped(_ sender: UIButton) {
        guard let currentProfile = authenticationService.currentProfile else {
            let alert = UIAlertController(
                title: "Log In Required",
                message: "Please log in or create an account before confirming your booking.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Log In", style: .default) { [weak self] _ in
                guard let self else { return }
                self.navigationController?.pushViewController(self.factory.makeLoginViewController(), animated: true)
            })
            present(alert, animated: true)
            return
        }

        sender.isEnabled = false
        let booking = confirmBookingUseCase.execute(draft: draft, owner: currentProfile)
        navigationController?.pushViewController(
            factory.makeConfirmationViewController(booking: booking),
            animated: true
        )
    }

    @objc private func editTicketsTapped() {
        navigationController?.popViewController(animated: true)
    }
}
