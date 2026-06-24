import UIKit

// module 2 showings landing screen
// this is the screen before movies concerts and seminars
final class ShowingsViewController: ScrollableViewController {
    var factory = AppFactory.shared
    private lazy var viewModel = factory.makeShowingsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Showings"
        buildInterface()
    }

    private func buildInterface() {
        let titleLabel = UILabel()
        titleLabel.text = "CineSeat Showings"
        titleLabel.font = CineSeatFont.pageTitleHeavy
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = viewModel.headerText
        subtitleLabel.font = CineSeatFont.body
        subtitleLabel.textColor = CineSeatTheme.secondaryText
        subtitleLabel.numberOfLines = 0

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)

        for category in viewModel.categories {
            contentStack.addArrangedSubview(makeCategoryCard(category))
        }
    }

    private func makeCategoryCard(_ category: ShowingCategory) -> CardView {
        let iconView = UIImageView(image: UIImage(systemName: category.iconName))
        iconView.tintColor = CineSeatTheme.primaryText
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 34),
            iconView.heightAnchor.constraint(equalToConstant: 34)
        ])

        let titleLabel = UILabel()
        titleLabel.text = category.title
        titleLabel.font = CineSeatFont.detailTitle
        titleLabel.textColor = CineSeatTheme.primaryText

        let subtitleLabel = UILabel()
        subtitleLabel.text = category.subtitle
        subtitleLabel.font = CineSeatFont.body
        subtitleLabel.textColor = CineSeatTheme.secondaryText
        subtitleLabel.numberOfLines = 0

        let countLabel = CineSeatTheme.captionLabel(viewModel.countText(for: category).uppercased())

        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, countLabel])
        labelStack.axis = .vertical
        labelStack.spacing = CineSeatSpacing.tiny

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = CineSeatTheme.mutedText
        chevron.contentMode = .scaleAspectFit

        let row = UIStackView(arrangedSubviews: [iconView, labelStack, chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = CineSeatSpacing.medium

        let card = makeCard(with: row)
        card.accessibilityIdentifier = "showingCategory_\(category.title)"
        card.isAccessibilityElement = true
        card.accessibilityLabel = "\(category.title), \(category.subtitle)"
        card.accessibilityTraits = .button

        let tap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped(_:)))
        card.addGestureRecognizer(tap)
        card.tag = viewModel.categories.firstIndex(of: category) ?? 0
        return card
    }

    @objc private func categoryTapped(_ recognizer: UITapGestureRecognizer) {
        guard let card = recognizer.view,
              viewModel.categories.indices.contains(card.tag) else {
            return
        }

        switch viewModel.categories[card.tag] {
        case .movies:
            showMovies()
        case .concerts:
            navigationController?.pushViewController(factory.makeEventListViewController(category: .concert), animated: true)
        case .seminars:
            navigationController?.pushViewController(factory.makeEventListViewController(category: .seminar), animated: true)
        }
    }

    private func showMovies() {
        guard let moviesViewController = storyboard?.instantiateViewController(withIdentifier: "movies-vc") as? MoviesViewController else {
            return
        }
        navigationController?.pushViewController(moviesViewController, animated: true)
    }
}
