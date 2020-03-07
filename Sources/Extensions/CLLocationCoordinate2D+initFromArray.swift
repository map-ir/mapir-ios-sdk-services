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

    init?(from arrayLiteral: [Double]) {
        guard arrayLiteral.count == 2 else { return nil }

        self.init(latitude: arrayLiteral[1], longitude: arrayLiteral[0])
    }
}
