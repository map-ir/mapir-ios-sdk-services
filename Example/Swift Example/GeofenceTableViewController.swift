//
//  GeofenceTableViewControllerTableViewController.swift
//  MapirServices Swift Example
//
//  Created by Alireza Asadi on 8/2/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit
import MapKit
import MapirServices

class GeofenceTableViewController: UITableViewController {


    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var finalizeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    @IBOutlet weak var uploadButton: UIButton!

    @IBOutlet weak var fenceIDTextField: UITextField!


    var polygons: [MKPolygon] = [] {
        didSet {
            uploadButton.isEnabled = polygons.isEmpty ? false : true

            let polygonsOnMap = mapView.overlays.compactMap { $0 as? MKPolygon }
            let polygonsNotOnMap = polygons.filter { !polygonsOnMap.contains($0) }
            let polygonsToDelete = polygonsOnMap
                .filter { !self.polygons.contains($0) && $0 != self.activePointsPolygon }

            mapView.removeOverlays(polygonsToDelete)
            mapView.addOverlays(polygonsNotOnMap)

            fence = nil
        }
    }

    var activePointsAnnotations: [MKPointAnnotation] = [] {
        didSet {
            finalizeButton.isEnabled = activePointsAnnotations.count >= 3 ? true : false
            deleteButton.isEnabled = !polygons.isEmpty || !activePointsAnnotations.isEmpty ? true : false

            if activePointsAnnotations.count < 3 {
                if let overlay = activePointsPolygon {
                    mapView.removeOverlay(overlay)
                    activePointsPolygon = nil
                }
            } else {
                if let overlay = activePointsPolygon {
                    mapView.removeOverlay(overlay)
                }
                var coordinates = activePointsAnnotations.map { $0.coordinate }
                coordinates.append(activePointsAnnotations.first!.coordinate)
                let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
                activePointsPolygon = polygon
                mapView.addOverlay(polygon)
            }

            let annotationsOnTheMap = mapView.annotations.compactMap { $0 as? MKPointAnnotation }
            let annotationsNotOnTheMap = activePointsAnnotations.filter { !annotationsOnTheMap.contains($0) }
            let annotationsToDelete = annotationsOnTheMap.filter { !self.activePointsAnnotations.contains($0) }

            mapView.removeAnnotations(annotationsToDelete)
            mapView.addAnnotations(annotationsNotOnTheMap)
        }
    }

    var activePointsPolygon: MKPolygon?

    var fence: Fence?

    var geofence = Geofence()

    override func viewDidLoad() {
        super.viewDidLoad()

        finalizeButton.isEnabled = false
        deleteButton.isEnabled = false
        uploadButton.isEnabled = false

        let camera = MKMapCamera(lookingAtCenter: Constants.tehranCoordinate, fromDistance: 500_000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: false)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 3
        case 2: return 1
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
                .filter { !self.activePointsAnnotations.contains($0) }

            mapView.removeAnnotations(unsavedAnnotations)
            mapView.addAnnotation(annotation)
        default:
            break
        }
    }

    @IBAction func loadFenceButtonTapped(_ sender: UIButton) {
        guard let fenceIDString = fenceIDTextField.text,
            let fenceID = Int(fenceIDString) else {
            showAlert(
                title: "Missing required value",
                message: "ID field is empty. Specify an ID then try again.")
            return
        }

        geofence.loadFence(withID: fenceID) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    let title = "Fence loading failed"
                    let message: String
                    if let error = error as? ServiceError {
                        message = "Loading fence (ID: \(fenceID)) failed with error: \(error.localizedDescription)"
                    } else {
                        message = "Loading fence (ID: \(fenceID)) failed."
                    }
                    self?.showAlert(title: title, message: message)
                case .success(let fence):
                    self?.activePointsAnnotations = []
                    self?.polygons = []

                    let interiorPolygons = fence.boundaries[0].interiorPolygons
                        .map { MKPolygon(coordinates: $0.coordinates, count: $0.coordinates.count) }
                    let polygon = MKPolygon(
                        coordinates: fence.boundaries[0].coordinates,
                        count: fence.boundaries[0].coordinates.count)

                    self?.polygons.append(polygon)
                    self?.polygons.append(contentsOf: interiorPolygons)

                    self?.fitMap(to: polygon)

                    self?.fence = fence
                }
            }
        }
    }


    @IBAction func finalizeButtonTapped(_ sender: UIButton) {
        if let polygon = activePointsPolygon {
            activePointsPolygon =  nil
            mapView.removeOverlay(polygon)
            polygons.append(polygon)
        }

        activePointsAnnotations = []
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if activePointsAnnotations.isEmpty {
            polygons = polygons.dropLast()
        } else {
            activePointsAnnotations = []
        }
    }

    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        do {
            var coordinates = Array(repeating: kCLLocationCoordinate2DInvalid, count: polygons[0].pointCount)
            polygons[0].getCoordinates(&coordinates, range: NSRange(location: 0, length: coordinates.count))

            var interiorPolygons: [Polygon] = []
            for interiorMKPolygon in polygons[1...] {
                var coordinates: [CLLocationCoordinate2D] = Array(
                    repeating: kCLLocationCoordinate2DInvalid,
                    count: interiorMKPolygon.pointCount
                )
                interiorMKPolygon.getCoordinates(&coordinates, range: NSRange(location: 0, length: interiorMKPolygon.pointCount))

                let polygon = try Polygon(coordinates: coordinates)
                interiorPolygons.append(polygon)
            }

            let polygon = try Polygon(coordinates: coordinates, interiorPolygons: interiorPolygons)

            geofence.createFence(withBoundaries: [polygon]) { [weak self] (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        let title = "Error"
                        let message: String
                        if let error = error as? ServiceError {
                            message = "Uploading fence failed with error: \(error)"
                        } else {
                            message = "Uploading fence failed."
                        }

                        self?.showAlert(title: title, message: message)
                    case .success(let fence):
                        let title = "Success"
                        let message = "Fence uploaded successfully. ID: \(fence.id)"
                        self?.showAlert(title: title, message: message)
                        self?.fence = fence
                    }
                }
            }
        } catch {
            showAlert(title: "Couldn't create polygons", message: "Polygons are made of invalid coordinates.")
        }

    }
}

