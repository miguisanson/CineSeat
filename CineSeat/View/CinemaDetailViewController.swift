import UIKit

// module 2 cinema detail screen
// opened from a map pin so users can inspect schedules assigned to that location
final class CinemaDetailViewController: ScrollableViewController {
    var factory = AppFactory.shared
    var viewModel: CinemaDetailViewModel!

    // tapping a movie header opens its detail; movieLookup[tag] resolves the movie
    private var movieLookup: [Movie] = []
    // tapping a showtime chip opens the movie detail with that time preselected
    private var chipLookup: [(movie: Movie, timeID: String)] = []

    private let chipsPerRow = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cinema Details"
        buildInterface()
    }

    private func buildInterface() {
        let titleLabel = UILabel()
        titleLabel.text = viewModel.cinema.name
        titleLabel.font = CineSeatFont.pageTitleHeavy
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0
        contentStack.addArrangedSubview(titleLabel)

        let summaryStack = UIStackView()
        summaryStack.axis = .vertical
        summaryStack.spacing = CineSeatSpacing.small
        summaryStack.addArrangedSubview(CineSeatTheme.captionLabel("Cinema information"))
        summaryStack.addArrangedSubview(makeInfoRow(label: "Type", value: viewModel.cinema.type.rawValue))
        summaryStack.addArrangedSubview(makeInfoRow(label: "Ticket price", value: viewModel.priceText))
        summaryStack.addArrangedSubview(makeInfoRow(label: "Address", value: viewModel.addressText))
        contentStack.addArrangedSubview(makeCard(with: summaryStack))

        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Now showing here"))

        let countLabel = UILabel()
        countLabel.text = viewModel.scheduleCountText
        countLabel.font = CineSeatFont.caption
        countLabel.textColor = CineSeatTheme.mutedText
        countLabel.numberOfLines = 0
        contentStack.addArrangedSubview(countLabel)

        let movieGroups = viewModel.movieGroups
        if movieGroups.isEmpty {
            contentStack.addArrangedSubview(makeEmptyCard())
        } else {
            for group in movieGroups {
                contentStack.addArrangedSubview(makeMovieCard(for: group))
            }
        }
    }

    private func makeEmptyCard() -> CardView {
        let label = UILabel()
        label.text = "No assigned movie schedules for this cinema yet."
        label.font = CineSeatFont.body
        label.textColor = CineSeatTheme.secondaryText
        label.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [label])
        stack.axis = .vertical
        return makeCard(with: stack)
    }

    private func makeMovieCard(for group: CinemaDetailViewModel.MovieGroup) -> CardView {
        let movieIndex = movieLookup.count
        movieLookup.append(group.movie)

        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.spacing = CineSeatSpacing.medium

        cardStack.addArrangedSubview(makeMovieHeader(for: group, movieIndex: movieIndex))

        let separator = UIView()
        separator.backgroundColor = CineSeatTheme.border
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        cardStack.addArrangedSubview(separator)

        for dateGroup in group.dateGroups {
            cardStack.addArrangedSubview(makeDateGroupStack(dateGroup, movie: group.movie))
        }

        let hint = CineSeatTheme.captionLabel("tap a showtime to continue booking")
        hint.numberOfLines = 0
        cardStack.addArrangedSubview(hint)

        return makeCard(with: cardStack)
    }

    private func makeMovieHeader(
        for group: CinemaDetailViewModel.MovieGroup,
        movieIndex: Int
    ) -> UIView {
        let poster = PosterPlaceholderView()
        poster.layer.cornerRadius = CineSeatRadius.small
        poster.clipsToBounds = true
        poster.loadPoster(from: group.movie.posterURLString, localName: group.movie.localPosterName)
        NSLayoutConstraint.activate([
            poster.widthAnchor.constraint(equalToConstant: CineSeatSize.moviePosterWidth),
            poster.heightAnchor.constraint(equalToConstant: CineSeatSize.moviePosterHeight)
        ])

        let titleLabel = UILabel()
        titleLabel.text = group.movie.title
        titleLabel.font = CineSeatFont.detailTitle
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0

        let metadataLabel = UILabel()
        metadataLabel.text = group.metadataText
        metadataLabel.font = CineSeatFont.metadata
        metadataLabel.textColor = CineSeatTheme.secondaryText
        metadataLabel.numberOfLines = 0

        let countLabel = UILabel()
        countLabel.text = group.showtimeCountText
        countLabel.font = CineSeatFont.caption
        countLabel.textColor = CineSeatTheme.mutedText

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = CineSeatTheme.mutedText
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let infoStack = UIStackView(arrangedSubviews: [titleLabel, metadataLabel, countLabel])
        infoStack.axis = .vertical
        infoStack.spacing = CineSeatSpacing.tiny

        let headerStack = UIStackView(arrangedSubviews: [poster, infoStack, chevron])
        headerStack.axis = .horizontal
        headerStack.spacing = CineSeatSpacing.medium
        headerStack.alignment = .center

        // make the whole header act like a "view movie" button
        let headerButton = UIButton(type: .system)
        headerButton.tag = movieIndex
        headerButton.accessibilityLabel = "View \(group.movie.title) details"
        headerButton.addTarget(self, action: #selector(viewMovieTapped(_:)), for: .touchUpInside)

        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.isUserInteractionEnabled = false
        headerButton.addSubview(headerStack)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: headerButton.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: headerButton.leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: headerButton.trailingAnchor),
            headerStack.bottomAnchor.constraint(equalTo: headerButton.bottomAnchor)
        ])
        return headerButton
    }

    private func makeDateGroupStack(
        _ dateGroup: CinemaDetailViewModel.DateGroup,
        movie: Movie
    ) -> UIStackView {
        let dateLabel = CineSeatTheme.captionLabel(dateGroup.schedule.displayDateWithTitle)
        dateLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [dateLabel])
        stack.axis = .vertical
        stack.spacing = CineSeatSpacing.small
        stack.addArrangedSubview(makeChipRows(for: dateGroup.times, movie: movie))
        return stack
    }

    // wraps showtime chips into fixed-width rows so they stay readable on small screens
    private func makeChipRows(for times: [ShowingTime], movie: Movie) -> UIStackView {
        let columnStack = UIStackView()
        columnStack.axis = .vertical
        columnStack.spacing = CineSeatSpacing.small

        var currentRow = makeChipRow()
        for (index, time) in times.enumerated() {
            if index > 0 && index % chipsPerRow == 0 {
                fillRow(currentRow)
                columnStack.addArrangedSubview(currentRow)
                currentRow = makeChipRow()
            }
            currentRow.addArrangedSubview(makeTimeChip(for: time, movie: movie))
        }
        fillRow(currentRow)
        columnStack.addArrangedSubview(currentRow)
        return columnStack
    }

    private func makeChipRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = CineSeatSpacing.small
        row.distribution = .fillEqually
        return row
    }

    // pads the final row with spacers so chips keep a consistent width
    private func fillRow(_ row: UIStackView) {
        let missing = chipsPerRow - row.arrangedSubviews.count
        guard missing > 0 else { return }
        for _ in 0..<missing {
            row.addArrangedSubview(UIView())
        }
    }

    private func makeTimeChip(for time: ShowingTime, movie: Movie) -> UIButton {
        let chipIndex = chipLookup.count
        chipLookup.append((movie: movie, timeID: time.id))

        let chip = UIButton(type: .system)
        chip.tag = chipIndex
        chip.setTitle(time.showtime, for: .normal)
        chip.setTitleColor(CineSeatTheme.primaryText, for: .normal)
        chip.titleLabel?.font = CineSeatFont.button
        chip.backgroundColor = CineSeatTheme.card
        chip.layer.cornerRadius = CineSeatRadius.small
        chip.layer.borderWidth = 1
        chip.layer.borderColor = CineSeatTheme.border.cgColor
        chip.heightAnchor.constraint(equalToConstant: 38).isActive = true
        chip.accessibilityLabel = "\(time.showtime), \(movie.title)"
        chip.addTarget(self, action: #selector(showtimeChipTapped(_:)), for: .touchUpInside)
        return chip
    }

    @objc private func viewMovieTapped(_ sender: UIButton) {
        guard movieLookup.indices.contains(sender.tag) else { return }
        navigationController?.pushViewController(
            factory.makeMovieDetailViewController(movie: movieLookup[sender.tag]),
            animated: true
        )
    }

    @objc private func showtimeChipTapped(_ sender: UIButton) {
        guard chipLookup.indices.contains(sender.tag) else { return }
        let selection = chipLookup[sender.tag]
        navigationController?.pushViewController(
            factory.makeMovieDetailViewController(
                movie: selection.movie,
                preselectedTimeID: selection.timeID
            ),
            animated: true
        )
    }
}
