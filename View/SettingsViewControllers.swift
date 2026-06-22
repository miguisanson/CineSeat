import UIKit

// module 5 settings menu
// this screen writes small app choices into a plist file
final class SettingsViewController: ScrollableViewController {
    var viewModel: SettingsViewModel!

    private let showCancelledSwitch = UISwitch()
    private let reminderSwitch = UISwitch()
    private let demoNotificationSwitch = UISwitch()
    private let settingsVersionLabel = UILabel()
    private let seatDatabaseLabel = UILabel()

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
        contentStack.addArrangedSubview(makeStorageCard())

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

    private func makeStorageCard() -> CardView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = CineSeatSpacing.regular
        stack.addArrangedSubview(CineSeatTheme.captionLabel("Local plist storage"))
        stack.addArrangedSubview(settingsVersionLabel)
        stack.addArrangedSubview(seatDatabaseLabel)
        stack.addArrangedSubview(makePathLabel("settings file: \(viewModel.settingsPathText)"))
        stack.addArrangedSubview(makePathLabel("seat layout file: \(viewModel.seatDatabasePathText)"))
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

    private func makePathLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = CineSeatFont.metadata
        label.textColor = CineSeatTheme.mutedText
        label.numberOfLines = 0
        return label
    }

    private func reloadSettings() {
        showCancelledSwitch.isOn = viewModel.showCancelledBookings
        reminderSwitch.isOn = viewModel.bookingRemindersEnabled
        demoNotificationSwitch.isOn = viewModel.demoNotificationsEnabled
        settingsVersionLabel.text = viewModel.settingsVersionText
        settingsVersionLabel.font = CineSeatFont.infoValue
        settingsVersionLabel.textColor = CineSeatTheme.primaryText
        seatDatabaseLabel.text = viewModel.seatDatabaseText
        seatDatabaseLabel.font = CineSeatFont.infoValue
        seatDatabaseLabel.textColor = CineSeatTheme.primaryText
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

    @objc private func resetTapped() {
        viewModel.resetSettings()
    }
}
