import UIKit

// module 5 settings menu
// this screen writes small app choices into a plist file
final class SettingsViewController: ScrollableViewController {
    var viewModel: SettingsViewModel!

    private let showCancelledSwitch = UISwitch()
    private let reminderSwitch = UISwitch()
    private let demoNotificationSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        buildInterface()
        reloadSettings()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: viewModel.settingsDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func buildInterface() {
        contentStack.addArrangedSubview(makePageTitle("Settings"))
        contentStack.addArrangedSubview(makeSettingsCard())
        contentStack.addArrangedSubview(makeChangelogCard())
        contentStack.addArrangedSubview(makeDemoResetCard())

        let resetButton = CineSeatTheme.secondaryButton(title: "Reset Settings")
        resetButton.accessibilityIdentifier = "resetSettingsButton"
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(resetButton)
    }

    private func makeSettingsCard() -> CardView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = CineSeatSpacing.small
        stack.addArrangedSubview(CineSeatTheme.captionLabel("App settings plist"))
        stack.addArrangedSubview(makeSwitchRow(
            title: "Show cancelled bookings",
            subtitle: "Controls whether cancelled tickets stay visible in My Bookings",
            toggle: showCancelledSwitch,
            action: #selector(showCancelledChanged(_:))
        ))
        stack.addArrangedSubview(makeSwitchRow(
            title: "Booking reminders",
            subtitle: "Schedules local reminders before confirmed showtimes",
            toggle: reminderSwitch,
            action: #selector(reminderChanged(_:))
        ))
        stack.addArrangedSubview(makeSwitchRow(
            title: "Demo notifications",
            subtitle: "Allows the 5 second notification demo on confirmation",
            toggle: demoNotificationSwitch,
            action: #selector(demoNotificationChanged(_:))
        ))
        return makeCard(with: stack)
    }

    private func makeChangelogCard() -> CardView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = CineSeatSpacing.regular
        stack.addArrangedSubview(CineSeatTheme.captionLabel("App changelog"))

        let descriptionLabel = UILabel()
        descriptionLabel.text = "View the release notes and hotfixes added during this demo build"
        descriptionLabel.font = CineSeatFont.bodySmall
        descriptionLabel.textColor = CineSeatTheme.secondaryText
        descriptionLabel.numberOfLines = 0
        stack.addArrangedSubview(descriptionLabel)

        let button = CineSeatTheme.secondaryButton(title: "View Changelog")
        button.accessibilityIdentifier = "viewChangelogButton"
        button.addTarget(self, action: #selector(viewChangelogTapped), for: .touchUpInside)
        stack.addArrangedSubview(button)
        return makeCard(with: stack)
    }

    private func makeDemoResetCard() -> CardView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = CineSeatSpacing.regular
        stack.addArrangedSubview(CineSeatTheme.captionLabel("Demo tools"))

        let descriptionLabel = UILabel()
        descriptionLabel.text = "Clear saved bookings so seat demos and booking numbers start clean again"
        descriptionLabel.font = CineSeatFont.bodySmall
        descriptionLabel.textColor = CineSeatTheme.secondaryText
        descriptionLabel.numberOfLines = 0
        stack.addArrangedSubview(descriptionLabel)

        let button = CineSeatTheme.secondaryButton(title: "Clear Demo Bookings")
        button.accessibilityIdentifier = "clearDemoBookingsButton"
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(clearDemoBookingsTapped), for: .touchUpInside)
        stack.addArrangedSubview(button)
        return makeCard(with: stack)
    }

    private func makeSwitchRow(
        title: String,
        subtitle: String,
        toggle: UISwitch,
        action: Selector
    ) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = CineSeatFont.detailTitle
        titleLabel.textColor = CineSeatTheme.primaryText

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = CineSeatFont.bodySmall
        subtitleLabel.textColor = CineSeatTheme.secondaryText
        subtitleLabel.numberOfLines = 0

        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStack.axis = .vertical
        labelStack.spacing = CineSeatSpacing.tiny

        toggle.addTarget(self, action: action, for: .valueChanged)

        let row = UIStackView(arrangedSubviews: [labelStack, toggle])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = CineSeatSpacing.medium
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = .init(
            top: CineSeatSpacing.small,
            leading: 0,
            bottom: CineSeatSpacing.small,
            trailing: 0
        )
        return row
    }

    private func makePageTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = CineSeatFont.pageTitle
        label.textColor = CineSeatTheme.primaryText
        return label
    }

    private func reloadSettings() {
        showCancelledSwitch.isOn = viewModel.showCancelledBookings
        reminderSwitch.isOn = viewModel.bookingRemindersEnabled
        demoNotificationSwitch.isOn = viewModel.demoNotificationsEnabled
    }

    @objc private func settingsChanged() {
        reloadSettings()
    }

    @objc private func showCancelledChanged(_ sender: UISwitch) {
        viewModel.showCancelledBookings = sender.isOn
    }

    @objc private func reminderChanged(_ sender: UISwitch) {
        viewModel.bookingRemindersEnabled = sender.isOn
    }

    @objc private func demoNotificationChanged(_ sender: UISwitch) {
        viewModel.demoNotificationsEnabled = sender.isOn
    }

    @objc private func viewChangelogTapped() {
        let viewController = ChangelogViewController()
        viewController.entries = viewModel.changelogEntries
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func resetTapped() {
        viewModel.resetSettings()
    }

    @objc private func clearDemoBookingsTapped() {
        let alert = UIAlertController(
            title: "Clear Demo Bookings?",
            message: "This removes all saved bookings, clears taken seats from confirmed bookings, and cancels pending local reminders. Movies, profiles, settings, and seat layouts stay unchanged.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Keep Bookings", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear Bookings", style: .destructive) { [weak self] _ in
            guard let self else { return }
            let removedCount = self.viewModel.clearDemoBookings()
            self.showDemoResetFinished(removedCount: removedCount)
        })
        present(alert, animated: true)
    }

    private func showDemoResetFinished(removedCount: Int) {
        let noun = removedCount == 1 ? "booking" : "bookings"
        let message = removedCount == 0
            ? "There were no saved bookings to clear."
            : "\(removedCount) saved \(noun) were cleared."
        let alert = UIAlertController(
            title: "Demo Reset Complete",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

final class ChangelogViewController: ScrollableViewController {
    var entries: [SettingsChangelogEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Changelog"
        buildInterface()
    }

    private func buildInterface() {
        let titleLabel = UILabel()
        titleLabel.text = "Release Notes"
        titleLabel.font = CineSeatFont.pageTitle
        titleLabel.textColor = CineSeatTheme.primaryText
        contentStack.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Demo changelog for the \(AppConstants.Brand.name) booking app"
        subtitleLabel.font = CineSeatFont.bodySmall
        subtitleLabel.textColor = CineSeatTheme.secondaryText
        subtitleLabel.numberOfLines = 0
        contentStack.addArrangedSubview(subtitleLabel)

        for entry in entries {
            contentStack.addArrangedSubview(makeEntryCard(entry))
        }
    }

    private func makeEntryCard(_ entry: SettingsChangelogEntry) -> CardView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = CineSeatSpacing.small

        let dateLabel = CineSeatTheme.captionLabel(entry.day)
        stack.addArrangedSubview(dateLabel)

        let titleLabel = UILabel()
        titleLabel.text = entry.title
        titleLabel.font = CineSeatFont.detailTitle
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0
        stack.addArrangedSubview(titleLabel)

        let detailsLabel = UILabel()
        detailsLabel.text = entry.details
        detailsLabel.font = CineSeatFont.bodySmall
        detailsLabel.textColor = CineSeatTheme.secondaryText
        detailsLabel.numberOfLines = 0
        stack.addArrangedSubview(detailsLabel)

        return makeCard(with: stack)
    }
}
