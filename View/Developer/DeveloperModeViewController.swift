import UIKit

// all local testing controls are isolated on this settings subpage
final class DeveloperModeViewController: ScrollableViewController {
    var viewModel: DeveloperModeViewModel!

    private let developerModeSwitch = UISwitch()
    private let simulateReviewSwitch = UISwitch()
    private let testNotificationSwitch = UISwitch()
    private let sendTestNotificationButton = CineSeatTheme.secondaryButton(title: "Send Test Notification")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Developer Mode"
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
        let titleLabel = UILabel()
        titleLabel.text = "Developer Mode"
        titleLabel.font = CineSeatFont.pageTitle
        titleLabel.textColor = CineSeatTheme.primaryText
        contentStack.addArrangedSubview(titleLabel)

        let warningLabel = UILabel()
        warningLabel.text = "Local testing tools can bypass production rules or erase device data. Keep Developer Mode off during normal use."
        warningLabel.font = CineSeatFont.body
        warningLabel.textColor = .systemRed
        warningLabel.numberOfLines = 0
        contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [warningLabel])))

        contentStack.addArrangedSubview(makeSwitchCard(
            title: "Enable Developer Mode",
            subtitle: "Unlocks the testing controls on this page",
            toggle: developerModeSwitch,
            action: #selector(developerModeChanged(_:))
        ))

        let testStack = UIStackView()
        testStack.axis = .vertical
        testStack.spacing = CineSeatSpacing.small
        testStack.addArrangedSubview(CineSeatTheme.captionLabel("Simulation"))
        testStack.addArrangedSubview(SettingsSwitchRowView(
            title: "Simulate review eligibility",
            subtitle: "Allows a signed-in account to review without waiting for an attended booking",
            toggle: simulateReviewSwitch,
            target: self,
            action: #selector(simulateReviewChanged(_:))
        ))
        testStack.addArrangedSubview(SettingsSwitchRowView(
            title: "Test notifications",
            subtitle: "Allows the local five-second notification test",
            toggle: testNotificationSwitch,
            target: self,
            action: #selector(testNotificationChanged(_:))
        ))
        sendTestNotificationButton.accessibilityIdentifier = "sendTestNotificationButton"
        sendTestNotificationButton.addTarget(self, action: #selector(sendTestNotificationTapped), for: .touchUpInside)
        testStack.addArrangedSubview(sendTestNotificationButton)
        contentStack.addArrangedSubview(makeCard(with: testStack))

        let dataStack = UIStackView()
        dataStack.axis = .vertical
        dataStack.spacing = CineSeatSpacing.regular
        dataStack.addArrangedSubview(CineSeatTheme.captionLabel("Local data reset"))
        let clearBookingsButton = destructiveButton(title: "Clear Local Bookings", action: #selector(clearBookingsTapped))
        clearBookingsButton.accessibilityIdentifier = "clearLocalBookingsButton"
        dataStack.addArrangedSubview(clearBookingsButton)
        let clearReviewsButton = destructiveButton(title: "Clear Local Reviews", action: #selector(clearReviewsTapped))
        clearReviewsButton.accessibilityIdentifier = "clearLocalReviewsButton"
        dataStack.addArrangedSubview(clearReviewsButton)
        contentStack.addArrangedSubview(makeCard(with: dataStack))
    }

    private func makeSwitchCard(title: String, subtitle: String, toggle: UISwitch, action: Selector) -> CardView {
        makeCard(with: SettingsSwitchRowView(
            title: title,
            subtitle: subtitle,
            toggle: toggle,
            target: self,
            action: action
        ))
    }

    private func destructiveButton(title: String, action: Selector) -> UIButton {
        let button = CineSeatTheme.secondaryButton(title: title)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func reloadSettings() {
        developerModeSwitch.isOn = viewModel.developerModeEnabled
        simulateReviewSwitch.isOn = viewModel.simulateReviewEligibility
        testNotificationSwitch.isOn = viewModel.testNotificationsEnabled
        let controlsEnabled = viewModel.developerModeEnabled
        simulateReviewSwitch.isEnabled = controlsEnabled
        testNotificationSwitch.isEnabled = controlsEnabled
        sendTestNotificationButton.isEnabled = controlsEnabled && viewModel.testNotificationsEnabled
        sendTestNotificationButton.alpha = sendTestNotificationButton.isEnabled ? 1 : 0.45
    }

    @objc private func settingsChanged() {
        reloadSettings()
    }

    @objc private func developerModeChanged(_ sender: UISwitch) {
        viewModel.developerModeEnabled = sender.isOn
    }

    @objc private func simulateReviewChanged(_ sender: UISwitch) {
        viewModel.simulateReviewEligibility = sender.isOn
    }

    @objc private func testNotificationChanged(_ sender: UISwitch) {
        viewModel.testNotificationsEnabled = sender.isOn
    }

    @objc private func sendTestNotificationTapped() {
        viewModel.scheduleTestNotification { [weak self] scheduled in
            DispatchQueue.main.async {
                self?.showMessage(
                    title: scheduled ? "Notification Scheduled" : "Notification Not Scheduled",
                    message: scheduled
                        ? "The local notification should appear in about five seconds."
                        : "Enable notification permission and the Test Notifications switch."
                )
            }
        }
    }

    @objc private func clearBookingsTapped() {
        confirmDestructiveAction(
            title: "Clear Local Bookings?",
            message: "This removes all bookings, releases locally reserved seats, and cancels pending reminders.",
            actionTitle: "Clear Bookings"
        ) { [weak self] in
            let count = self?.viewModel.clearBookings() ?? 0
            self?.showMessage(title: "Bookings Cleared", message: "Removed \(count) local bookings.")
        }
    }

    @objc private func clearReviewsTapped() {
        confirmDestructiveAction(
            title: "Clear Local Reviews?",
            message: "This permanently removes every review saved on this device.",
            actionTitle: "Clear Reviews"
        ) { [weak self] in
            let count = self?.viewModel.clearReviews() ?? 0
            self?.showMessage(title: "Reviews Cleared", message: "Removed \(count) local reviews.")
        }
    }

    private func confirmDestructiveAction(
        title: String,
        message: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive) { _ in action() })
        present(alert, animated: true)
    }

    private func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
