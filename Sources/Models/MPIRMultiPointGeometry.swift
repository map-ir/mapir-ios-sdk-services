//
//  MPIRMultiPointGeometry.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/3/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

class MPIRPolygon: MPIRGeometry {
    
    var coordinates: [CLLocationCoordinate2D]
    
    init(from coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }
}
