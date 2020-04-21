//
//  SearchTableViewController.swift
//  MapirServices Swift Example
//
//  Created by Alireza Asadi on 27/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit
import MapKit
import MapirServices

class SearchTableViewController: UITableViewController {

    @IBOutlet weak var searchTextField: UITextField!

    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!

    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var filterValueTextField: UITextField!

    @IBOutlet var categoryCells: [UITableViewCell]!

    @IBOutlet weak var mapView: MKMapView!

    let search = Search()

    var searchCategories: Search.Categories = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 2
        case 3: return 9
        case 4: return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 3 else { return }

        let selectedCell = categoryCells[indexPath.row]
        let selectedCategory = Search.Categories(rawValue: 1 << indexPath.row)

        switch selectedCell.accessoryType {
        case .none:
            selectedCell.accessoryType = .checkmark
            searchCategories.insert(selectedCategory)
        case .checkmark:
            selectedCell.accessoryType = .none
            searchCategories.remove(selectedCategory)
        default:
            break
        }
    }

    @IBAction func searchButtonTapped(_ sender: Any) {
        if let searchTerm = searchTextField.text, !searchTerm.isEmpty {
            let config = Search.Configuration()
            if let latitudeString = latitudeTextField.text, let longitudeString = longitudeTextField.text, let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
                config.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            if let filterValue = filterValueTextField.text, !filterValue.isEmpty {
                var filter: Search.Filter?
                switch filterSegmentedControl.selectedSegmentIndex {
                case 0:
                    if let doubleValue =  Double(filterValue) {
                        filter = .distance(meter: doubleValue)
                    } else {
                        showAlert(title: "Invalid Filter", message: "For \"Distance\" filter, value must be Floating point number.") { (_) in
                            self.filterValueTextField.text  = ""
                        }
                        return
                    }
                case 1:
                    filter = .city(name: filterValue)
                case 2:
                    filter = .county(name: filterValue)
                case 3:
                    filter = .province(name: filterValue)
                case 4:
                    filter = .neighborhood(name: filterValue)
                case 5:
                    if let intValue = Int(filterValue) {
                        filter = .district(number: intValue)
                    } else {
                        showAlert(title: "Invalid Filter", message: "For \"District\" filter, value must be Integer number.") {
                            (_) in self.filterValueTextField.text  = ""
                        }
                        return
                    }
                default:
                    break
                }
                config.filter = filter
            }
            config.categories = searchCategories

            search.search(for: searchTerm, configuration: config) { [weak self] (results, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.cleanMap()
                        let errorDesc = (error as? ServiceError)?.localizedDescription ?? "Unknown Error"
                        self?.showAlert(
                            title: "Error",
                            message: "Something went wrong in searching process.\nError: \(errorDesc)"
                        ) { (_) in
                            self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                    }
                }
                if let results = results {
                    DispatchQueue.main.async {
                        self?.showSearchResultsOnMap(results)
                    }
                }
            }
            
            tableView.scrollToRow(at: IndexPath(row: 0, section: 4), at: .bottom, animated: true)
        } else {
            showAlert(title: "Missing required search term", message: "Search term text field should not be left empty.") { (_) in
                self.searchTextField.becomeFirstResponder()
            }
        }
    }
}

extension SearchTableViewController {
    func cleanMap() {
        let currentAnnotations = mapView.annotations
        if !currentAnnotations.isEmpty {
            mapView.removeAnnotations(currentAnnotations)
        }
    }

    func showSearchResultsOnMap(_ results: [Search.Result]) {
        cleanMap()
        var annotations: [MKPointAnnotation] = []
        for result in results {
            if let coordinate = result.coordinate {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = result.title
                if let type = result.type, let address = result.address {
                    annotation.subtitle = "\(type) - \(address)"
                }
                annotations.append(annotation)
            }
        }

        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)
    }
}

extension SearchTableViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }

        let reuseID = "ResultAnnotation"
        let annotationView: MKMarkerAnnotationView
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        }
        annotationView.animatesWhenAdded = true
        annotationView.canShowCallout = true
        annotationView.markerTintColor = UIColor(
            hue: CGFloat.random(in: 0...1),
            saturation: 0.5,
            brightness: 1.0,
            alpha: 1.0)

        return annotationView
    }
}

extension SearchTableViewController {
    func showAlert(title: String, message: String, dismissCompletionHandler: ((UIAlertAction) -> Void)? = nil ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default, handler: dismissCompletionHandler)

        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
