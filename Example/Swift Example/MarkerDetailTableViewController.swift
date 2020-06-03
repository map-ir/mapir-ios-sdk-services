//
//  MarkerDetailTableViewController.swift
//  MapirServices Swift Example
//
//  Created by Alireza Asadi on 13/2/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit
import MapirServices

class MarkerDetailTableViewController: UITableViewController {

    @IBOutlet weak var labelTextField: UITextField!

    @IBOutlet var styleCells: [UITableViewCell]!

    var selectedMarkerStyle: MapSnapshotter.Marker.Style?

    var completionHandler: ((_ markerStyle: MapSnapshotter.Marker.Style, _ label: String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 2: return 1
        case 1: return 14
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.section == 1 else { return }

        let selectedCell = styleCells[indexPath.row]

        styleCells.forEach { $0.accessoryType = .none }
        selectedCell.accessoryType = .checkmark

        if let styleName = selectedCell.textLabel?.text?.lowercased() {
            selectedMarkerStyle = MapSnapshotter.Marker.Style(rawValue: styleName)
        }
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let markerStyle = selectedMarkerStyle, let labelText = labelTextField.text else {
            showAlert(
                title: "Missing Style",
                message: "You have to specity a style for the marker before adding the marker.")
            return
        }

        completionHandler?(markerStyle, labelText)
        dismiss(animated: true)
    }
}
