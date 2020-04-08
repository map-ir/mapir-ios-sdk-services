//
//  GeoJSONError.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 20/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import Foundation

enum GeoJSONError: Error {

    /// A polygon needs at least 4 coordinates as vertices to be acceptable. This error
    /// occures when a `Polygon` is being created with 3 or less coordinates.
    case insufficientCoordinates

    /// Happens when polygon is empty.
    case insufficientPolygons

    /// To create a `CLLocationCoordinate2D` object using a GeoJSON notation, an array
    /// of longitude and latitude is needed. if the array has any more or less values other than
    /// these two, it's considered incorrect.
    case incorrectCoordinateComponents
}
