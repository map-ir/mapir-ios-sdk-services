//
//  MapSnapshotterTableViewController.swift
//  MapirServices Swift Example
//
//  Created by Alireza Asadi on 13/2/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit
import MapKit

import MapirServices

class MapSnapshotterTableViewController: UITableViewController {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var zoomLevelTextField: UITextField!
    @IBOutlet weak var imageWidthTextField: UITextField!
    @IBOutlet weak var imageHeightTextField: UITextField!

    @IBOutlet weak var resultImageView: UIImageView!

    var markers: [MapSnapshotter.Marker] = []

    var snapshotter = MapSnapshotter()

    var markerAnnotations: [MKPointAnnotation] = []
    var updatingMarkerAnnotatationView: MKAnnotationView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = MKMapCamera(lookingAtCenter: Constants.tehranCoordinate, fromDistance: 500_000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: false)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 3: return 1
        case 2: return 2
        default: return 0
        }
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
                .filter { !self.markerAnnotations.contains($0) }

            mapView.removeAnnotations(unsavedAnnotations)
            mapView.addAnnotation(annotation)
        default:
            break
        }
    }

    @IBAction func createSnapshotButtonTapped(_ sender: UIBarButtonItem) {
        guard !markers.isEmpty else {
            showAlert(title: "Missing Marker", message: "At least one marker is required to proceed.")
            return
        }

        guard let heightString = imageHeightTextField.text,
            let widthString = imageWidthTextField.text,
            let height = Int(heightString), let width = Int(widthString) else {
                showAlert(
                    title: "Missing or invalid image size",
                    message: "Image size height and width are required to create a snapshot.")
                return
        }

        guard let zoomLevelString = zoomLevelTextField.text, let zoomLevel = Int(zoomLevelString) else {
            showAlert(
                title: "Missing or invalid zoom level",
                message: "A valid zoom level is required to create a snapshot.")
            return
        }

        let imageSize = CGSize(width: width, height: height)
        let configuration = MapSnapshotter.Configuration(size: imageSize, zoomLevel: zoomLevel, markers: markers)

        snapshotter.createSnapshot(with: configuration) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    let title = "Snapshot loading failed."
                    let message: String
                    if let error = error as? ServiceError {
                        message = "Loading snapshot failed with error: \(error.localizedDescription)"
                    } else {
                        message = "Loading snapshot failed."
                    }
                    self?.showAlert(title: title, message: message)
                case .success(let image):
                    self?.resultImageView.image = image
                    
                    let indexPath = IndexPath(row: 0, section: 3)
                    self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }

            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueID = segue.identifier, segueID == "PresentMarkerDetailViewController" {
            let destination = segue.destination as! MarkerDetailTableViewController

            destination.completionHandler = { [weak self] (style, text) in
                if let annotationView = self?.updatingMarkerAnnotatationView,
                    let pointAnnotation = annotationView.annotation as? MKPointAnnotation {

                    let marker = MapSnapshotter.Marker(
                        at: pointAnnotation.coordinate,
                        label: text,
                        style: style
                    )
                    self?.markers.append(marker)
                    self?.markerAnnotations.append(pointAnnotation)

                    let coordinates = pointAnnotation.coordinate
                    pointAnnotation.subtitle =
                        "\(String(coordinates.latitude).prefix(7)), \(String(coordinates.longitude).prefix(7)) - \(style.rawValue)"
                    pointAnnotation.title = text.isEmpty ? "(No label)" : text

                    if let leftCalloutButton = annotationView.leftCalloutAccessoryView as? UIButton {
                        leftCalloutButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                    }
                }
            }
        }
    }
}

extension MapSnapshotterTableViewController: MKMapViewDelegate  {

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

            if !markerAnnotations.contains(pointAnnotation) {
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
            if !markerAnnotations.contains(pointAnnotation) {
                updatingMarkerAnnotatationView = view
                performSegue(withIdentifier: "PresentMarkerDetailViewController", sender: control)
            } else {
                if let index = markerAnnotations.firstIndex(of: pointAnnotation) {
                    markerAnnotations.remove(at: index)
                    markers.remove(at: index)
                    mapView.removeAnnotation(pointAnnotation)
                }
            }
        }

    }
}
