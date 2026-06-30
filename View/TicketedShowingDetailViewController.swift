import UIKit

// module 2 shared concert and seminar detail layout
// ticketed showings use quantity instead of a cinema seat map
class TicketedShowingDetailViewController: ScrollableViewController {
    var factory = AppFactory.shared
    var viewModel: TicketedShowingScheduleViewModel!

    private let datePicker = UIDatePicker()
    private let timesStack = UIStackView()
    private let venueLabel = UILabel()
    private let mapView = LocationPreviewMapView()
    private let quantityLabel = UILabel()
    private let quantityStepper = UIStepper()
    private let priceLabel = UILabel()
    private let reviewsButton = CineSeatTheme.secondaryButton(title: "Read Reviews")
    private let bookButton = CineSeatTheme.primaryButton(title: "Book Tickets")
    private lazy var reviewSubject = ReviewSubject(event: viewModel.event)
    private lazy var reviewsViewModel = factory.makeReviewsViewModel(subject: reviewSubject)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.event.category.title
        buildInterface()
        updateScheduleViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reviewsViewModel.reload()
        reviewsButton.setTitle("READ REVIEWS (\(reviewsViewModel.reviews.count))", for: .normal)
    }

    private func buildInterface() {
        let event = viewModel.event
        let posterView = PosterPlaceholderView()
        posterView.translatesAutoresizingMaskIntoConstraints = false
        posterView.heightAnchor.constraint(equalToConstant: CineSeatSize.posterDetailHeight).isActive = true
        posterView.loadPoster(from: event.posterURLString, localName: event.localPosterName)
        contentStack.addArrangedSubview(posterView)

        let titleLabel = UILabel()
        titleLabel.text = event.title
        titleLabel.font = CineSeatFont.pageTitleHeavy
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0
        contentStack.addArrangedSubview(titleLabel)

        let metadataLabel = UILabel()
        metadataLabel.text = "\(event.eventType) - \(event.duration)\n\(reviewsViewModel.ratingSummary.compactText)"
        metadataLabel.font = CineSeatFont.metadata
        metadataLabel.textColor = CineSeatTheme.mutedText
        metadataLabel.numberOfLines = 0
        contentStack.addArrangedSubview(metadataLabel)

        let details = UIStackView()
        details.axis = .vertical
        details.spacing = CineSeatSpacing.small
        details.addArrangedSubview(CineSeatTheme.captionLabel("Details"))
        let summaryLabel = UILabel()
        summaryLabel.text = event.summary
        summaryLabel.font = CineSeatFont.body
        summaryLabel.textColor = CineSeatTheme.secondaryText
        summaryLabel.numberOfLines = 0
        details.addArrangedSubview(summaryLabel)
        contentStack.addArrangedSubview(makeCard(with: details))

        reviewsButton.accessibilityIdentifier = "ticketedShowingReviewsButton"
        reviewsButton.addTarget(self, action: #selector(reviewsTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(reviewsButton)

        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Select date"))
        configureDatePicker()
        contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [datePicker]), padding: 10))

        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Select time"))
        timesStack.axis = .vertical
        timesStack.spacing = CineSeatSpacing.regular
        contentStack.addArrangedSubview(timesStack)

        venueLabel.font = CineSeatFont.metadata
        venueLabel.textColor = CineSeatTheme.secondaryText
        venueLabel.numberOfLines = 0
        venueLabel.textAlignment = .center
        contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [venueLabel]), padding: 12))

        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Venue location"))
        contentStack.addArrangedSubview(mapView)

        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = Double(AppConstants.Booking.maximumEventTickets)
        quantityStepper.stepValue = 1
        quantityStepper.value = Double(viewModel.quantity)
        quantityStepper.addTarget(self, action: #selector(quantityChanged(_:)), for: .valueChanged)
        quantityStepper.accessibilityIdentifier = "eventTicketQuantityStepper"

        quantityLabel.font = CineSeatFont.infoValue
        quantityLabel.textColor = CineSeatTheme.primaryText
        priceLabel.font = CineSeatFont.detailTitle
        priceLabel.textColor = CineSeatTheme.primaryText
        priceLabel.textAlignment = .right

        let quantityRow = UIStackView(arrangedSubviews: [quantityLabel, UIView(), quantityStepper])
        quantityRow.axis = .horizontal
        quantityRow.alignment = .center
        let priceRow = UIStackView(arrangedSubviews: [CineSeatTheme.captionLabel("Estimated total"), UIView(), priceLabel])
        priceRow.axis = .horizontal
        priceRow.alignment = .center
        let ticketStack = UIStackView(arrangedSubviews: [quantityRow, priceRow])
        ticketStack.axis = .vertical
        ticketStack.spacing = CineSeatSpacing.medium
        contentStack.addArrangedSubview(makeCard(with: ticketStack))

        bookButton.addTarget(self, action: #selector(bookTicketsTapped), for: .touchUpInside)
        bookButton.accessibilityIdentifier = "bookEventTicketsButton"
        contentStack.addArrangedSubview(bookButton)
    }

    private func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.minimumDate = viewModel.minimumDate
        datePicker.maximumDate = viewModel.maximumDate
        datePicker.isEnabled = viewModel.minimumDate != nil
        if let selectedDate = viewModel.selectedSchedule?.date {
            datePicker.date = selectedDate
        }
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    private func rebuildTimeButtons() {
        timesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let times = viewModel.selectedSchedule?.times else { return }

        for (index, time) in times.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.titleLabel?.font = CineSeatFont.infoValue
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.layer.cornerRadius = CineSeatRadius.medium
            button.layer.borderWidth = 1
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
            button.addTarget(self, action: #selector(timeTapped(_:)), for: .touchUpInside)
            button.setTitle("\(time.showtime)\n\(time.venue.name)\n\(CineSeatTheme.money(time.ticketPrice)) per ticket", for: .normal)
            let isSelected = viewModel.selectedTime?.id == time.id
            button.backgroundColor = isSelected ? CineSeatTheme.primaryText : CineSeatTheme.card
            button.setTitleColor(isSelected ? .white : CineSeatTheme.primaryText, for: .normal)
            button.layer.borderColor = (isSelected ? CineSeatTheme.primaryText : CineSeatTheme.border).cgColor
            timesStack.addArrangedSubview(button)
        }
    }

    private func updateScheduleViews() {
        rebuildTimeButtons()
        quantityStepper.maximumValue = Double(viewModel.maximumQuantity)
        quantityStepper.value = Double(viewModel.quantity)
        quantityLabel.text = "Tickets: \(viewModel.quantity)"
        priceLabel.text = CineSeatTheme.money(viewModel.total)

        if let schedule = viewModel.selectedSchedule, let time = viewModel.selectedTime {
            venueLabel.text = "date: \(schedule.displayDateWithTitle)\ntime: \(time.showtime)\nvenue: \(time.venue.name)\n\(time.venue.address)"
            mapView.show(venue: time.venue)
        } else {
            venueLabel.text = "no bookable event schedule yet"
        }

        bookButton.isEnabled = viewModel.isBookingAvailable
        bookButton.alpha = viewModel.isBookingAvailable ? 1 : 0.45
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        viewModel.selectDate(sender.date)
        updateScheduleViews()
    }

    @objc private func timeTapped(_ sender: UIButton) {
        viewModel.selectTime(at: sender.tag)
        updateScheduleViews()
    }

    @objc private func quantityChanged(_ sender: UIStepper) {
        viewModel.setQuantity(Int(sender.value))
        updateScheduleViews()
    }

    @objc private func bookTicketsTapped() {
        guard let draft = viewModel.makeDraft() else { return }
        navigationController?.pushViewController(
            factory.makeTicketedShowingBookingSummaryViewController(draft: draft),
            animated: true
        )
    }

    @objc private func reviewsTapped() {
        navigationController?.pushViewController(
            factory.makeReviewsViewController(subject: reviewSubject),
            animated: true
        )
    }
}
