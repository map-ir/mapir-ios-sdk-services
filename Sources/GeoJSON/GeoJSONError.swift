//
//  GeoJSONError.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 20/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import Foundation

/// Errors related to decoding from GeoJSON or creating objects that are
/// representable in GeoJSON format, such as `Polygon`.
@objc(SHGeoJSONError)
public enum GeoJSONError: UInt, Error {

    /// A polygon needs at least 4 coordinates as vertices to be acceptable. This error
    /// occurs when a `Polygon` is being created with 3 or less coordinates.
    case insufficientCoordinates

    /// Happens when polygon is empty.
    case insufficientPolygons

    /// Interior polygons of a `Polygon` should have no interior polygons of their own.
    case incorrectInteriorPolygonsFormat

    /// To create a `CLLocationCoordinate2D` object using a GeoJSON notation, an array
    /// of longitude and latitude is needed. if the array has any more or less values other than
    /// these two, it's considered incorrect.
    case incorrectCoordinateComponents
}
