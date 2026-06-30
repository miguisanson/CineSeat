import UIKit

// module 5 settings menu
// this screen writes small app choices into a plist file
final class SettingsViewController: ScrollableViewController {
    var factory = AppFactory.shared
    var viewModel: SettingsViewModel!

    private let showCancelledSwitch = UISwitch()
    private let reminderSwitch = UISwitch()

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
        contentStack.addArrangedSubview(makeDeveloperModeCard())

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
        stack.addArrangedSubview(SettingsSwitchRowView(
            title: "Show cancelled bookings",
            subtitle: "Controls whether cancelled tickets stay visible in My Bookings",
            toggle: showCancelledSwitch,
            target: self,
            action: #selector(showCancelledChanged(_:))
        ))
        stack.addArrangedSubview(SettingsSwitchRowView(
            title: "Booking reminders",
            subtitle: "Schedules local reminders before confirmed showtimes",
            toggle: reminderSwitch,
            target: self,
            action: #selector(reminderChanged(_:))
        ))
        return makeCard(with: stack)
    }

    private func makeChangelogCard() -> CardView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = CineSeatSpacing.regular
        stack.addArrangedSubview(CineSeatTheme.captionLabel("App changelog"))

        let descriptionLabel = UILabel()
        descriptionLabel.text = "View the release notes and changes included in this build"
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

    private func makeDeveloperModeCard() -> CardView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = CineSeatSpacing.regular
        stack.addArrangedSubview(CineSeatTheme.captionLabel("Developer Mode"))

        let descriptionLabel = UILabel()
        descriptionLabel.text = "Open isolated notification, eligibility, and local data testing controls"
        descriptionLabel.font = CineSeatFont.bodySmall
        descriptionLabel.textColor = CineSeatTheme.secondaryText
        descriptionLabel.numberOfLines = 0
        stack.addArrangedSubview(descriptionLabel)

        let button = CineSeatTheme.secondaryButton(title: "Open Developer Mode")
        button.accessibilityIdentifier = "openDeveloperModeButton"
        button.addTarget(self, action: #selector(openDeveloperModeTapped), for: .touchUpInside)
        stack.addArrangedSubview(button)
        return makeCard(with: stack)
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

    @objc private func viewChangelogTapped() {
        let viewController = ChangelogViewController()
        viewController.entries = viewModel.changelogEntries
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func resetTapped() {
        viewModel.resetSettings()
    }

    @objc private func openDeveloperModeTapped() {
        navigationController?.pushViewController(factory.makeDeveloperModeViewController(), animated: true)
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
        subtitleLabel.text = "Release history for the \(AppConstants.Brand.name) booking app"
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