extension GeofenceTableViewController: MKMapViewDelegate {
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

            if !activePointsAnnotations.contains(pointAnnotation) {
                button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            } else {
                button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            }

            button.sizeToFit()
            annotationView.leftCalloutAccessoryView = button
        }

        if fence != nil {
            let button = UIButton()
            button.frame = .zero
            button.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
            button.sizeToFit()
            annotationView.rightCalloutAccessoryView = button
        }

        return annotationView
    }

    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        if let pointAnnotation = view.annotation as? MKPointAnnotation {
            if view.rightCalloutAccessoryView == control as UIView {
                if let fence = fence {
                    let status = fence.contains(pointAnnotation.coordinate)
                    pointAnnotation.subtitle = pointAnnotation.title
                    pointAnnotation.title =
                        "Coordinate is " + (status ? "in" : "out of") + " the fence"

                    view.leftCalloutAccessoryView = nil
                    view.rightCalloutAccessoryView = nil
                }
            } else if !activePointsAnnotations.contains(pointAnnotation) {
                activePointsAnnotations.append(pointAnnotation)

                pointAnnotation.subtitle = pointAnnotation.title
                pointAnnotation.title = "Vertex \(activePointsAnnotations.count)"

                view.rightCalloutAccessoryView = nil

                if let leftCalloutButton = control as? UIButton {
                    leftCalloutButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                }
            } else {
                activePointsAnnotations.removeAll { $0 == pointAnnotation }
                mapView.removeAnnotation(pointAnnotation)
                for (offset, annotation) in activePointsAnnotations.enumerated() {
                    annotation.title = "Vertex \(offset + 1)"
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygon = overlay as! MKPolygon
            let renderer = MKPolygonRenderer(overlay: overlay)
            let strokeColor: UIColor
            if polygon == activePointsPolygon {
                strokeColor = UIColor(hue: 0.4, saturation: 0.6, brightness: 1.0, alpha: 1.0)
            } else {
                if let firstPolygon = polygons.first, polygon == firstPolygon {
                    strokeColor = UIColor(hue: 0, saturation: 0.6, brightness: 1.0, alpha: 1.0)
                } else {
                    strokeColor = UIColor(hue: 0.6, saturation: 0.6, brightness: 1.0, alpha: 1.0)
                }
            }

            renderer.strokeColor = strokeColor
            renderer.lineWidth = 3.0
            return renderer
        }

        return MKOverlayRenderer()
    }

    func fitMap(to shape: MKPolygon) {
        let insets =  UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mapView.setVisibleMapRect(shape.boundingMapRect, edgePadding: insets, animated: true)
    }
}

