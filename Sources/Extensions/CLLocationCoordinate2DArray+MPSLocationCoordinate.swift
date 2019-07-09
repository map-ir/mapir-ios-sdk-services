//
//  CLLocationCoordinate2DArray+MPSLocationCoordinate.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 12/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

extension Array where Element == CLLocationCoordinate2D {
    var asMPSLocationCoordintes: [MPSLocationCoordinate] {
        var locationCoordintes = [MPSLocationCoordinate]()
        for clcoord in self {
            locationCoordintes.append((clcoord as CLLocationCoordinate2D).asMPSLocationCoordinate)
        }
        return locationCoordintes
    }
}
