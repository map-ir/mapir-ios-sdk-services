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
    let session = URLSession.shared
    let decoder = JSONDecoder()

    var dismat: MPSDistanceMatrix? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        let url: URL! = URL(string: "https://map.ir/distancematrix?origins=a%2C35.743534%2C51.456549%7Cb%2C35.757213%2C51.450101%7Cc%2C35.761801%2C51.458255&destinations=d%2C35.772561%2C51.443138%7Cf%2C35.785861%2C51.448116%7Cg%2C35.799228%2C51.451163&sorted=false")
        var request = URLRequest(url: url)
        request.addValue("WsLdHK46I5Wfr5xgI0ynjjyiw9Fyhydu", forHTTPHeaderField: "x-api-key")
        request.httpMethod = "get"
        request.timeoutInterval = 10

        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            }
            if let data = data {
                let dismat = try? self.decoder.decode(MPSDistanceMatrix.self, from: data)
                if let dismat = dismat {
                    for origin in dismat.origins {
                        print("Origin: \(origin.name!)")
                    }
                    for dest in dismat.destinations {
                        print("Dest: \(dest.name!)")
                    }
                    for distance in dismat.distances {
                        print("Distance of \(distance.origin.name!) to \(distance.destination.name!) is: \(distance.distance)")
                    }
                    for duration in dismat.durations {
                        print("Duration of \(duration.origin.name!) to \(duration.destination.name!) is: \(duration.duration)")
                    }
                }
                self.dismat = dismat
            }
        }.resume()
    }

    /// LoadView
    override func loadView() {
        self.view = self.label
    }

}
