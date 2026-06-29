import UIKit
import MapKit

// module 2 locations tab
// mapkit stays in this file so settings remains only for settings
final class CinemaLocationsViewController: UIViewController {
    var factory = AppFactory.shared
    var viewModel = CinemaLocationsViewModel()

    private let headerStack = UIStackView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let categorySegmentedControl = UISegmentedControl()
    private let mapView = MKMapView()
    private let zoomButtonStack = UIStackView()
    private let zoomInButton = UIButton(type: .system)
    private let zoomOutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Locations"
        view.backgroundColor = CineSeatTheme.background
        buildInterface()
        reloadLocations()
    }

    private func buildInterface() {
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .vertical
        headerStack.spacing = CineSeatSpacing.tiny

        titleLabel.text = "Cinema Locations"
        titleLabel.font = CineSeatFont.pageTitle
        titleLabel.textColor = CineSeatTheme.primaryText
        titleLabel.numberOfLines = 0

        countLabel.text = viewModel.countText
        countLabel.font = CineSeatFont.caption
        countLabel.textColor = CineSeatTheme.mutedText
        countLabel.numberOfLines = 0

        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(countLabel)

        for (index, category) in viewModel.categories.enumerated() {
            categorySegmentedControl.insertSegment(withTitle: category.title, at: index, animated: false)
        }
        categorySegmentedControl.selectedSegmentIndex = viewModel.selectedCategory.rawValue
        categorySegmentedControl.addTarget(self, action: #selector(locationCategoryChanged(_:)), for: .valueChanged)
        categorySegmentedControl.accessibilityIdentifier = "locationCategoryFilter"
        headerStack.addArrangedSubview(categorySegmentedControl)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
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

    @objc private func locationCategoryChanged(_ sender: UISegmentedControl) {
        viewModel.selectCategory(at: sender.selectedSegmentIndex)
        reloadLocations()
    }

    private func reloadLocations() {
        titleLabel.text = viewModel.titleText
        countLabel.text = viewModel.countText
        mapView.removeAnnotations(mapView.annotations)
        addLocationPins()
    }

    private func addLocationPins() {
        let annotations = viewModel.mapItems.compactMap { item -> LocationAnnotation? in
            guard let latitude = item.latitude, let longitude = item.longitude else { return nil }
            let annotation = LocationAnnotation(itemID: item.id, category: viewModel.selectedCategory)
            annotation.title = item.title
            annotation.subtitle = item.subtitle
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
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

private final class LocationAnnotation: MKPointAnnotation {
    let itemID: String
    let category: LocationCategory

    init(itemID: String, category: LocationCategory) {
        self.itemID = itemID
        self.category = category
        super.init()
    }
}

extension CinemaLocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let locationAnnotation = annotation as? LocationAnnotation else { return nil }

        let reuseIdentifier = "CinemaPin"
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)

        view.annotation = annotation
        view.canShowCallout = true
        // stock Apple Maps red pin/marker look
        view.markerTintColor = locationAnnotation.category == .cinemas ? .systemRed : .systemOrange
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return view
    }

    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        guard let annotation = view.annotation as? LocationAnnotation,
              let item = viewModel.item(id: annotation.itemID) else {
            return
        }

        switch item {
        case .cinema(let cinema):
            navigationController?.pushViewController(
                factory.makeCinemaDetailViewController(cinema: cinema),
                animated: true
            )
        case .eventVenue(let venue):
            navigationController?.pushViewController(
                factory.makeEventVenueDetailViewController(venue: venue),
                animated: true
            )
        }
    }
}
