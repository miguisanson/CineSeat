import UIKit

// shared controls keep movie concert and seminar result headers aligned
final class ShowingListTableHeaderView: UIView {
    static let height: CGFloat = 132

    let countLabel = CineSeatTheme.captionLabel("")
    let ratingSortButton = UIButton(type: .system)
    let locationFilterButton = UIButton(type: .system)

    init(
        frame: CGRect,
        countAccessibilityIdentifier: String,
        ratingAccessibilityIdentifier: String,
        locationAccessibilityIdentifier: String
    ) {
        super.init(frame: frame)
        configureViews(
            countAccessibilityIdentifier: countAccessibilityIdentifier,
            ratingAccessibilityIdentifier: ratingAccessibilityIdentifier,
            locationAccessibilityIdentifier: locationAccessibilityIdentifier
        )
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews(
            countAccessibilityIdentifier: "showingResultCount",
            ratingAccessibilityIdentifier: "ratingSort",
            locationAccessibilityIdentifier: "locationFilter"
        )
    }

    private func configureViews(
        countAccessibilityIdentifier: String,
        ratingAccessibilityIdentifier: String,
        locationAccessibilityIdentifier: String
    ) {
        countLabel.accessibilityIdentifier = countAccessibilityIdentifier
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        ratingSortButton.contentHorizontalAlignment = .left
        ratingSortButton.titleLabel?.font = CineSeatFont.metadataSemibold
        ratingSortButton.setTitleColor(CineSeatTheme.primaryText, for: .normal)
        ratingSortButton.accessibilityIdentifier = ratingAccessibilityIdentifier
        ratingSortButton.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.gray()
        configuration.image = UIImage(systemName: "mappin.and.ellipse")
        configuration.imagePadding = CineSeatSpacing.small
        configuration.titleLineBreakMode = .byTruncatingTail
        locationFilterButton.configuration = configuration
        locationFilterButton.contentHorizontalAlignment = .left
        locationFilterButton.showsMenuAsPrimaryAction = true
        locationFilterButton.accessibilityIdentifier = locationAccessibilityIdentifier
        locationFilterButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(countLabel)
        addSubview(ratingSortButton)
        addSubview(locationFilterButton)

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: CineSeatSpacing.small),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),

            ratingSortButton.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: CineSeatSpacing.tiny),
            ratingSortButton.leadingAnchor.constraint(equalTo: countLabel.leadingAnchor),
            ratingSortButton.trailingAnchor.constraint(equalTo: countLabel.trailingAnchor),
            ratingSortButton.heightAnchor.constraint(equalToConstant: 32),

            locationFilterButton.topAnchor.constraint(equalTo: ratingSortButton.bottomAnchor, constant: CineSeatSpacing.tiny),
            locationFilterButton.leadingAnchor.constraint(equalTo: countLabel.leadingAnchor),
            locationFilterButton.trailingAnchor.constraint(equalTo: countLabel.trailingAnchor),
            locationFilterButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
}
