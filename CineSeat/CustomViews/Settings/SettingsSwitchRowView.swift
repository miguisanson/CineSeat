import UIKit

// shared settings row removes duplicate label and switch setup
final class SettingsSwitchRowView: UIStackView {
    init(
        title: String,
        subtitle: String,
        toggle: UISwitch,
        target: Any?,
        action: Selector
    ) {
        super.init(frame: .zero)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = CineSeatFont.detailTitle
        titleLabel.textColor = CineSeatTheme.primaryText

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = CineSeatFont.bodySmall
        subtitleLabel.textColor = CineSeatTheme.secondaryText
        subtitleLabel.numberOfLines = 0

        let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labels.axis = .vertical
        labels.spacing = CineSeatSpacing.tiny

        toggle.addTarget(target, action: action, for: .valueChanged)
        addArrangedSubview(labels)
        addArrangedSubview(toggle)
        axis = .horizontal
        alignment = .center
        spacing = CineSeatSpacing.medium
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = .init(
            top: CineSeatSpacing.small,
            leading: 0,
            bottom: CineSeatSpacing.small,
            trailing: 0
        )
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
