import UIKit

// module 2 movie detail screen
// the user picks a fixed showing instead of choosing any cinema
final class MovieDetailViewController: ScrollableViewController {
    var movie: Movie!
    var factory = AppFactory.shared

    private lazy var scheduleViewModel = factory.makeMovieScheduleViewModel(movie: movie)
    // beginner-style showing button references like separate storyboard outlets
    // each showing already has the cinema assigned in sample data
    private var firstShowingButton: UIButton!
    private var secondShowingButton: UIButton!
    private var thirdShowingButton: UIButton!
    private let assignedCinemaLabel = UILabel()
    private var selectSeatsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movie Detail"
        buildInterface()
        updateShowingButtons()
    }

    private func buildInterface() {
        let poster = PosterPlaceholderView()
        poster.heightAnchor.constraint(equalToConstant: 220).isActive = true
        poster.loadPoster(from: movie.posterURLString, localName: movie.localPosterName)
        contentStack.addArrangedSubview(poster)

        let titleLabel = UILabel()
        titleLabel.text = movie.title
        titleLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textColor = CineSeatTheme.primaryText

        let metadataLabel = UILabel()
        metadataLabel.text = "\(movie.genre)  |  \(movie.duration)  |  ***** \(String(format: "%.1f", movie.rating))"
        metadataLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        metadataLabel.textColor = CineSeatTheme.mutedText
        metadataLabel.numberOfLines = 0

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(metadataLabel)

        let synopsisTitle = CineSeatTheme.captionLabel("Synopsis")
        let synopsisLabel = UILabel()
        synopsisLabel.text = movie.synopsis
        synopsisLabel.font = .systemFont(ofSize: 13)
        synopsisLabel.textColor = CineSeatTheme.secondaryText
        synopsisLabel.numberOfLines = 0
        let synopsisStack = UIStackView(arrangedSubviews: [synopsisTitle, synopsisLabel])
        synopsisStack.axis = .vertical
        synopsisStack.spacing = 7
        contentStack.addArrangedSubview(makeCard(with: synopsisStack))

        if movie.isComingSoon {
            let comingSoonLabel = UILabel()
            comingSoonLabel.text = "This movie is coming soon. You can view the details now, but seat booking opens when it moves to Now Playing."
            comingSoonLabel.font = .systemFont(ofSize: 13)
            comingSoonLabel.textColor = CineSeatTheme.secondaryText
            comingSoonLabel.textAlignment = .center
            comingSoonLabel.numberOfLines = 0
            contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [comingSoonLabel]), padding: 12))
        }

        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Select scheduled showing"))

        firstShowingButton = makeShowingButton(index: 0)
        secondShowingButton = makeShowingButton(index: 1)
        thirdShowingButton = makeShowingButton(index: 2)

        let showingsStack = UIStackView(arrangedSubviews: [
            firstShowingButton,
            secondShowingButton,
            thirdShowingButton
        ])
        showingsStack.axis = .vertical
        showingsStack.spacing = 8
        contentStack.addArrangedSubview(showingsStack)

        assignedCinemaLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        assignedCinemaLabel.textColor = CineSeatTheme.secondaryText
        assignedCinemaLabel.numberOfLines = 0
        assignedCinemaLabel.textAlignment = .center
        contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [assignedCinemaLabel]), padding: 12))

        selectSeatsButton = CineSeatTheme.primaryButton(title: movie.isComingSoon ? "Coming Soon" : "Select Seats")
        selectSeatsButton.addTarget(self, action: #selector(selectSeatsTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(selectSeatsButton)
    }

    private func makeShowingButton(index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = index
        button.titleLabel?.font = .monospacedSystemFont(ofSize: 11, weight: .semibold)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.accessibilityIdentifier = "showingButton\(index + 1)"
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
        button.addTarget(self, action: #selector(showingTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func showingTapped(_ sender: UIButton) {
        scheduleViewModel.selectShowing(at: sender.tag)
        updateShowingButtons()
    }

    private func updateShowingButtons() {
        update(button: firstShowingButton, at: 0)
        update(button: secondShowingButton, at: 1)
        update(button: thirdShowingButton, at: 2)

        if let showing = scheduleViewModel.selectedShowing {
            assignedCinemaLabel.text = "assigned cinema: \(showing.cinema.name)\n\(showing.cinema.type.rawValue) ticket - \(CineSeatTheme.money(showing.ticketPrice))"
        } else {
            assignedCinemaLabel.text = "no bookable schedule yet"
        }

        let isBookingAvailable = scheduleViewModel.isBookingAvailable
        selectSeatsButton.isEnabled = isBookingAvailable
        selectSeatsButton.alpha = isBookingAvailable ? 1 : 0.45
        selectSeatsButton.setTitle(movie.isComingSoon ? "COMING SOON" : "SELECT SEATS", for: .normal)
    }

    private func update(button: UIButton?, at index: Int) {
        guard let showing = scheduleViewModel.showing(at: index) else {
            button?.isHidden = true
            return
        }

        let isSelected = scheduleViewModel.selectedShowing?.id == showing.id
        button?.isHidden = false
        button?.isEnabled = movie.isNowPlaying
        button?.alpha = movie.isNowPlaying ? 1 : 0.5
        button?.setTitle(showingButtonTitle(for: showing), for: .normal)
        button?.accessibilityLabel = "\(showing.dateTitle) \(showing.showtime), \(showing.cinema.name), \(showing.cinema.type.rawValue)"
        button?.backgroundColor = isSelected ? CineSeatTheme.primaryText : CineSeatTheme.card
        button?.setTitleColor(isSelected ? .white : CineSeatTheme.primaryText, for: .normal)
        button?.layer.borderColor = (isSelected ? CineSeatTheme.primaryText : CineSeatTheme.border).cgColor
    }

    private func showingButtonTitle(for showing: MovieShowing) -> String {
        "\(showing.dateTitle)  \(showing.showtime)\n\(showing.cinema.shortName) - \(showing.cinema.type.rawValue)\n\(CineSeatTheme.money(showing.ticketPrice))"
    }

    @objc private func selectSeatsTapped() {
        guard movie.isNowPlaying else {
            let alert = UIAlertController(
                title: "Coming Soon",
                message: "Seat booking opens when this movie moves to Now Playing.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        guard let draft = scheduleViewModel.makeDraft() else {
            let alert = UIAlertController(
                title: "No Showing",
                message: "There is no assigned cinema schedule available for this movie yet.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let seatViewController = factory.makeSeatSelectionViewController(draft: draft)
        navigationController?.pushViewController(seatViewController, animated: true)
    }
}

// module 2 seat selection screen
// seat buttons are connected one by one to show manual outlet style
final class SeatSelectionViewController: ScrollableViewController {
    var draft: BookingDraft!
    var factory = AppFactory.shared

    private lazy var viewModel = factory.makeSeatSelectionViewModel(ticketPrice: draft.ticketPrice)
    // beginner-style seat button references
    // this intentionally avoids a clean dictionary or outlet collection
    private var seatA1Button: UIButton!
    private var seatA2Button: UIButton!
    private var seatA3Button: UIButton!
    private var seatA4Button: UIButton!
    private var seatA5Button: UIButton!
    private var seatA6Button: UIButton!
    private var seatA7Button: UIButton!
    private var seatA8Button: UIButton!
    private var seatB1Button: UIButton!
    private var seatB2Button: UIButton!
    private var seatB3Button: UIButton!
    private var seatB4Button: UIButton!
    private var seatB5Button: UIButton!
    private var seatB6Button: UIButton!
    private var seatB7Button: UIButton!
    private var seatB8Button: UIButton!
    private var seatC1Button: UIButton!
    private var seatC2Button: UIButton!
    private var seatC3Button: UIButton!
    private var seatC4Button: UIButton!
    private var seatC5Button: UIButton!
    private var seatC6Button: UIButton!
    private var seatC7Button: UIButton!
    private var seatC8Button: UIButton!
    private var seatD1Button: UIButton!
    private var seatD2Button: UIButton!
    private var seatD3Button: UIButton!
    private var seatD4Button: UIButton!
    private var seatD5Button: UIButton!
    private var seatD6Button: UIButton!
    private var seatD7Button: UIButton!
    private var seatD8Button: UIButton!
    private var seatE1Button: UIButton!
    private var seatE2Button: UIButton!
    private var seatE3Button: UIButton!
    private var seatE4Button: UIButton!
    private var seatE5Button: UIButton!
    private var seatE6Button: UIButton!
    private var seatE7Button: UIButton!
    private var seatE8Button: UIButton!
    private var seatF1Button: UIButton!
    private var seatF2Button: UIButton!
    private var seatF3Button: UIButton!
    private var seatF4Button: UIButton!
    private var seatF5Button: UIButton!
    private var seatF6Button: UIButton!
    private var seatF7Button: UIButton!
    private var seatF8Button: UIButton!
    private var seatG1Button: UIButton!
    private var seatG2Button: UIButton!
    private var seatG3Button: UIButton!
    private var seatG4Button: UIButton!
    private var seatG5Button: UIButton!
    private var seatG6Button: UIButton!
    private var seatG7Button: UIButton!
    private var seatG8Button: UIButton!
    private let selectedSeatsLabel = UILabel()
    private let totalLabel = UILabel()
    private let continueButton = CineSeatTheme.primaryButton(title: "Continue")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Seats"
        buildInterface()
        updateSeatViews()
    }

    private func buildInterface() {
        let showtimeLabel = CineSeatTheme.captionLabel("\(draft.movie.title) - \(draft.cinema.name) - \(draft.showtime) - \(CineSeatTheme.money(draft.ticketPrice))")
        showtimeLabel.textAlignment = .center
        contentStack.addArrangedSubview(showtimeLabel)

        let screenView = UIView()
        screenView.backgroundColor = CineSeatTheme.mutedText
        screenView.layer.cornerRadius = 3
        screenView.translatesAutoresizingMaskIntoConstraints = false
        let screenContainer = UIView()
        screenContainer.addSubview(screenView)
        NSLayoutConstraint.activate([
            screenView.topAnchor.constraint(equalTo: screenContainer.topAnchor),
            screenView.centerXAnchor.constraint(equalTo: screenContainer.centerXAnchor),
            screenView.widthAnchor.constraint(equalTo: screenContainer.widthAnchor, multiplier: 0.82),
            screenView.heightAnchor.constraint(equalToConstant: 6),
            screenView.bottomAnchor.constraint(equalTo: screenContainer.bottomAnchor)
        ])
        contentStack.addArrangedSubview(screenContainer)
        let screenLabel = CineSeatTheme.captionLabel("Screen")
        screenLabel.textAlignment = .center
        contentStack.addArrangedSubview(screenLabel)

        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.spacing = 6
        gridStack.alignment = .center

        for row in viewModel.rows {
            gridStack.addArrangedSubview(makeSeatRow(row))
        }
        contentStack.addArrangedSubview(gridStack)

        let legendStack = UIStackView(arrangedSubviews: [
            makeLegendItem(title: "Available", color: CineSeatTheme.card),
            makeLegendItem(title: "Selected", color: CineSeatTheme.primaryText),
            makeLegendItem(title: "Reserved", color: CineSeatTheme.reservedSeat)
        ])
        legendStack.axis = .horizontal
        legendStack.distribution = .equalSpacing
        legendStack.alignment = .center
        contentStack.addArrangedSubview(makeCard(with: legendStack, padding: 12))

        selectedSeatsLabel.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        selectedSeatsLabel.textColor = CineSeatTheme.primaryText
        selectedSeatsLabel.textAlignment = .right
        totalLabel.font = .monospacedSystemFont(ofSize: 17, weight: .bold)
        totalLabel.textColor = CineSeatTheme.primaryText
        totalLabel.textAlignment = .right

        let summaryStack = UIStackView(arrangedSubviews: [
            makeSummaryRow(title: "Selected seats", valueLabel: selectedSeatsLabel),
            makeSummaryRow(title: "Total", valueLabel: totalLabel)
        ])
        summaryStack.axis = .vertical
        summaryStack.spacing = 4
        contentStack.addArrangedSubview(makeCard(with: summaryStack, padding: 12))

        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(continueButton)
    }

    private func makeSeatRow(_ row: String) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = traitCollection.horizontalSizeClass == .compact ? 3 : 4
        rowStack.alignment = .center

        let leadingLabel = makeRowLabel(row)
        rowStack.addArrangedSubview(leadingLabel)
        for number in 1...viewModel.seatsPerRow {
            if number == 5 {
                let aisle = UIView()
                let aisleWidth: CGFloat = traitCollection.horizontalSizeClass == .compact ? 6 : 8
                aisle.widthAnchor.constraint(equalToConstant: aisleWidth).isActive = true
                rowStack.addArrangedSubview(aisle)
            }

            let seat = "\(row)\(number)"
            let button = UIButton(type: .system)
            button.accessibilityIdentifier = seat
            button.accessibilityLabel = "Seat \(seat)"
            button.titleLabel?.font = .monospacedSystemFont(ofSize: 9, weight: .bold)
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            let seatSize: CGFloat = traitCollection.horizontalSizeClass == .compact ? 24 : 28
            button.widthAnchor.constraint(equalToConstant: seatSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: 25).isActive = true
            button.addTarget(self, action: #selector(seatTapped(_:)), for: .touchUpInside)
            connectSeatButton(button, toSeat: seat)
            rowStack.addArrangedSubview(button)
        }
        rowStack.addArrangedSubview(makeRowLabel(row))
        return rowStack
    }

    private func connectSeatButton(_ button: UIButton, toSeat seat: String) {
        switch seat {
        case "A1": seatA1Button = button
        case "A2": seatA2Button = button
        case "A3": seatA3Button = button
        case "A4": seatA4Button = button
        case "A5": seatA5Button = button
        case "A6": seatA6Button = button
        case "A7": seatA7Button = button
        case "A8": seatA8Button = button
        case "B1": seatB1Button = button
        case "B2": seatB2Button = button
        case "B3": seatB3Button = button
        case "B4": seatB4Button = button
        case "B5": seatB5Button = button
        case "B6": seatB6Button = button
        case "B7": seatB7Button = button
        case "B8": seatB8Button = button
        case "C1": seatC1Button = button
        case "C2": seatC2Button = button
        case "C3": seatC3Button = button
        case "C4": seatC4Button = button
        case "C5": seatC5Button = button
        case "C6": seatC6Button = button
        case "C7": seatC7Button = button
        case "C8": seatC8Button = button
        case "D1": seatD1Button = button
        case "D2": seatD2Button = button
        case "D3": seatD3Button = button
        case "D4": seatD4Button = button
        case "D5": seatD5Button = button
        case "D6": seatD6Button = button
        case "D7": seatD7Button = button
        case "D8": seatD8Button = button
        case "E1": seatE1Button = button
        case "E2": seatE2Button = button
        case "E3": seatE3Button = button
        case "E4": seatE4Button = button
        case "E5": seatE5Button = button
        case "E6": seatE6Button = button
        case "E7": seatE7Button = button
        case "E8": seatE8Button = button
        case "F1": seatF1Button = button
        case "F2": seatF2Button = button
        case "F3": seatF3Button = button
        case "F4": seatF4Button = button
        case "F5": seatF5Button = button
        case "F6": seatF6Button = button
        case "F7": seatF7Button = button
        case "F8": seatF8Button = button
        case "G1": seatG1Button = button
        case "G2": seatG2Button = button
        case "G3": seatG3Button = button
        case "G4": seatG4Button = button
        case "G5": seatG5Button = button
        case "G6": seatG6Button = button
        case "G7": seatG7Button = button
        case "G8": seatG8Button = button
        default: break
        }
    }

    private func makeRowLabel(_ row: String) -> UILabel {
        let label = CineSeatTheme.captionLabel(row)
        label.textAlignment = .center
        let labelWidth: CGFloat = traitCollection.horizontalSizeClass == .compact ? 12 : 14
        label.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        return label
    }

    private func makeLegendItem(title: String, color: UIColor) -> UIStackView {
        let square = UIView()
        square.backgroundColor = color
        square.layer.cornerRadius = 3
        square.layer.borderWidth = 1
        square.layer.borderColor = CineSeatTheme.border.cgColor
        square.widthAnchor.constraint(equalToConstant: 18).isActive = true
        square.heightAnchor.constraint(equalToConstant: 16).isActive = true

        let label = UILabel()
        label.text = title
        label.font = .monospacedSystemFont(ofSize: 9, weight: .regular)
        label.textColor = CineSeatTheme.secondaryText

        let stack = UIStackView(arrangedSubviews: [square, label])
        stack.axis = .horizontal
        stack.spacing = 5
        return stack
    }

    private func makeSummaryRow(title: String, valueLabel: UILabel) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [CineSeatTheme.captionLabel(title), valueLabel])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    @objc private func seatTapped(_ sender: UIButton) {
        guard let seat = sender.accessibilityIdentifier else { return }
        viewModel.toggleSeat(seat)
        updateSeatViews()
    }

    private func updateSeatViews() {
        updateSeatButton(seatA1Button, seat: "A1")
        updateSeatButton(seatA2Button, seat: "A2")
        updateSeatButton(seatA3Button, seat: "A3")
        updateSeatButton(seatA4Button, seat: "A4")
        updateSeatButton(seatA5Button, seat: "A5")
        updateSeatButton(seatA6Button, seat: "A6")
        updateSeatButton(seatA7Button, seat: "A7")
        updateSeatButton(seatA8Button, seat: "A8")
        updateSeatButton(seatB1Button, seat: "B1")
        updateSeatButton(seatB2Button, seat: "B2")
        updateSeatButton(seatB3Button, seat: "B3")
        updateSeatButton(seatB4Button, seat: "B4")
        updateSeatButton(seatB5Button, seat: "B5")
        updateSeatButton(seatB6Button, seat: "B6")
        updateSeatButton(seatB7Button, seat: "B7")
        updateSeatButton(seatB8Button, seat: "B8")
        updateSeatButton(seatC1Button, seat: "C1")
        updateSeatButton(seatC2Button, seat: "C2")
        updateSeatButton(seatC3Button, seat: "C3")
        updateSeatButton(seatC4Button, seat: "C4")
        updateSeatButton(seatC5Button, seat: "C5")
        updateSeatButton(seatC6Button, seat: "C6")
        updateSeatButton(seatC7Button, seat: "C7")
        updateSeatButton(seatC8Button, seat: "C8")
        updateSeatButton(seatD1Button, seat: "D1")
        updateSeatButton(seatD2Button, seat: "D2")
        updateSeatButton(seatD3Button, seat: "D3")
        updateSeatButton(seatD4Button, seat: "D4")
        updateSeatButton(seatD5Button, seat: "D5")
        updateSeatButton(seatD6Button, seat: "D6")
        updateSeatButton(seatD7Button, seat: "D7")
        updateSeatButton(seatD8Button, seat: "D8")
        updateSeatButton(seatE1Button, seat: "E1")
        updateSeatButton(seatE2Button, seat: "E2")
        updateSeatButton(seatE3Button, seat: "E3")
        updateSeatButton(seatE4Button, seat: "E4")
        updateSeatButton(seatE5Button, seat: "E5")
        updateSeatButton(seatE6Button, seat: "E6")
        updateSeatButton(seatE7Button, seat: "E7")
        updateSeatButton(seatE8Button, seat: "E8")
        updateSeatButton(seatF1Button, seat: "F1")
        updateSeatButton(seatF2Button, seat: "F2")
        updateSeatButton(seatF3Button, seat: "F3")
        updateSeatButton(seatF4Button, seat: "F4")
        updateSeatButton(seatF5Button, seat: "F5")
        updateSeatButton(seatF6Button, seat: "F6")
        updateSeatButton(seatF7Button, seat: "F7")
        updateSeatButton(seatF8Button, seat: "F8")
        updateSeatButton(seatG1Button, seat: "G1")
        updateSeatButton(seatG2Button, seat: "G2")
        updateSeatButton(seatG3Button, seat: "G3")
        updateSeatButton(seatG4Button, seat: "G4")
        updateSeatButton(seatG5Button, seat: "G5")
        updateSeatButton(seatG6Button, seat: "G6")
        updateSeatButton(seatG7Button, seat: "G7")
        updateSeatButton(seatG8Button, seat: "G8")

        let seats = viewModel.sortedSelectedSeats
        selectedSeatsLabel.text = seats.isEmpty ? "None" : seats.joined(separator: ", ")
        totalLabel.text = CineSeatTheme.money(viewModel.total)
        continueButton.isEnabled = !seats.isEmpty
        continueButton.alpha = seats.isEmpty ? 0.45 : 1
    }

    private func updateSeatButton(_ button: UIButton?, seat: String) {
        let isReserved = viewModel.reservedSeats.contains(seat)
        let isSelected = viewModel.selectedSeats.contains(seat)
        button?.isEnabled = !isReserved
        button?.backgroundColor = isReserved ? CineSeatTheme.reservedSeat : (isSelected ? CineSeatTheme.primaryText : CineSeatTheme.card)
        button?.layer.borderColor = (isSelected ? CineSeatTheme.primaryText : CineSeatTheme.border).cgColor
        button?.setTitle(isSelected ? "X" : "", for: .normal)
        button?.setTitleColor(.white, for: .normal)
    }

    @objc private func continueTapped() {
        draft.seats = viewModel.sortedSelectedSeats
        let summaryViewController = factory.makeBookingSummaryViewController(draft: draft)
        navigationController?.pushViewController(summaryViewController, animated: true)
    }
}

// module 2 booking summary screen
// this checks login before calling the confirm booking use case
final class BookingSummaryViewController: ScrollableViewController {
    var draft: BookingDraft!
    var factory = AppFactory.shared
    var confirmBookingUseCase: ConfirmBookingUseCase = DefaultConfirmBookingUseCase(
        bookingManager: BookingStore.shared
    )
    var authenticationService: Authenticating = AuthenticationService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Booking Summary"
        buildInterface()
    }

    private func buildInterface() {
        let movieStack = UIStackView()
        movieStack.axis = .vertical
        movieStack.spacing = 5
        let titleLabel = UILabel()
        titleLabel.text = draft.movie.title
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = CineSeatTheme.primaryText
        movieStack.addArrangedSubview(titleLabel)
        movieStack.addArrangedSubview(CineSeatTheme.captionLabel("\(draft.movie.genre) - \(draft.movie.duration) - ***** \(String(format: "%.1f", draft.movie.rating))"))
        contentStack.addArrangedSubview(makeCard(with: movieStack))

        let details = UIStackView()
        details.axis = .vertical
        details.addArrangedSubview(CineSeatTheme.captionLabel("Booking details"))
        details.addArrangedSubview(makeInfoRow(label: "Date", value: draft.date))
        details.addArrangedSubview(makeInfoRow(label: "Time", value: draft.showtime))
        details.addArrangedSubview(makeInfoRow(label: "Cinema", value: draft.cinema.name))
        details.addArrangedSubview(makeInfoRow(label: "Seats", value: draft.seats.joined(separator: ", ")))
        details.addArrangedSubview(makeInfoRow(label: "Tickets", value: "\(draft.seats.count) x \(draft.cinema.type.rawValue)"))
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

        let editButton = CineSeatTheme.secondaryButton(title: "Edit Seats")
        editButton.addTarget(self, action: #selector(editSeatsTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(editButton)
    }

    @objc private func confirmTapped(_ sender: UIButton) {
        guard authenticationService.currentProfile != nil else {
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
        let booking = confirmBookingUseCase.execute(draft: draft)
        let confirmationViewController = factory.makeConfirmationViewController(booking: booking)
        navigationController?.pushViewController(confirmationViewController, animated: true)
    }

    @objc private func editSeatsTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// module 2 confirmation screen
// this shows the final booking details after persistence saves the booking
final class ConfirmationViewController: ScrollableViewController {
    var booking: Booking!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Confirmation"
        navigationItem.hidesBackButton = true
        buildInterface()
    }

    private func buildInterface() {
        let successIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        successIcon.tintColor = CineSeatTheme.primaryText
        successIcon.contentMode = .scaleAspectFit
        successIcon.heightAnchor.constraint(equalToConstant: 72).isActive = true
        contentStack.addArrangedSubview(successIcon)

        let titleLabel = UILabel()
        titleLabel.text = "Booking Confirmed!"
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 21, weight: .heavy)
        titleLabel.textColor = CineSeatTheme.primaryText
        contentStack.addArrangedSubview(titleLabel)

        let idTitle = CineSeatTheme.captionLabel("Booking ID")
        idTitle.textAlignment = .center
        let idLabel = UILabel()
        idLabel.text = booking.id
        idLabel.textAlignment = .center
        idLabel.font = .monospacedSystemFont(ofSize: 20, weight: .bold)
        idLabel.textColor = CineSeatTheme.primaryText
        let idStack = UIStackView(arrangedSubviews: [idTitle, idLabel])
        idStack.axis = .vertical
        idStack.spacing = 5
        contentStack.addArrangedSubview(makeCard(with: idStack))

        let details = UIStackView()
        details.axis = .vertical
        details.addArrangedSubview(makeInfoRow(label: "Movie", value: booking.movie.title))
        details.addArrangedSubview(makeInfoRow(label: "Date", value: booking.date))
        details.addArrangedSubview(makeInfoRow(label: "Showtime", value: booking.showtime))
        details.addArrangedSubview(makeInfoRow(label: "Cinema", value: booking.cinema))
        details.addArrangedSubview(makeInfoRow(label: "Seats", value: booking.seats.joined(separator: ", ")))
        details.addArrangedSubview(makeInfoRow(label: "Total paid", value: CineSeatTheme.money(booking.total)))
        contentStack.addArrangedSubview(makeCard(with: details))

        let viewBookingsButton = CineSeatTheme.primaryButton(title: "View My Bookings")
        viewBookingsButton.addTarget(self, action: #selector(viewBookingsTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(viewBookingsButton)

        let backToMoviesButton = CineSeatTheme.secondaryButton(title: "Back to Movies")
        backToMoviesButton.addTarget(self, action: #selector(backToMoviesTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(backToMoviesButton)
    }

    @objc private func viewBookingsTapped() {
        guard let tabBarController else { return }
        tabBarController.selectedIndex = 1
        (tabBarController.selectedViewController as? UINavigationController)?.popToRootViewController(animated: false)
    }

    @objc private func backToMoviesTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
