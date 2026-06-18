import UIKit

// module 6 design layer theme
// shared colors and basic factory helpers stay here
enum CineSeatTheme {
    static let background = UIColor.white
    static let card = UIColor(white: 0.96, alpha: 1)
    static let border = UIColor(white: 0.84, alpha: 1)
    static let placeholder = UIColor(white: 0.79, alpha: 1)
    static let mutedText = UIColor(white: 0.58, alpha: 1)
    static let secondaryText = UIColor(white: 0.33, alpha: 1)
    static let primaryText = UIColor(white: 0.10, alpha: 1)
    static let reservedSeat = UIColor(white: 0.75, alpha: 1)
    static let unavailableSeat = UIColor(white: 0.88, alpha: 1)

    static func money(_ value: Double) -> String {
        String(format: "₱%.2f", value)
    }

    static func captionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .monospacedSystemFont(ofSize: 10, weight: .medium)
        label.textColor = mutedText
        label.numberOfLines = 0
        return label
    }

    static func primaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title.uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
        button.backgroundColor = primaryText
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }

    static func secondaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title.uppercased(), for: .normal)
        button.setTitleColor(primaryText, for: .normal)
        button.titleLabel?.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
        button.backgroundColor = UIColor(white: 0.91, alpha: 1)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = border.cgColor
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }
}
