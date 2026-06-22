import UIKit

// module 2 reusable scroll screen
// long forms and booking screens stay usable on smaller iphones
class ScrollableViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CineSeatTheme.background

        if scrollView == nil {
            scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(scrollView)
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }

        if contentStack == nil {
            contentStack = UIStackView()
            contentStack.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(contentStack)
            NSLayoutConstraint.activate([
                contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: CineSeatSpacing.large),
                contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
                contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),
                contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -CineSeatSpacing.pageHorizontal)
            ])
        }

        scrollView.alwaysBounceVertical = true
        contentStack.axis = .vertical
        contentStack.spacing = CineSeatSpacing.medium
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func makeCard(with stack: UIStackView, padding: CGFloat = CineSeatSpacing.cardPadding) -> CardView {
        let card = CardView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -padding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -padding)
        ])
        return card
    }

    func makeInfoRow(label: String, value: String) -> UIStackView {
        let labelView = CineSeatTheme.captionLabel(label)
        let valueView = UILabel()
        valueView.text = value
        valueView.textAlignment = .right
        valueView.font = CineSeatFont.infoValue
        valueView.textColor = CineSeatTheme.primaryText
        valueView.numberOfLines = 0
        valueView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [labelView, valueView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = CineSeatSpacing.medium
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = .init(top: 7, leading: 0, bottom: 7, trailing: 0)
        return row
    }
}
