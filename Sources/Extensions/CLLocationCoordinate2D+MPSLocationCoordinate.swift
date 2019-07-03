//
//  CLLocationCoordinate2D+MPSLocationCoordinate.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 12/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    var asMPSLocationCoordinate: MPSLocationCoordinate {
        return MPSLocationCoordinate(from: self)
    }
}
