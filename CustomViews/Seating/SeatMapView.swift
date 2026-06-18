import UIKit

// module 6 design layer custom view
// this is a custom UIKit seat map using stack views and buttons
final class SeatMapView: UIView {
    private let gridStack = UIStackView()
    private var layout: SeatLayout?
    private var selectedSeats: Set<String> = []
    private var highlightedSeats: Set<String> = []
    private var isInteractive = true
    private var showsSeatIDForHighlightedSeats = false
    private var accessibilityPrefix = "seat"

    var onSeatTapped: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGrid()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGrid()
    }

    func configure(
        layout: SeatLayout,
        selectedSeats: Set<String>,
        highlightedSeats: Set<String> = [],
        isInteractive: Bool = true,
        showsSeatIDForHighlightedSeats: Bool = false,
        accessibilityPrefix: String = "seat"
    ) {
        self.layout = layout
        self.selectedSeats = selectedSeats
        self.highlightedSeats = highlightedSeats
        self.isInteractive = isInteractive
        self.showsSeatIDForHighlightedSeats = showsSeatIDForHighlightedSeats
        self.accessibilityPrefix = accessibilityPrefix
        rebuildGrid()
    }

    func update(selectedSeats: Set<String>, highlightedSeats: Set<String>? = nil) {
        self.selectedSeats = selectedSeats
        if let highlightedSeats {
            self.highlightedSeats = highlightedSeats
        }

        for case let button as SeatButton in allSeatButtons(in: gridStack) {
            update(button: button)
        }
    }

    private func setupGrid() {
        translatesAutoresizingMaskIntoConstraints = false
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridStack.axis = .vertical
        gridStack.spacing = 5
        gridStack.alignment = .center
        addSubview(gridStack)

        NSLayoutConstraint.activate([
            gridStack.topAnchor.constraint(equalTo: topAnchor),
            gridStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            gridStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            gridStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            gridStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func rebuildGrid() {
        gridStack.arrangedSubviews.forEach { view in
            gridStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard let layout else { return }

        for row in layout.rows {
            gridStack.addArrangedSubview(makeRowStack(row: row, layout: layout))
        }
    }

    private func makeRowStack(row: SeatRow, layout: SeatLayout) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = compactSeatSpacing
        rowStack.alignment = .center

        rowStack.addArrangedSubview(makeRowLabel(row.label))

        for number in row.seatNumbers {
            let seatID = row.seatID(for: number)
            let button = makeSeatButton(seatID: seatID)
            rowStack.addArrangedSubview(button)

            if layout.aisleAfterSeatNumbers.contains(number),
               number != row.seatNumbers.last {
                rowStack.addArrangedSubview(makeAisleSpace())
            }
        }

        rowStack.addArrangedSubview(makeRowLabel(row.label))
        return rowStack
    }

    private func makeSeatButton(seatID: String) -> SeatButton {
        let button = SeatButton(type: .system)
        button.seatID = seatID
        button.accessibilityIdentifier = accessibilityIdentifier(for: seatID)
        button.accessibilityLabel = accessibilityPrefix == "bookingSeat" ? "Booking seat \(seatID)" : "Seat \(seatID)"
        button.titleLabel?.font = .monospacedSystemFont(ofSize: 8, weight: .bold)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.widthAnchor.constraint(equalToConstant: compactSeatSize).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.addTarget(self, action: #selector(seatTapped(_:)), for: .touchUpInside)
        update(button: button)
        return button
    }

    private func update(button: SeatButton) {
        guard let seatID = button.seatID,
              let layout else { return }

        let isHighlighted = highlightedSeats.contains(seatID)
        let isSelected = selectedSeats.contains(seatID)
        let isReserved = layout.reservedSeats.contains(seatID)
        let isUnavailable = layout.unavailableSeats.contains(seatID)
        let isEnabled = isInteractive && (isHighlighted || layout.isSelectable(seatID))

        button.isEnabled = isEnabled
        button.alpha = isUnavailable ? 0.65 : 1
        button.backgroundColor = seatColor(
            isHighlighted: isHighlighted,
            isSelected: isSelected,
            isReserved: isReserved,
            isUnavailable: isUnavailable
        )
        button.layer.borderColor = (isHighlighted || isSelected ? CineSeatTheme.primaryText : CineSeatTheme.border).cgColor
        button.setTitle(seatTitle(seatID: seatID, isHighlighted: isHighlighted, isSelected: isSelected), for: .normal)
        button.setTitleColor(.white, for: .normal)
    }

    private func seatColor(
        isHighlighted: Bool,
        isSelected: Bool,
        isReserved: Bool,
        isUnavailable: Bool
    ) -> UIColor {
        if isHighlighted || isSelected {
            return CineSeatTheme.primaryText
        }

        if isReserved {
            return CineSeatTheme.reservedSeat
        }

        if isUnavailable {
            return CineSeatTheme.unavailableSeat
        }

        return CineSeatTheme.card
    }

    private func seatTitle(seatID: String, isHighlighted: Bool, isSelected: Bool) -> String {
        if isHighlighted && showsSeatIDForHighlightedSeats {
            return seatID
        }

        return isSelected ? "X" : ""
    }

    private func makeRowLabel(_ row: String) -> UILabel {
        let label = CineSeatTheme.captionLabel(row)
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: compactRowLabelWidth).isActive = true
        return label
    }

    private func makeAisleSpace() -> UIView {
        let aisle = UIView()
        aisle.widthAnchor.constraint(equalToConstant: compactAisleWidth).isActive = true
        return aisle
    }

    private func accessibilityIdentifier(for seatID: String) -> String {
        accessibilityPrefix == "seat" ? seatID : "\(accessibilityPrefix)_\(seatID)"
    }

    private func allSeatButtons(in view: UIView) -> [SeatButton] {
        view.subviews.flatMap { subview -> [SeatButton] in
            if let button = subview as? SeatButton {
                return [button]
            }
            return allSeatButtons(in: subview)
        }
    }

    @objc private func seatTapped(_ sender: SeatButton) {
        guard let seatID = sender.seatID else { return }
        onSeatTapped?(seatID)
    }

    private var compactSeatSpacing: CGFloat {
        traitCollection.horizontalSizeClass == .compact ? 3 : 4
    }

    private var compactSeatSize: CGFloat {
        traitCollection.horizontalSizeClass == .compact ? 24 : 28
    }

    private var compactRowLabelWidth: CGFloat {
        traitCollection.horizontalSizeClass == .compact ? 12 : 14
    }

    private var compactAisleWidth: CGFloat {
        traitCollection.horizontalSizeClass == .compact ? 6 : 8
    }
}
