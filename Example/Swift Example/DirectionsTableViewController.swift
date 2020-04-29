//
//  DirectionsTableViewController.swift
//  MapirServices Swift Example
//
//  Created by Alireza Asadi on 3/2/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit
import MapirServices
import MapKit

class DirectionsTableViewController: UITableViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var exclusionsSegmentedControl: UISegmentedControl!

    let directions = Directions()
    var directionsConfiguration: Directions.Configuration = .default

    var waypointAnnotations: [MKPointAnnotation] = []
    var routeOverlays: [MKPolyline] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = MKMapCamera(lookingAtCenter: Constants.tehranCoordinate, fromDistance: 500_000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: false)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.4
        self.mapView.addGestureRecognizer(longPressGesture)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1...4: return 1
        default: return 0
        }
    }

    @IBAction func vehicleUpdated(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            directionsConfiguration.vehicleType = .privateCar
            exclusionsSegmentedControl.isEnabled = true
        case 1:
            directionsConfiguration.vehicleType = .foot
            exclusionsSegmentedControl.setEnabled(true, forSegmentAt: 0)
            exclusionsSegmentedControl.isEnabled = false
        case 2:
            directionsConfiguration.vehicleType = .bicycle
            exclusionsSegmentedControl.setEnabled(true, forSegmentAt: 0)
            exclusionsSegmentedControl.isEnabled = false
        default:
            break
        }
    }

    @IBAction func exclusionAreaUpdated(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            directionsConfiguration.areaToExclude = .none
        case 1:
            directionsConfiguration.areaToExclude = .trafficControlArea
        case 2:
            directionsConfiguration.areaToExclude = .airPollutionControlArea
        default:
            break
        }
    }

    @IBAction func numberOfRoutesUpdated(_ sender: UISegmentedControl) {
        directionsConfiguration.numberOfAlternatives = sender.selectedSegmentIndex
    }

    @IBAction func inludeStepsUpdated(_ sender: UISegmentedControl) {
        directionsConfiguration.includeSteps = sender.selectedSegmentIndex == 0 ? true : false
    }

    @IBAction func routeOverviewStyleUpated(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            directionsConfiguration.routeOverviewStyle = .full
        case 1:
            directionsConfiguration.routeOverviewStyle = .simplified
        case 2:
            directionsConfiguration.routeOverviewStyle = .none
        default:
            break
        }
    }

    @IBAction func routeButtonTapped(_ sender: UIBarButtonItem) {
        guard waypointAnnotations.count >= 2 else {
            showAlert(
                title: "Missing Required Field",
                message: "You have to specify at least 2 coordinates on the map before routing."
            ) { (_) in
                let mapIndexPath = IndexPath(row: 0, section: 4)
                self.tableView.scrollToRow(at: mapIndexPath, at: .bottom, animated: true)
            }
            return
        }

        mapView.removeOverlays(routeOverlays)

        let coordinates = waypointAnnotations.map { $0.coordinate }
        directions.calculateDirections(among: coordinates, configuration: directionsConfiguration) { [weak self] (result, error) in
            if let error = error {
                let errorDesc = (error as? ServiceError)?.localizedDescription ?? "Unknown Error"
                DispatchQueue.main.async {
                    self?.showAlert(
                        title: "Error",
                        message: "Something went wrong in routing process.\nError: \(errorDesc)")
                }
                return
            }
            if let result = result {
                for route in result.routes {
                    if let coordinates = route.coordinates {
                        DispatchQueue.main.async {
                            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                            self?.mapView.addOverlay(polyline)
                            self?.routeOverlays.append(polyline)
                        }
                    }
                }
            }
        }
    }

    @IBAction func clearRoutingPointsButtonTapped(_ sender: UIBarButtonItem) {
        waypointAnnotations = []
        let annotations = mapView.annotations
        let overlays = mapView.overlays
        mapView.removeAnnotations(annotations)
        mapView.removeOverlays(overlays)
    }

    @objc func didRecognizeLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .ended:
            let point = gesture.location(in: mapView)
            let targetCoordinate = mapView.convert(point, toCoordinateFrom: mapView)

            let annotation = MKPointAnnotation()
            annotation.coordinate = targetCoordinate
            annotation.title =
                "\(String(targetCoordinate.latitude).prefix(9)), \(String(targetCoordinate.longitude).prefix(9))"

            let currentAnnotations = mapView.annotations
            let currentPointAnnotations = currentAnnotations
                .filter { $0.isKind(of: MKPointAnnotation.self) }
                .map { $0 as! MKPointAnnotation }

            let unsavedAnnotations = currentPointAnnotations
                .filter { !self.waypointAnnotations.contains($0) }

            mapView.removeAnnotations(unsavedAnnotations)
            mapView.addAnnotation(annotation)
        default:
            break
        }
    }
}

extension DirectionsTableViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard !(annotation is MKUserLocation),
            !(annotation is MKPolyline) else { return nil }
        
        let reuseID = "CoordinateAnnotation"
        let annotationView: MKMarkerAnnotationView
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        }
        annotationView.animatesWhenAdded = true
        annotationView.canShowCallout = true

        if let pointAnnotation = annotation as? MKPointAnnotation {
            let button = UIButton(type: .system)
            button.frame = .zero

            if !waypointAnnotations.contains(pointAnnotation) {
                button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            } else {
                button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            }

            button.sizeToFit()
            annotationView.leftCalloutAccessoryView = button
        }

        return annotationView
    }

    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        if let pointAnnotation = view.annotation as? MKPointAnnotation {
            if !waypointAnnotations.contains(pointAnnotation) {
                waypointAnnotations.append(pointAnnotation)

                pointAnnotation.subtitle = pointAnnotation.title
                pointAnnotation.title = "Waypoint \(waypointAnnotations.count)"

                if let leftCalloutButton = control as? UIButton {
                    leftCalloutButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                }
            } else {
                waypointAnnotations.removeAll { $0 == pointAnnotation }
                mapView.removeAnnotation(pointAnnotation)
                for (offset, annotation) in waypointAnnotations.enumerated() {
                    annotation.title = "Waypoint \(offset + 1)"
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(
                hue: .random(in: 0...100) / 100,
                saturation: 0.6,
                brightness: 1.0,
                alpha: 1.0
            )
            renderer.lineWidth = 3.0
            return renderer
        }

        return MKOverlayRenderer()
    }
}
