//
//  GeoJSONGeometryConvertible.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 20/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import Foundation

/// A geometrical object which is convertible from and to GeoJSON notation.
protocol GeoJSONGeometryConvertible {

    /// A type that represents the format that the geometry is presented in GeoJSON.
    associatedtype GeoJSONType

    /// Converts existing shape and geometries to a format which is convertible to
    /// GeoJSON, using `JSONEncoder`.
    func convertedToGeoJSONGeometry() -> GeoJSONType

    /// Creates a shape that is expressible using GeoJSON accepted geometries.
    ///
    /// - Parameter geometry: geometry which is needed to be converted to Swift readable
    ///   format.
    init(fromGeoJSONGeometry geometry: GeoJSONType) throws
}
