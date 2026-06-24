import UIKit
import MapKit

// module 2 locations tab
// mapkit stays in this file so settings remains only for settings
final class CinemaLocationsViewController: UIViewController {
    var viewModel = CinemaLocationsViewModel()

    private let headerStack = UIStackView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let mapView = MKMapView()
    private let zoomButtonStack = UIStackView()
    private let zoomInButton = UIButton(type: .system)
    private let zoomOutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Locations"
        view.backgroundColor = CineSeatTheme.background
        buildInterface()
        addCinemaPins()
    }

    private func buildInterface() {
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .vertical
        headerStack.spacing = CineSeatSpacing.tiny

        titleLabel.text = "Cinema Locations"
        titleLabel.font = CineSeatFont.pageTitle
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0

        countLabel.text = viewModel.cinemaCountText
        countLabel.font = CineSeatFont.caption
        countLabel.textColor = CineSeatTheme.mutedText
        countLabel.numberOfLines = 0

        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(countLabel)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.layer.cornerRadius = CineSeatRadius.large
        mapView.clipsToBounds = true

        buildZoomControls()

        view.addSubview(headerStack)
        view.addSubview(mapView)
        view.addSubview(zoomButtonStack)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CineSeatSpacing.large),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),

            mapView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: CineSeatSpacing.large),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CineSeatSpacing.pageHorizontal),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CineSeatSpacing.pageHorizontal),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -CineSeatSpacing.pageHorizontal),

            zoomButtonStack.topAnchor.constraint(equalTo: mapView.topAnchor, constant: CineSeatSpacing.medium),
            zoomButtonStack.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -CineSeatSpacing.medium),
            zoomInButton.widthAnchor.constraint(equalToConstant: 44),
            zoomInButton.heightAnchor.constraint(equalToConstant: 44),
            zoomOutButton.widthAnchor.constraint(equalToConstant: 44),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func buildZoomControls() {
        zoomButtonStack.translatesAutoresizingMaskIntoConstraints = false
        zoomButtonStack.axis = .vertical
        zoomButtonStack.spacing = CineSeatSpacing.small
        zoomButtonStack.distribution = .fillEqually

        configureZoomButton(zoomInButton, systemImageName: "plus.magnifyingglass", accessibilityLabel: "Zoom in")
        configureZoomButton(zoomOutButton, systemImageName: "minus.magnifyingglass", accessibilityLabel: "Zoom out")

        zoomInButton.addTarget(self, action: #selector(zoomInTapped), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(zoomOutTapped), for: .touchUpInside)

        zoomButtonStack.addArrangedSubview(zoomInButton)
        zoomButtonStack.addArrangedSubview(zoomOutButton)
    }

    private func configureZoomButton(_ button: UIButton, systemImageName: String, accessibilityLabel: String) {
        button.backgroundColor = CineSeatTheme.card
        button.tintColor = CineSeatTheme.primaryText
        button.layer.cornerRadius = CineSeatRadius.medium
        button.layer.borderColor = CineSeatTheme.border.cgColor
        button.layer.borderWidth = 1
        button.setImage(UIImage(systemName: systemImageName), for: .normal)
        button.accessibilityLabel = accessibilityLabel
    }

    @objc private func zoomInTapped() {
        adjustMapZoom(multiplier: 0.55)
    }

    @objc private func zoomOutTapped() {
        adjustMapZoom(multiplier: 1.8)
    }

    private func adjustMapZoom(multiplier: CLLocationDegrees) {
        let currentRegion = mapView.region
        let latitudeDelta = min(max(currentRegion.span.latitudeDelta * multiplier, 0.002), 1.5)
        let longitudeDelta = min(max(currentRegion.span.longitudeDelta * multiplier, 0.002), 1.5)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        mapView.setRegion(MKCoordinateRegion(center: currentRegion.center, span: span), animated: true)
    }

    private func addCinemaPins() {
        let annotations = viewModel.mappedCinemas.compactMap { cinema -> MKPointAnnotation? in
            guard let location = cinema.location else { return nil }
            let annotation = MKPointAnnotation()
            annotation.title = cinema.name
            annotation.subtitle = "\(cinema.type.rawValue) - \(location.address)"
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            return annotation
        }

        mapView.addAnnotations(annotations)
        guard !annotations.isEmpty else { return }

        let latitudes = annotations.map(\.coordinate.latitude)
        let longitudes = annotations.map(\.coordinate.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (latitudes.min()! + latitudes.max()!) / 2,
            longitude: (longitudes.min()! + longitudes.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((latitudes.max()! - latitudes.min()!) * 1.8, 0.02),
            longitudeDelta: max((longitudes.max()! - longitudes.min()!) * 1.8, 0.02)
        )
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
    }
}
