//
//  Array+PolygonAdditions.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 20/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import Foundation

extension Array: GeoJSONGeometryConvertible where Element == Polygon {
    func convertedToGeoJSONGeometry() -> [[[[Double]]]] {
        var multiPolygon: [[[[Double]]]] = []
        for p in self {
            multiPolygon.append(p.convertedToGeoJSONGeometry())
        }
        return multiPolygon
    }

    init(fromGeoJSONGeometry geometry: [[[[Double]]]]) throws {
        self = []
        for polygonGeom in geometry {
            self.append(try Polygon(fromGeoJSONGeometry: polygonGeom))
        }
    }
}
