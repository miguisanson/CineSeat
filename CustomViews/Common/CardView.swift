import UIKit

// module 6 reusable card view
// most screens use this for simple grouped content
final class CardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = CineSeatTheme.card
        layer.cornerRadius = CineSeatRadius.medium
        layer.borderWidth = 1
        layer.borderColor = CineSeatTheme.border.cgColor
    }
}
