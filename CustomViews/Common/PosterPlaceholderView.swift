import UIKit

// module 4 poster loader
// bundled images are used first then urlsession cache is the fallback
final class PosterPlaceholderView: UIView {
    private let imageView = UIImageView()
    private let iconView = UIImageView(image: UIImage(systemName: "photo"))
    private let titleLabel = CineSeatTheme.captionLabel("Poster")
    private var currentPosterID: String?
    private var task: URLSessionDataTask?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = CineSeatTheme.placeholder
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.69, alpha: 1).cgColor
        clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        addSubview(imageView)

        iconView.tintColor = CineSeatTheme.mutedText
        iconView.contentMode = .scaleAspectFit
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func loadPoster(from urlString: String?, localName: String? = nil) {
        task?.cancel()
        imageView.image = nil
        imageView.isHidden = true
        iconView.superview?.isHidden = false
        currentPosterID = localName ?? urlString

        if let localName,
           let image = bundledPoster(named: localName) {
            show(image, for: localName)
            return
        }

        guard let urlString,
              let url = URL(string: urlString) else {
            currentPosterID = nil
            return
        }

        currentPosterID = urlString

        if let cachedURL = cachedFileURL(for: url),
           let data = try? Data(contentsOf: cachedURL),
           let image = UIImage(data: data) {
            show(image, for: urlString)
            return
        }

        task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let image = UIImage(data: data) else {
                return
            }

            if let cachedURL = self.cachedFileURL(for: url) {
                try? data.write(to: cachedURL, options: .atomic)
            }

            DispatchQueue.main.async {
                self.show(image, for: urlString)
            }
        }
        task?.resume()
    }

    private func show(_ image: UIImage, for posterID: String) {
        guard currentPosterID == posterID else { return }
        imageView.image = image
        imageView.isHidden = false
        iconView.superview?.isHidden = true
    }

    private func bundledPoster(named fileName: String) -> UIImage? {
        guard let fileURL = Bundle.main.url(
            forResource: fileName,
            withExtension: nil,
            subdirectory: "PosterImages"
        ),
              let data = FileManager.default.contents(atPath: fileURL.path) else {
            return nil
        }
        return UIImage(data: data)
    }

    private func cachedFileURL(for url: URL) -> URL? {
        guard let cacheDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        let posterDirectory = cacheDirectory.appendingPathComponent("PosterCache", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: posterDirectory,
            withIntermediateDirectories: true
        )
        return posterDirectory.appendingPathComponent(url.lastPathComponent)
    }
}
