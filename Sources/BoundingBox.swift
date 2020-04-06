//
//  BoundingBox.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 18/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import Foundation

struct BoundingBox {
    var southWest: CLLocationCoordinate2D
    var northEast: CLLocationCoordinate2D

    init(polygons: [Polygon]) {
        var latitudes: [Double] = []
        var longitudes: [Double] = []

        polygons.forEach { polygon in
            polygon.coordinates.forEach { coord in
                latitudes.append(coord.latitude)
                longitudes.append(coord.longitude)
            }
        }

        guard !latitudes.isEmpty, !longitudes.isEmpty else {
            preconditionFailure("Polygon does not have coordinates.")
        }

        southWest = CLLocationCoordinate2D(latitude: latitudes.min()!, longitude: longitudes.min()!)
        northEast = CLLocationCoordinate2D(latitude: latitudes.max()!, longitude: longitudes.max()!)

    }

    init(polygon: Polygon) {
        self.init(polygons: [polygon])
    }

    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        (southWest.latitude...northEast.latitude).contains(coordinate.latitude) &&
            (southWest.longitude...northEast.longitude).contains(coordinate.longitude)
    }
}
