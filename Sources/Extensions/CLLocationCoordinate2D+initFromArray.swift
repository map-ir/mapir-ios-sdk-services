//
//  CLLocationCoordinate2D+initFromArray.swift
//  MapirServices
//
//  Created by Alireza Asadi on 12/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

extension CLLocationCoordinate2D {
    init(from array: [Double]) {
        self.init(latitude: array[1], longitude: array[0])
    }
}
