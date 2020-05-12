//
//  CLLocationCoordinate2D+initFromArray.swift
//  MapirServices
//
//  Created by Alireza Asadi on 12/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

extension CLLocationCoordinate2D: GeoJSONGeometryConvertible {

    func convertedToGeoJSONGeometry() -> [Double] {
        [longitude, latitude]
    }

    init(fromGeoJSONGeometry geometry: [Double]) throws {
        guard geometry.count == 2 else { throw GeoJSONError.incorrectCoordinateComponents }

        self.init(latitude: geometry[1], longitude: geometry[0])
    }
}
