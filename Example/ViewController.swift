//
//  ViewController.swift
//  Example
//
//  Created by Alireza Asadi on 31 Ordibehesht, 1398 AP.
//  Copyright © 1398 Map. All rights reserved.
//

import UIKit
import MapirServices

// MARK: - ViewController

/// The ViewController
class ViewController: UIViewController {

    // MARK: Properties
    
    /// The Label
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "🚀\nMapirServices\nExample\nYou may watch your debbugin console :)"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()

    // MARK: Instance of MapirServices
    let mps = MPSMapirServices.shared
    
    // MARK: View-Lifecycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        let coordinates = MPSLocationCoordinate(latitude: 35.732527, longitude: 51.422710)
        let size = CGSize(width: 300, height: 250)
        let marker = MPSStaticMapMarker(coordinate: coordinates, style: MPSStaticMapMarker.Style.red, label: "mapir")

        mps.getStaticMap(center: coordinates,
                         size: size,
                         zoomLevel: 15,
                         markers: [marker]) { (result) in

                            switch result{
                            case .failure(let error):
                                debugPrint(error.localizedDescription)
                            case .success(let image):
                                let backgroundImage = image
                                let uiImageView = UIImageView(image: backgroundImage)
                                uiImageView.frame.origin = CGPoint(x: self.view.frame.midX - uiImageView.frame.width / 2,
                                                                   y: self.view.frame.maxY - uiImageView.frame.height - 50)
                                uiImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                self.view.insertSubview(uiImageView, belowSubview: self.view)
                            }
        }

        mps.getReverseGeocode(for: coordinates) { (result) in
            switch result {
            case .success(let reverse):
                print("getReverseGeocode method for (\(coordinates.latitude), \(coordinates.longitude)) was successful.")
                print("---> address is: \(reverse.address ?? "nil")")
            case .failure(let error):
                print("getReverseGeocode failed with error: \(error.localizedDescription)")
            }
        }

        mps.getFastReverseGeocode(for: coordinates) { (result) in
            switch result {
            case .success(let reverse):
                print("getFastReverseGeocode method for (\(coordinates.latitude), \(coordinates.longitude)) was successful.")
                print("---> address is: \(reverse.address ?? "nil")")
            case .failure(let error):
                print("getFastReverseGeocode failed with error: \(error.localizedDescription)")
            }
        }

    }

    /// LoadView
    override func loadView() {
        self.view = self.label
    }

}
