import MapKit
import UIKit

// module 2 reusable map preview
// event and venue screens use the same single pin setup
final class LocationPreviewMapView: MKMapView {
    private let regionDistance: CLLocationDegrees = 0.02

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAppearance()
    }

    private func configureAppearance() {
        pointOfInterestFilter = .excludingAll
        // previews do not steal vertical gestures from their parent scroll view
        isScrollEnabled = false
        isZoomEnabled = false
        layer.cornerRadius = CineSeatRadius.large
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: 190).isActive = true
    }

    func show(venue: EventVenue) {
        removeAnnotations(annotations)
        let annotation = MKPointAnnotation()
        annotation.title = venue.name
        annotation.subtitle = venue.address
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: venue.latitude,
            longitude: venue.longitude
        )
        addAnnotation(annotation)
        setRegion(
            MKCoordinateRegion(
                center: annotation.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: regionDistance,
                    longitudeDelta: regionDistance
                )
            ),
            animated: false
        )
    }
}
