//
//  CoordinateSelectionViewController.swift
//  MapirServices Swift Example
//
//  Created by Alireza Asadi on 2/2/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit
import MapKit

protocol CoordinateSelectionDelegate: class {
    func viewController(
        _ vc: CoordinateSelectionViewController,
        willDismissWithSelectedCoordinate selectedCoordinate: CLLocationCoordinate2D?)
}

class CoordinateSelectionViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    var selectedCoordinate: CLLocationCoordinate2D?
    var mapCenter: CLLocationCoordinate2D?

    weak var delegate: CoordinateSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = MKMapCamera(
            lookingAtCenter: mapCenter ?? Constants.tehranCoordinate,
            fromDistance: 800_000,
            pitch: 0,
            heading: 0)

        mapView.setCamera(camera, animated: false)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.4
        self.mapView.addGestureRecognizer(longPressGesture)
    }

    @objc func didRecognizeLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .ended:
            let point = gesture.location(in: mapView)
            let targetCoordinate = mapView.convert(point, toCoordinateFrom: mapView)

            let annotation = MKPointAnnotation()
            annotation.coordinate = targetCoordinate
            annotation.title = "\(String(targetCoordinate.latitude).prefix(9)), \(String(targetCoordinate.longitude).prefix(9))"

            let currentAnnotations = mapView.annotations
            mapView.removeAnnotations(currentAnnotations)

            mapView.addAnnotation(annotation)
        default:
            break
        }

    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        delegate?.viewController(self, willDismissWithSelectedCoordinate: selectedCoordinate)

        super.dismiss(animated: flag, completion: completion)
    }
}

extension CoordinateSelectionViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }

        let reuseID = "CoordinateAnnotation"
        let annotationView: MKMarkerAnnotationView
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        }
        annotationView.animatesWhenAdded = true
        annotationView.canShowCallout = true

        let button = UIButton(type: .system)
        button.frame = .zero
        button.setTitle("Select", for: .normal)
        button.sizeToFit()

        annotationView.leftCalloutAccessoryView = button
        return annotationView
    }

    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        let annotation = view.annotation
        selectedCoordinate = annotation?.coordinate
        dismiss(animated: true)
    }

}

