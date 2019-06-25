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
        label.text = "🚀\nMapirServices\nExample"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    // MARK: View-Lifecycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        let session = URLSession.shared

        let lat = 35.7006311416626
        let lng = 51.3361930847168

        let url = URL(string: "https://map.ir/reverse?lat=\(lat)&lon=\(lng)")

        let decoder = JSONDecoder()

        var request = URLRequest(url: url!)
        request.httpMethod = "get"
        request.timeoutInterval = 20

        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let obj = try! decoder.decode(MPSReverseGeocode.self, from: data)
                print(obj.address!)
                print(obj.coordinates)
                print(obj.postalAddress!)
            }
        }.resume()

    }
    
    /// LoadView
    override func loadView() {
        self.view = self.label
    }

}
