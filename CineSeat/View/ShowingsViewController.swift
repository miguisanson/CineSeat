import UIKit

// module 2 showings landing screen
// movies concerts and seminars open as three separate feature pages
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
        titleLabel.text = "\(AppConstants.Brand.name) Showings"
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

        let countLabel = CineSeatTheme.captionLabel(viewModel.countText(for: category))
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
        card.tag = viewModel.categories.firstIndex(of: category) ?? 0
        card.isAccessibilityElement = true
        card.accessibilityIdentifier = "showingCategory_\(category.title)"
        card.accessibilityLabel = "\(category.title), \(category.subtitle)"
        card.accessibilityTraits = .button
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryTapped(_:))))
        return card
    }

    @objc private func categoryTapped(_ recognizer: UITapGestureRecognizer) {
        guard let card = recognizer.view,
              viewModel.categories.indices.contains(card.tag) else { return }

        switch viewModel.categories[card.tag] {
        case .movies:
            showMovies()
        case .concerts:
            navigationController?.pushViewController(factory.makeConcertListViewController(), animated: true)
        case .seminars:
            navigationController?.pushViewController(factory.makeSeminarListViewController(), animated: true)
        }
    }

    private func showMovies() {
        guard let moviesViewController = storyboard?.instantiateViewController(
            withIdentifier: "movies-vc"
        ) as? MoviesViewController else { return }
        navigationController?.pushViewController(moviesViewController, animated: true)
    }
}
