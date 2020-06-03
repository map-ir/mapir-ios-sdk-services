//
//  GeocoderViewController.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 26/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit
import MapKit
import MapirServices

class GeocoderViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!


    var latestGeocodeResult: Placemark? {
        didSet { DispatchQueue.main.async { self.tableView.reloadData() } }
    }

    var geocoder = Geocoder()

    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = MKMapCamera(lookingAtCenter: Constants.tehranCoordinate, fromDistance: 5_000_000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: false)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPressGesture)

        mapView.delegate = self

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
            latestGeocodeResult = nil

            mapView.addAnnotation(annotation)
        default:
            break
        }
    }
}

extension GeocoderViewController: MKMapViewDelegate {

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

        let button = UIButton(type: .detailDisclosure)

        annotationView.leftCalloutAccessoryView = button
        return annotationView
    }

    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        let annotation = view.annotation
        geocoder.reverseGeocode(annotation!.coordinate) { [weak self] (result) in
            switch result {
            case .success(let placemarks):
                guard let placemark = placemarks.first else { return }
                self?.latestGeocodeResult = placemark
            case .failure:
                break
            }
        }
    }
}

extension GeocoderViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latestGeocodeResult == nil ? 1 : 8
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyValueCell.reuseIdentifier) as! PropertyValueCell

        guard let placemark = latestGeocodeResult else {
            cell.propertyNameLabel.text = "Note"
            cell.propertyValueLabel.text = "Long press a location on the map. Then press i button to start reverse geocoding."
            return cell
        }

        cell.propertyNameLabel.text = propertyName(forRowAt: indexPath)
        cell.propertyValueLabel.text = placemark[keyPath: propertyKeyPath(forRowAt: indexPath)]

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    private func propertyName(forRowAt indexPath: IndexPath) -> String {
        let keys: [String] = [
            "Full Address",
            "Postal Address",
            "POI",
            "Neighborhood",
            "District",
            "City",
            "Province",
            "Postal Code",
        ]

        return keys[indexPath.row]

    }

    private func propertyKeyPath(forRowAt indexPath: IndexPath) -> KeyPath<Placemark, String?> {
        let placemarkProperties: [KeyPath<Placemark, String?>] = [
            \.address,
            \.postalAddress,
            \.poi,
            \.neighborhood,
            \.district,
            \.city,
            \.province,
            \.postalCode,
        ]

        return placemarkProperties[indexPath.row]
    }
}

